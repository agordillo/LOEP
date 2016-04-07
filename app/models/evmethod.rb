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
    metric = Metric.allc.select{|m| m.evmethods == [self]}.first if metric.nil?

    evData = lo.getEvaluationData(self)[self.name]

    iScores = evData[:items]
    return nil if iScores.blank? or iScores.include? nil

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
    evModule = self.module.constantize

    graphEngine = nil
    labels = []
    iScores =  []
    
    los.each do |lo|
      rpdLo = evModule.representationData(lo)
      break if rpdLo.nil?
      graphEngine = rpdLo["engine"] if graphEngine.blank? and !rpdLo["engine"].blank?
      labels = rpdLo["labels"] if labels.blank? and !rpdLo["labels"].blank?
      iScoresLo = rpdLo["iScores"]
      unless iScoresLo.nil?
        iScoresLo.length.times do |i|
          iScores[i] = (iScores[i].nil? ? 0 : iScores[i]) + iScoresLo[i]  unless iScoresLo[i].nil?
        end
      end
    end

    graphEngine ||= "Rgraph"
    #All LOs need to have evaluation data for being represented
    return nil if labels.blank? or iScores.blank?

    #Average scores
    losL = los.length
    iScores.length.times do |i|
      iScores[i] = (iScores[i]/losL).round(2) unless iScores[i].nil?
    end

    representationData = Hash.new
    representationData["iScores"] = iScores
    representationData["averageScore"] = (representationData["iScores"].sum/representationData["iScores"].size.to_f).round(2)
    representationData["labels"] = labels
    representationData["engine"] = graphEngine unless graphEngine.nil?
    representationData
  end

  def representationDataForComparingLos(los)
    return if los.blank?
    
    representationData = Hash.new
    evModule = self.module.constantize

    los.each do |lo|
      rpdLo = evModule.representationData(lo)
      representationData[lo.id] = rpdLo unless rpdLo.nil? or rpdLo["iScores"].blank? or rpdLo["iScores"].include? nil
    end

    return nil if representationData.length < 2

    representationData["labels"] = representationData.values.first["labels"]
    representationData["engine"] = representationData.values.first["engine"] unless representationData.values.first["engine"].blank?
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
    Evmethod.find_by_name(name).shortname
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
