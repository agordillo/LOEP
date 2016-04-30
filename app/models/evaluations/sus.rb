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


  #############
  # Representation Data
  #############
  
  def self.representationData(lo,metric=nil)
    evmethod = Evmethod.find_by_module(self.name)
    metric = Metric.find_by_name("Global SUS Score") if metric.nil?
    metric = Metric.allc.select{|m| m.evmethods == [evmethod]}.first  if metric.nil?
    return if metric.nil?

    loSUSscore = lo.scores.find_by_metric_id(metric.id)
    return if loSUSscore.nil?

    representationData = Hash.new
    representationData["name"] = lo.name
    representationData["averageScore"] = loSUSscore.value.to_f.round(2)
    representationData["iScores"] = [representationData["averageScore"]]
    representationData["labels"] = [I18n.t("evmethods.SUS.score.name")]
    representationData["engine"] = "Rgraph"
    representationData
  end

end