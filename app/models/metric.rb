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
    evaluations = lo.evaluations.where(:evmethod_id => self.evmethods.map{|ev| ev.id})

    if evaluations.length === 0
      return nil
    end

    self.class.getScoreForEvaluations(evaluations)
  end

  def self.getScoreForEvaluation(evaluation)
    self.class.getScoreForEvaluations([evaluation])
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
