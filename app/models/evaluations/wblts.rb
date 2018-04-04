# encoding: utf-8

class Evaluations::Wblts < Evaluation
  # this is for Evaluations with evMethod=WBLT-S (type=WbltsEvaluation)
  #Override methods here

  def init
    self.evmethod_id ||= Evmethod.find_by_name("WBLT-S").id
    super
  end

  def self.getItems
    items = []
    13.times do |i|
      items << {
        :name => I18n.t("evmethods.wblts.item" + (i+1).to_s + ".name") + ".",
        :shortname => I18n.t("evmethods.wblts.item" + (i+1).to_s + ".shortname"),
        :type=> "integer"
      }
    end
    2.times do |i|
      items << {
        :name => I18n.t("evmethods.wblts.item" + (i+14).to_s + ".name"),
        :type=> "text"
      }
    end
    items
  end

  def self.getScale
    return [1,7]
  end


  #############
  # Representation Data
  #############

  def self.representationData(lo)
    super(lo,Metric.find_by_type("Metrics::WBLTSAM"))
  end

end