# encoding: utf-8

class Evaluations::Star < Evaluation
  # this is for Evaluations with evMethod=Star (type=StarEvaluation)

  def init
    self.evmethod_id ||= Evmethod.find_by_name("Star").id
    super
  end

  def self.getItems
    [
      {
        :name => "Rating",
        :type=> "integer"
      }
    ]
  end

  def self.getScale
    return [1,5]
  end

  def self.getFormOptions
    {
      contexts: false,
      comments: false,
      global_score: false,
      :scaleLegend => {
        :min => "1", 
        :max => "5"
      }
    }
  end

end