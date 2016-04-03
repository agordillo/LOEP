# encoding: utf-8

class Evaluations::Wbltt < Evaluation
  # this is for Evaluations with evMethod=WBLT-T (type=WblttEvaluation)
  #Override methods here

  def init
    self.evmethod_id ||= Evmethod.find_by_name("WBLT-T").id
    super
  end

  def self.getItems
    items = []
    11.times do |i|
      items << {
        :name => I18n.t("evmethods.Wbltt.item" + (i+1).to_s + ".name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item" + (i+1).to_s + ".shortname"),
        :type=> "integer"
      }
    end
    3.times do |i|
      items << {
        :name => I18n.t("evmethods.Wbltt.item" + (i+12).to_s + ".name") + ".",
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
    super
  end

  def self.representationDataForLos(los)
    super
  end

  def self.representationDataForComparingLos(los)
    super
  end

end