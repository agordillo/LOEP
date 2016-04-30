# encoding: utf-8

class Evaluations::Lori < Evaluation
  # this is for Evaluations with evMethod=LORI (type=LoriEvaluation)
  #Override methods here

  def init
    self.evmethod_id ||= Evmethod.find_by_name("LORI v1.5").id
    super
  end

  def self.getItems
    items = []
    9.times do |i|
      items << {
        :name => I18n.t("evmethods.lori.item" + (i+1).to_s + ".name"),
        :description => I18n.t("evmethods.lori.item" + (i+1).to_s + ".description"),
        :type=> "integer"
      }
    end
    items
  end

  def self.getScale
    return [1,5]
  end

  def self.getFormOptions
    {
      :scaleLegend => {
        :min => I18n.t("forms.evmethod.low"), 
        :max => I18n.t("forms.evmethod.high")
      },
      :explicitSkipAnswer => {
        :title => I18n.t("forms.evmethod.na")
      }
    }
  end


  #############
  # Representation Data
  #############

  def self.representationData(lo)
    super(lo,Metric.find_by_type("Metrics::LORIAM"))
  end

end