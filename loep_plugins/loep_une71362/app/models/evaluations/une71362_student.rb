# encoding: utf-8

class Evaluations::Une71362Student < Evaluation
  # this is for Evaluations with evMethod=UNE 71362 - Student (type=Une71362StudentEvaluation)

  def init
    self.evmethod_id ||= Evmethod.find_by_name("UNE 71362 - Student").id
    super
  end

  def self.getItems
    [
      {
        :name => "Item1",
        :type=> "integer"
      },{
        :name => "Item2",
        :type=> "integer"
      }
    ]
  end

  def self.getScale
    return [1,5]
  end

end