class Lo < ActiveRecord::Base
  attr_accessible :categories, :description, :name, :repository, :technology, :language_id, :lotype, :url, :scope, :hasText, :hasImages, :hasVideos, :hasAudios, :hasQuizzes, :hasWebs, :hasFlashObjects, :hasApplets, :hasDocuments, :hasFlashcards, :hasVirtualTours, :hasEnrichedVideos, :tag_list

  acts_as_xlsx
  
  validates :url,
  :presence => true,
  :uniqueness => {
    :case_sensitive => false
  }

  validates :name,
  :presence => true,
  :length => { :in => 3..255 }

  validates :language_id, :presence => { :message => "has to be specified" }
  validates :language_id, :exclusion => { :in => [-1], :message => "has to be specified."}

  validates :lotype,
  :presence => true,
  :exclusion => { in: "Unspecified", message: "has to be specified" }

  validates :technology,
  :presence => true,
  :exclusion => { in: "Unspecified", message: "has to be specified" }

  validates :scope,
  :presence => true
  validates_inclusion_of :scope, :in => ["Private", "Protected", "Public"], :allow_nil => false, :message => ": Invalid scope value"

  validates :owner_id, :presence => { :message => "has to be specified" }

  validate :checkRepositoryId

  def checkRepositoryId
    if self.id.nil? and !self.repository.blank? and !self.id_repository.blank?
      #Create a new LO with repository and repository ID
      #Check if the ID is uniq for this repository
      if Lo.where(:repository => self.repository, :id_repository => self.id_repository).length > 0
        errors.add(:repository, 'If the repository identifier is included, it must be unique')
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
    self.scores.map{|s| s.metric}.uniq.map{|m| m.evmethods.map{|ev| scoreEvmethods.push(ev)}}
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

  def getCategories
  	unless self.categories.nil?
  		begin
  			JSON(self.categories)
  		rescue
  			[]
  		end
  	end
  end

  def hasBeenEvaluatedWithMetric(metric)
    !getScoreForMetric(metric).nil?
  end

  def hasBeenEvaluatedWithEvmethod(evmethod)
    if evmethod.nil?
      false
    else
      # This method requires a single evaluation to rate all the LORI items of the LO to considere it as evaluated
      # !Evaluation.getValidEvaluationsForItems(self.evaluations.where(:evmethod_id => evmethod.id),evmethod.getEvaluationModule.getItemsArray).empty?
    
      #We consider that a LO has been evaluated with a evmethod, if for each item of the method, exists at least one evaluation that rate it with a valid score.
      evMethodEvaluations = self.evaluations.where(:evmethod_id => evmethod.id)
      evmethod.getEvaluationModule.getItemsArray.each do |nItem|
        if Evaluation.getValidEvaluationsForItem(evMethodEvaluations,nItem).empty?
          return false
        end
      end
      return true
      
    end
  end

  def getScoreForMetric(metric)
    self.scores.where(:metric_id => metric.id).first
  end


  #######################
  # Get extended LO Data
  #######################

  def extended_attributes
    attrs = self.attributes
    attrs["keywords"] = self.tag_list.to_s

    Evmethod.all.each do |evmethod|
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

    Metric.all.each do |metric|
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

end
