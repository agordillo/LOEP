class Lo < ActiveRecord::Base
  attr_accessible :description, :name, :repository, :id_repository, :technology, :language_id, :lotype, :url, :scope, :hasText, :hasImages, :hasVideos, :hasAudios, :hasQuizzes, :hasWebs, :hasFlashObjects, :hasApplets, :hasDocuments, :hasFlashcards, :hasVirtualTours, :hasEnrichedVideos, :tag_list, :lom_profile_url

  acts_as_xlsx

  validates :url,
  :presence => true,
  :uniqueness => {
    :case_sensitive => false
  }

  validates :name,
  :presence => true,
  :length => { :in => 3..255 }

  validates :language_id, :presence => { :message => I18n.t("dictionary.errors.unspecified") }
  validates :language_id, :exclusion => { :in => [-1], :message => I18n.t("dictionary.errors.unspecified")}

  validates :lotype,
  :presence => true

  validates :technology,
  :presence => true

  validates :scope,
  :presence => true
  validates_inclusion_of :scope, :in => ["Private", "Protected", "Public"], :allow_nil => false, :message => ": " + I18n.t("dictionary.invalid")

  validates :owner_id, :presence => { :message => I18n.t("dictionary.errors.unspecified") }

  validate :checkRepositoryId

  def checkRepositoryId
    if self.id.nil? and !self.repository.blank? and !self.id_repository.blank?
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
  has_one :lom

  after_save :save_lom_profile

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
    if evmethod.nil?
      false
    else
      # This method requires a single evaluation to rate all the EvMethod numeric items of the LO to considere it as evaluated
      #We consider that a LO has been evaluated with a evmethod, if for each numeric item of the method, exists at least one evaluation that rate it with a valid score.
      evMethodEvaluations = self.evaluations.where(:evmethod_id => evmethod.id)
      evmethod.getEvaluationModule.getItemsWithType("integer").each_with_index do |item,index|
        if Evaluation.getValidEvaluationsForItem(evMethodEvaluations,index+1).empty?
          return false
        end
      end
      return true
    end
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

  def metadata
    self.lom.metadata unless self.lom.nil?
  end

  def update_lom_profile
    if self.lom.nil?
      lom = Lom.new
      lom.lo_id = self.id
    else
      lom = self.lom
    end
    
    unless self.lom_profile_url.blank?
      #Generate LOM profile from url
      lom.populate_from_url(self.lom_profile_url)
    else
      lom.populate_from_lo
    end

    lom.save
  end


  #######################
  # Get extended LO Data
  #######################

  def extended_attributes
    attrs = self.attributes
    attrs["keywords"] = self.tag_list.to_s
    attrs["language"] = self.language.translated_name

    attrs["created_at"] = Utils.getReadableDate(attrs["created_at"])
    attrs["updated_at"] = Utils.getReadableDate(attrs["updated_at"])

    Evmethod.allc.each do |evmethod|
      evMethodAssignments = self.assignments.where(:evmethod_id=>evmethod.id)

      attrs["Assignments with " + evmethod.name] = evMethodAssignments.length
      attrs["Completed assignments with " + evmethod.name] = evMethodAssignments.where(:status => "Completed").length
      attrs["Pending assignments with " + evmethod.name] = evMethodAssignments.where(:status => "Pending").length
      attrs["Rejected assignments with " + evmethod.name] = evMethodAssignments.where(:status => "Rejected").length

      evMethodEvaluations = self.evaluations.where(:evmethod_id => evmethod.id)
      attrs["Evaluations with " + evmethod.name] = evMethodEvaluations.length
      itemsArray = evmethod.getEvaluationModule.getItemsArray
      evMethodFullValidEvaluations = Evaluation.getValidEvaluationsForItems(evMethodEvaluations,itemsArray)
      attrs["Completed Evaluations with " + evmethod.name] = evMethodFullValidEvaluations.length

      if evmethod.getEvaluationModule.methods.include? :representationData
        representationData = evmethod.getEvaluationModule.representationData(self)
      end

      itemsArray.each_with_index do |nItem,index|
        attrKey = evmethod.name + " item" + nItem.to_s

        if !representationData.nil?
          if !representationData["iScores"][index].nil?
            attrs[attrKey] = representationData["iScores"][index]
          else
            attrs[attrKey] = ""
          end
        else
          attrs[attrKey] = ""
        end
      end
    end

    Metric.allc.each do |metric|
      attrKey = "Metric Score: " + metric.name

      score = self.scores.where(:metric_id => metric.id).first
      if !score.nil?
        attrs[attrKey] = score.value.to_f
      else
        attrs[attrKey] = ""
      end
    end

   attrs
  end


  ##############
  # Evaluation Data
  #############

  #Return the evaluations and average item values, grouped by evaluation methods.
  def getEvaluationData(evmethods=nil)
    evData = Hash.new

    if evmethods.nil?
      loEvmethods = self.evmethods.uniq
    else
      unless evmethods.is_a? Array
        evmethods = [evmethods]
      end
      loEvmethods = evmethods
    end

    loEvmethods.each do |evmethod|
      evData[evmethod.name] = Hash.new
      evData[evmethod.name][:evaluations] = self.evaluations.where(:evmethod_id => evmethod.id)
      evData[evmethod.name][:items] = [] #itemsAverageValue

      nItems = evmethod.module.constantize.getItemsWithType("integer").length

      if evData[evmethod.name][:evaluations].length === 0
        nItems.times do |i|
          evData[evmethod.name][:items].push(nil)
        end
        next
      end

      nItems.times do |i|
        validEvaluations = Evaluation.getValidEvaluationsForItem(evData[evmethod.name][:evaluations],i+1)
        if validEvaluations.length == 0
          #Means that this item has not been evaluated in any evaluation
          #All evaluations had leave this item in blank
          iScore = nil
        else
          iScore = validEvaluations.average("item"+(i+1).to_s).to_f
        end
        evData[evmethod.name][:items].push(iScore)
      end
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


  private

  def save_lom_profile
    self.update_lom_profile
  end

end