class Lo < ActiveRecord::Base
  attr_accessible :description, :name, :repository, :id_repository, :app_id, :technology, :language_id, :lotype, :url, :scope, :hasText, :hasImages, :hasVideos, :hasAudios, :hasQuizzes, :hasWebs, :hasFlashObjects, :hasApplets, :hasDocuments, :hasFlashcards, :hasVirtualTours, :hasEnrichedVideos, :tag_list, :metadata_url, :interactions
  attr_accessor :interactions

  acts_as_xlsx if ActiveRecord::Base.connection.table_exists? "los"

  before_validation :fill_values

  validates :url, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :name, :presence => true, :length => { :in => 1..255 }
  validates :language_id, :presence => { :message => I18n.t("dictionary.errors.unspecified") }
  validates :language_id, :exclusion => { :in => [-1], :message => I18n.t("dictionary.errors.unspecified")}
  validates :lotype, :presence => true
  validates :technology, :presence => true
  validates :scope, :presence => true
  validates_inclusion_of :scope, :in => ["Private", "Protected", "Public"], :allow_nil => false, :message => ": " + I18n.t("dictionary.invalid")
  validates :owner_id, :presence => { :message => I18n.t("dictionary.errors.unspecified") }
  validate :checkRepositoryId
  def checkRepositoryId
    if self.new_record? and !self.repository.blank? and !self.id_repository.blank?
      #Create a new LO with repository and repository ID
      #Check if the ID is uniq for this repository
      if Lo.where(:repository => self.repository, :id_repository => self.id_repository).length > 0
        errors.add(:repository, I18n.t("los.message.error.repository_id"))
        return
      end
    end
    true
  end

  acts_as_taggable

  has_many :assignments, :dependent => :destroy
  has_many :users, through: :assignments
  has_many :evaluations, :dependent => :destroy
  belongs_to :language
  has_many :scores, :dependent => :destroy
  has_many :metrics, through: :scores
  has_many :evmethods, through: :evaluations
  belongs_to :app
  has_one :metadata, :dependent => :destroy
  has_one :lo_interaction, :dependent => :destroy

  after_save :save_metadata
  after_save :save_interactions
  after_save :calculate_automatic_scores

  #---------------------------------------------------------------------------------

  #Extra Attrs

  #Get Users with assignments for evaluate this LO
  def assignedReviewers
    self.users.uniq
  end

  def pendingAssignedReviewers
    self.assignments.where(:status=>"Pending").map{|as| as.user}.uniq
  end

  #Get Users that evaluate this LO
  def reviewers
    self.evaluations.map{ |ev| ev.user }.uniq
  end

  #Get Users that evaluate the LO or habe an assignment for evaluate it
  def allUsers
    (assignedReviewers+reviewers).uniq
  end

  #Get the owner of the LO
  def owner
    if self.app.nil?
      unless self.owner_id.nil?
        User.find(self.owner_id)
      end
    else
      self.app.user
    end
  end 

  #Get the evMethods that have been used to score this LO
  def getScoreEvmethods
    scoreEvmethods = []
    self.scoresc.map{|s| s.metric}.uniq.map{|m| m.evmethods.map{|ev| scoreEvmethods.push(ev)}}
    scoreEvmethods.uniq
  end

  #Get the evMethods that have been used to evaluate this LO
  def getEvaluationEvmethods
    self.evmethods.uniq
  end

  #Get the evMethods that have been used to evaluate or score this LO
  def getAllEvmethods
    (getScoreEvmethods+getEvaluationEvmethods).uniq
  end

  #Extra Getters
  def getLanguages
    unless self.languages.empty?
      self.languages.map { |l| l.id }
    end
  end

  def hasBeenEvaluatedWithMetric(metric)
    !getScoreForMetric(metric).nil?
  end

  def hasBeenEvaluatedWithEvmethod(evmethod)
    return false if evmethod.nil?
    return evmethod.module.constantize.hasEvaluatedLo(self) if evmethod.module.constantize.respond_to?("hasEvaluatedLo")

    #By default, LOEP consider that a LO has been evaluated with a evmethod, if for each numeric item of the method, exists at least one evaluation that rate it with a valid score.
    #This default behaviour can be customized by defining a custom hasEvaluatedLo method in the corresponding module.
    evMethodEvaluations = self.evaluations.where(:evmethod_id => evmethod.id)
    evmethod.getEvaluationModule.getItemsArray("numeric").each do |itemName|
      return false if Evaluation.getValidEvaluationsForItem(evMethodEvaluations,itemName).empty?
    end
    return true
  end

  def hasBeenEvaluatedWithEvmethods(evmethods)
    return false if evmethods.blank?
    evmethods.each do |evmethod|
      return false if self.hasBeenEvaluatedWithEvmethod(evmethod)!=true
    end
    return true
  end

  def getScoreForMetric(metric)
    self.scores.where(:metric_id => metric.id).first
  end

  #Get scores filtering the ones from disabled Metrics
  def scoresc
    self.scores.where("metric_id in (?)", Metric.allc.map{|m| m.id})
  end

  def readable_scope
    I18n.t("scopes."+self.scope.downcase) unless self.scope.nil?
  end

  def readable_lotype
    I18n.t("los.types." + self.lotype) unless self.lotype.nil?
  end

  def readable_technology_or_format
    I18n.t("los.technology_or_format." + self.technology) unless self.technology.nil?
  end

  def update_metadata
    if self.metadata.nil?
      metadata = Metadata.new
      metadata.lo_id = self.id
    else
      metadata = self.metadata
    end
    metadata.update
  end

  def getMetadata(options={})
    metadata = Metadata.find_by_lo_id(self.id)
    options = {:format => "json", :schema => Metadata::Lom.schema }.merge(options)
    if metadata.nil?
      case options[:format]
      when "json"
        return {}
      when "xml"
        return Metadata.getEmptyXml
      else
        return nil
      end
    else
      return metadata.getMetadata(options)
    end
  end

  def update_interactions
    return if self.interactions.nil?
    LoInteraction.createWithHash(self,self.interactions)
  end

  def getInteraction
    LoInteraction.find_by_lo_id(self.id)
  end

  #######################
  # Get extended LO Data
  #######################

  def extended_attributes(xlsx_attributes=false)
    attrs = self.attributes
    attrs["tag_list"] = self.tag_list.to_s
    attrs["lanCode"] = self.language.code
    attrs["interactions"] = self.lo_interaction.extended_attributes unless self.lo_interaction.nil? or xlsx_attributes

    attrs["created_at"] = Utils.getReadableDate(attrs["created_at"])
    attrs["updated_at"] = Utils.getReadableDate(attrs["updated_at"])

    evData = self.getEvaluationData

    Evmethod.allc.each do |evmethod|
      evMethodAssignments = self.assignments.where(:evmethod_id=>evmethod.id)

      attrs["Assignments with " + evmethod.name] = evMethodAssignments.length
      attrs["Completed assignments with " + evmethod.name] = evMethodAssignments.where(:status => "Completed").length
      attrs["Pending assignments with " + evmethod.name] = evMethodAssignments.where(:status => "Pending").length
      attrs["Rejected assignments with " + evmethod.name] = evMethodAssignments.where(:status => "Rejected").length

      evMethodEvaluations = self.evaluations.where(:evmethod_id => evmethod.id)
      attrs["Evaluations with " + evmethod.name] = evMethodEvaluations.length
      itemsArray = evmethod.getEvaluationModule.getItemsArray("numeric")
      tItemsArray = evmethod.getEvaluationModule.getItemsArray("textual")
      mandatoryItemsArray = evmethod.getEvaluationModule.getItemsArray("numeric")
      evMethodFullValidEvaluations = Evaluation.getValidEvaluationsForItems(evMethodEvaluations,mandatoryItemsArray)
      attrs["Completed Evaluations with " + evmethod.name] = evMethodFullValidEvaluations.length

      evData = {} if evData.blank? 
      evData[evmethod.name] = {} if evData[evmethod.name].blank?
      
      #Numeric Items
      evDataItems = []
      evDataItems = evData[evmethod.name][:items] unless evData[evmethod.name][:items].blank?
      itemsArray.each_with_index do |itemName,index|
        attrKey = evmethod.name + " " + itemName.to_s
        unless evDataItems[index].blank?
          attrs[attrKey] = evDataItems[index].to_f.round(2)
        else
          attrs[attrKey] = ""
        end
      end

      #Textual Items
      evDataTitems = {}
      evDataTitems = evData[evmethod.name][:titems] unless evData[evmethod.name][:titems].blank?
      tItemsArray.each do |itemName|
        attrKey = evmethod.name + " " + itemName.to_s
        unless evDataTitems[itemName].blank?
          attrs[attrKey] = evDataTitems[itemName]
        else
          attrs[attrKey] = ""
        end
      end

      #Comments
      attrCommentsKey = evmethod.name + " comments"
      unless evData[evmethod.name][:comments].blank?
        attrs[attrCommentsKey] = evData[evmethod.name][:comments]
      else
        attrs[attrCommentsKey] = ""
      end
    end

    Metric.allc.each do |metric|
      attrKey = "Metric Score: " + metric.name

      score = self.scores.where(:metric_id => metric.id).first
      if !score.nil?
        attrs[attrKey] = score.value.to_f.to_f.round(2)
      else
        attrs[attrKey] = ""
      end
    end

    attrs
  end

  def xlsx_attributes
    attrs = self.extended_attributes(true)
    unless self.lo_interaction.nil?
      attrs["interactions [nsamples]"] = self.lo_interaction.nsamples unless self.lo_interaction.nsamples.blank?
      attrs["interactions [nsignificativesamples]"] = self.lo_interaction.nsignificativesamples unless self.lo_interaction.nsignificativesamples.blank?
      unless self.lo_interaction.lo_interaction_fields.blank?
        self.lo_interaction.lo_interaction_fields.map{|f| f}.each do |f|
          attrs["interactions [" + f.name + "]"] = f.average_value.round(2)
        end
      end
    end
    attrs
  end


  ##############
  # Evaluation Data
  #############

  #Return the evaluations and average item values, grouped by evaluation models.
  def getEvaluationData(evmethods=nil)
    evData = Hash.new

    if evmethods.nil?
      loEvmethods = (self.evmethods.uniq & Evmethod.allc)
    else
      evmethods = [evmethods] unless evmethods.is_a? Array
      loEvmethods = evmethods
    end

    loEvmethods.each do |evmethod|
      evData[evmethod.name] = Hash.new
      evData[evmethod.name][:evaluations] = self.evaluations.where(:evmethod_id => evmethod.id)
      evData[evmethod.name][:items] = [] #Average value of numeric items
      evData[evmethod.name][:titems] = {} #Hash with array of values of textual items
      evData[evmethod.name][:comments] = [] #Array with comments

      #Numeric Items
      items = evmethod.module.constantize.getItemsArray("numeric")
      nItems = items.length
      if evData[evmethod.name][:evaluations].length === 0
        nItems.times do |i|
          evData[evmethod.name][:items].push(nil)
        end
      else
        items.each do |itemName|
          validEvaluations = Evaluation.getValidEvaluationsForItem(evData[evmethod.name][:evaluations],itemName)
          if validEvaluations.length == 0
            #Means that this item has not been evaluated in any evaluation
            #All evaluations left this item blank
            iScore = nil
          else
            iScores = validEvaluations.map{|e| e.send("#{itemName}")}
            iScore = (iScores.sum/iScores.size.to_f).round(2)
          end
          evData[evmethod.name][:items].push(iScore)
        end
      end

      #Textual Items
      tItems = evmethod.module.constantize.getItemsArray("textual")
      tItems.each do |itemName|
        validEvaluations = Evaluation.getValidEvaluationsForItem(evData[evmethod.name][:evaluations],itemName)
        if validEvaluations.blank?
          evData[evmethod.name][:titems][itemName] = []
        else
          evData[evmethod.name][:titems][itemName] = validEvaluations.map{|e| e.send(itemName)}
        end
      end

      #Comments
      evaluationsWithComments = Evaluation.getValidEvaluationsForItem(evData[evmethod.name][:evaluations],"comments")
      evData[evmethod.name][:comments] = evaluationsWithComments.map{|e| e.comments} unless evaluationsWithComments.blank?
    end

    evData
  end


  #Class Methods

  def self.orderByScore(los,metric)
    metric = metric || Metric.first
    los.sort! { |a, b|
      scoreA = a.scores.where(:metric_id => metric.id).first
      scoreB = b.scores.where(:metric_id => metric.id).first

      scoreA = (scoreA.nil? ? nil : scoreA.value)
      scoreB = (scoreB.nil? ? nil : scoreB.value)

      if scoreA.nil? and scoreB.nil?
        0
      elsif scoreA.nil?
        +1
      elsif scoreB.nil?
        -1
      else
        scoreB <=> scoreA
      end
    }
    los
  end

  def self.Public
    Lo.where("los.scope!='private'")
  end

  def self.evaluatedWithEvmethods(evmethods=[])
    evmethods = [evmethods] unless evmethods.is_a? ActiveRecord::Relation or evmethods.is_a? Array
    evmethods = evmethods & Evmethod.allc
    los = Evaluation.where("evaluations.evmethod_id in (?)", evmethods).map{|ev| ev.lo}.uniq
    los.select{ |lo|
      lo.hasBeenEvaluatedWithEvmethods(evmethods)
    }
  end


  private

  def fill_values
    self.repository = nil if self.repository.blank?
    self.scope = "Private" unless !self.scope.blank? and ["Private", "Protected", "Public"].include? self.scope
    self.lotype = "unspecified" unless !self.lotype.blank? and I18n.t("los.types").map{|k,v| k.to_s}.include? self.lotype
    self.technology = "unspecified" unless !self.technology.blank? and I18n.t("los.technology_or_format").map{|k,v| k.to_s}.include? self.technology
  end

  def save_metadata
    self.update_metadata
  end

  def save_interactions
    self.update_interactions
  end

  def calculate_automatic_scores
    Evmethod.allc_automatic.each do |evmethod|
      evmethod.getEvaluationModule.createAutomaticEvaluation(self)
    end
  end

end