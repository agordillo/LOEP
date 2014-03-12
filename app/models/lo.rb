class Lo < ActiveRecord::Base
  attr_accessible :callback, :categories, :description, :name, :repository, :technology, :language_id, :lotype, :url, :scope, :hasText, :hasImages, :hasVideos, :hasAudios, :hasQuizzes, :hasWebs, :hasFlashObjects, :hasApplets, :hasDocuments, :hasFlashcards, :hasVirtualTours, :hasEnrichedVideos, :tag_list

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

  acts_as_taggable

  has_many :assignments, :dependent => :destroy
  has_many :users, through: :assignments
  has_many :evaluations, :dependent => :destroy
  belongs_to :language
  has_many :scores, :dependent => :destroy
  has_many :metrics, through: :scores
  has_many :evmethods, through: :evaluations

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
      !Evaluation.getValidEvaluationsForItems(self.evaluations.where(:evmethod_id => evmethod.id),evmethod.getEvaluationModule.getItemsArray).empty?
    end
  end

  def getScoreForMetric(metric)
    self.scores.where(:metric_id => metric.id).first
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
