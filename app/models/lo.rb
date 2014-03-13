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
  :length => { :in => 3..255 },
  :uniqueness => {
    :case_sensitive => false
  }

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

  #XLSX management
  def getXLSXHeaders
    keys = self.attributes.keys
    keys.push("Keywords")

    Evmethod.all.each do |evmethod|
      keys.push("Assignments with " + evmethod.name)
      keys.push("Completed Assignments")
      keys.push("Pending Assignments")
      keys.push("Rejected Assignments")

      keys.push("Evaluations with " + evmethod.name)
      keys.push("Completed Evaluations with " + evmethod.name)

      itemsArray = evmethod.getEvaluationModule.getItemsArray
      itemsArray.each do |nItem|
        keys.push(evmethod.name + " item" + nItem.to_s)
      end
    end

    Metric.all.each do |metric|
      keys.push("Metric Score: " + metric.name)
    end

    keys
  end

  def getXLSXValues
    values = self.attributes.values
    values.push(self.tag_list.to_s)

    Evmethod.all.each do |evmethod|
      evMethodAssignments = self.assignments.where(:evmethod_id=>evmethod.id)
      values.push(evMethodAssignments.length)
      values.push(evMethodAssignments.where(:status => "Completed").length)
      values.push(evMethodAssignments.where(:status => "Pending").length)
      values.push(evMethodAssignments.where(:status => "Rejected").length)

      evMethodEvaluations = self.evaluations.where(:evmethod_id => evmethod.id)
      values.push(evMethodEvaluations.length)
      itemsArray = evmethod.getEvaluationModule.getItemsArray
      evMethodFullValidEvaluations = Evaluation.getValidEvaluationsForItems(evMethodEvaluations,itemsArray)
      values.push(evMethodFullValidEvaluations.length)

      if evmethod.getEvaluationModule.methods.include? :representationData
        representationData = evmethod.getEvaluationModule.representationData(self)
      end

      itemsArray.each_with_index do |nItem,index|
        if !representationData.nil?
          if !representationData["iScores"][index].nil?
            values.push(representationData["iScores"][index])
          else
            values.push("")
          end
        else
          values.push("")
        end
      end
    end

    Metric.all.each do |metric|
      score = self.scores.where(:metric_id => metric.id).first
      if !score.nil?
        values.push(score.value)
      else
        values.push("")
      end
    end

    values
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
