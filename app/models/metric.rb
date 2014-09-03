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

  def getScoreForLo(lo, evaluation=nil)
    evmethodsData = Hash.new

    if evaluation.nil?
      evmethods = self.evmethods
    else
      evmethods = [evaluation.evmethod]
    end

    evmethods.each do |evmethod|
      evmethodsData[evmethod.name] = Hash.new
      if evaluation.nil?
        evmethodsData[evmethod.name][:evaluations] = lo.evaluations.where(:evmethod_id => evmethod.id)
      else
        evmethodsData[evmethod.name][:evaluations] = lo.evaluations.where(:id => evaluation.id)
      end
      evmethodsData[evmethod.name][:items] = [] #itemsAverageValue

      nItems = evmethod.module.constantize.getItems.length

      if evmethodsData[evmethod.name][:evaluations].length === 0
        nItems.times do |i|
          evmethodsData[evmethod.name][:items].push(nil)
        end
        next
      end

      nItems.times do |i|
        validEvaluations = Evaluation.getValidEvaluationsForItem(evmethodsData[evmethod.name][:evaluations],i+1)
        if validEvaluations.length == 0
          #Means that this item has not been evaluated in any evaluation
          #All evaluations had leave this item in blank
          iScore = nil
        else
          iScore = validEvaluations.average("item"+(i+1).to_s).to_f
        end
        evmethodsData[evmethod.name][:items].push(iScore)
      end
    end

    if self.evmethods.length == 1
      #Metric with only one Evmethod. Keep it simple.
      itemAverageValues = evmethodsData.values[0][:items]
      if itemAverageValues.blank? or itemAverageValues.include? nil
        return nil
      end
      loScore = self.class.getLoScore(itemAverageValues,evmethodsData.values[0][:evaluations])
    else
      loScore = self.class.getLoScore(evmethodsData)
    end

    unless loScore.nil?
      loScore = ([[loScore,0].max,10].min).round(2)
    end

    return loScore
  end

  #This score only makes sense for metrics that only rely on one evmethod.
  def getScoreForEvaluation(evaluation)
    getScoreForLo(evaluation.lo,evaluation)
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

end
