class Evaluations::Sus < Evaluation
  # this is for Evaluations with evMethod=SUS (type=SusEvaluation)

  def init
    self.evmethod_id ||= Evmethod.find_by_name("SUS").id
    super
  end

  def self.getItems
    items = []
    10.times do |i|
      items << {
        :name => I18n.t("evmethods.SUS.item" + (i+1).to_s + ".name", :system => I18n.t("los.name.one").downcase) + ".",
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
        :min => I18n.t("forms.evmethod.low_likert"), 
        :max => I18n.t("forms.evmethod.high_likert")
      }
    }
  end

end