class Evmethod < ActiveRecord::Base
  attr_accessible :name, :module
  
  has_many :assignments, :dependent => :destroy
  has_and_belongs_to_many :metrics
  has_many :evaluations, :dependent => :destroy

  validates :name,
  :presence => true,
  :length => { :in => 2..255 },
  :uniqueness => {
    :case_sensitive => false
  }
  validates :module,
  :presence => true,
  :length => { :in => 2..255 },
  :uniqueness => {
    :case_sensitive => false
  }

  def self.allc
    Evmethod.where("name in (?)",LOEP::Application.config.evmethod_names)
  end

  def self.allc_automatic
    allc.where(:automatic => true)
  end


  ################################
  # Method for represent evaluations of a specific evmethod through graphs
  ################################

  def buildRepresentationData(lo,metric=nil)
    if metric.nil?
      metric = Metric.allc.select{|m| m.evmethods == [self]}.first
    end

    evData = lo.getEvaluationData(self)[self.name]

    iScores = evData[:items]
    if iScores.blank? or iScores.include? nil
      return nil
    end

    scale = self.module.constantize.getScale
    iScores.each_with_index do |iScore,index|
      iScores[index] = ((iScore-scale[0]) * 10/(scale[1]-scale[0]).to_f).round(2)
    end

    representationData = Hash.new
    representationData["iScores"] = iScores

    unless metric.nil?
      loScoreForAverage = lo.scores.find_by_metric_id(metric.id)
      unless loScoreForAverage.nil?
        representationData["averageScore"] = loScoreForAverage.value.round(2)
      end
    end

    representationData["name"] = lo.name
    representationData["labels"] = self.module.constantize.getItemsWithType("numeric").map{|li| li[:shortname] || li[:name]}
    representationData["engine"] = "Rgraph"
    representationData
  end

  def representationDataForLos(los)
    representationData = Hash.new
    evModule = self.module.constantize
    items = evModule.getItemsWithType("numeric")

    graphEngine = nil
    nItems = items.length

    iScores =  []
    nItems.times do |i|
      iScores.push(nil)
    end
    
    los.each do |lo|
      rpdLo = evModule.representationData(lo)
      if !graphEngine and !rpdLo.nil? and !rpdLo["engine"].nil?
        graphEngine = rpdLo["engine"]
      end
      unless rpdLo.nil?
        iScoresLo = rpdLo["iScores"]
        nItems.times do |i|
          unless iScoresLo[i].nil?
            if iScores[i].nil?
              iScores[i] = iScoresLo[i]
            else
              iScores[i] = iScores[i] + iScoresLo[i]
            end
          end
        end
      end
    end

    losL = los.length
    nItems.times do |i|
      if !iScores[i].nil?
        iScores[i] = (iScores[i]/losL).round(2)
      end
    end

    representationData["iScores"] = iScores
    representationData["averageScore"] = (representationData["iScores"].sum/representationData["iScores"].size.to_f).round(2)
    representationData["labels"] = items.map{|li| li[:shortname] || li[:name]}
    unless graphEngine.nil?
      representationData["engine"] = graphEngine
    end
    representationData
  end

  def representationDataForComparingLos(los)
    representationData = Hash.new
    evModule = self.module.constantize

    los.each do |lo|
      rpdLo = evModule.representationData(lo)
      if !rpdLo.nil? and !rpdLo["iScores"].nil? and !rpdLo["iScores"].include? nil
        representationData[lo.id] = rpdLo
      end
    end

    if representationData.length < 2
      return nil
    end

    representationData["labels"] = evModule.getItemsWithType("numeric").map{|li| li[:shortname] || li[:name]}
    
    if !representationData.values.first.nil? and !representationData.values.first["engine"].nil?
      representationData["engine"] = representationData.values.first["engine"]
    end

    representationData
  end

  #############
  #Paths
  #############

  def new_evaluation_path(lo)
    evaluationModule = getEvaluationModule
    helper_method_name = "new_" + self.module.gsub(":","").underscore + "_path"
    new_evaluation_path = Rails.application.routes.url_helpers.send(helper_method_name)

    #Add params
    new_evaluation_path + "?lo_id=" + lo.id.to_s
  end

  def new_evaluation_path_with_assignment(assignment)
    new_evaluation_path(assignment.lo) + "&assignment_id=" + assignment.id.to_s
  end

  def root_path
    Rails.application.routes.url_helpers.evmethods_path + "/" + self.shortname
  end

  def documentation_path
    # e.g. '/evmethods/lori/documentation'
    self.root_path + "/documentation"
  end

  def representation_path
    # e.g. '/evmethods/lori/representation'
    self.root_path + "/representation"
  end

  #############
  # Nick Name for Paths
  #############

  def shortname
    self.module.split("Evaluations::")[1].downcase
  end

  def self.getShortnameFromName(name)
    Evmethod.find_by_name("LORI v1.5").shortname
  end

  def self.getNameFromShortname(shortname)
    Evmethod.getEvMethodFromShortname(shortname).name
  end

  def self.getEvMethodFromShortname(shortname)
    Evmethod.find_by_module("Evaluations::" + shortname.capitalize)
  end

  def getEvaluationModule
    self.module.constantize
  end

  #############
  # Utils
  #############

  def hasDocumentation
    lookup_context.template_exists?("documentation", "evmethods/"+self.shortname, true)
  end

  def hasRepresentation
    lookup_context.template_exists?("representation", "evmethods/"+self.shortname, true)
  end

end
