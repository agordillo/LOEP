class Metric < ActiveRecord::Base
  attr_accessible :name

  validates :name,
  :presence => true,
  :uniqueness => {
    :case_sensitive => false
  }

  validates :type,
  :presence => true,
  :uniqueness => {
    :case_sensitive => true
  }

  validate :evmethods_blank

  def evmethods_blank
    if self.evmethods.blank?
      errors.add(:evmethods, 'A metric should have at least one evaluation method.')
    else
      true
    end
  end

  has_many :scores, :dependent => :destroy
  has_and_belongs_to_many :evmethods
  
  def self.allc
    Metric.where("type in (?)",LOEP::Application.config.metrics.map{|m| m.class.name})
  end

  def self.getInstance
    Metric.find_by_type(self.name)
  end

  def self.getEvmethods
    instance = getInstance
    unless instance.nil?
      instance.evmethods
    else
      []
    end
  end

  ################################
  # Method for metrics to inherit
  ################################

  def getScoreForLos(los)
    scores = Hash.new
    los.each do |lo|
      scores[lo.id.to_s] = getScoreForLo(lo)
    end
    scores
  end

  def getScoreForLo(lo)
    getScoreForEvData(lo.getEvaluationData)
  end

  #This score only makes sense for metrics that only rely on one evmethod.
  def getScoreForEvaluation(evaluation)
    getScoreForEvData(evaluation.getEvaluationData)
  end

  def getScoreForEvData(evData)
    if self.evmethods.length == 1
      #Metric with only one Evmethod.
      itemAverageValues = evData.values.first[:items]
      if itemAverageValues.blank? or itemAverageValues.include? nil
        return nil
      end
    end

    loScore = self.class.getLoScore(evData)

    unless loScore.nil?
      loScore = ([[loScore,0].max,10].min).round(2)
    end

    return loScore
  end

  def self.itemWeights
    evmethods = getEvmethods
    itemWeights = []
    unless evmethods.blank?
      itemsLength = evmethods.map{|ev| ev.module.constantize.getItems.length}.sum
      itemWeight = 1/itemsLength.to_f
      itemsLength.times do |i|
        itemWeights.push(BigDecimal(itemWeight,6));
      end
    end
    itemWeights
  end

  ################################
  # Method for metrics to implement and override
  ################################

  def self.getLoScore(evData,evaluations=nil)
    #Override me
  end

end
