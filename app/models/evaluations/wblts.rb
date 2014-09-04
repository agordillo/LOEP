# encoding: utf-8

class Evaluations::Wblts < Evaluation
  # this is for Evaluations with evMethod=WBLT-S (type=WbltsEvaluation)
  #Override methods here

  def init
    self.evmethod_id ||= Evmethod.find_by_name("WBLT-S").id
    super
  end

  def self.getItems
    [
      {:name => "The learning object was well organized.",
        :type=> "integer"},
      {:name => "The learning object was easy to use.",
        :type=> "integer"},
      {:name => "The instructions in the learning object were easy to follow.",
        :type=> "integer"},
      {:name => "The help features of the learning object were useful.",
        :type=> "integer"},
      {:name => "Working with the learning object helped me learn.",
        :type=> "integer"},
      {:name => "The feedback from the learning object helped me learn.",
        :type=> "integer"},
      {:name => "The graphics and animations from the learning object helped me learn.",
        :type=> "integer"},
      {:name => "The learning object helped teach me a new concept.",
        :type=> "integer"},
      {:name => "Overall, the learning object helped me learn.",
        :type=> "integer"},
      {:name => "I like the overall theme of the learning object.",
        :type=> "integer"},
      {:name => "I found the learning object to be engaging.",
        :type=> "integer"},
      {:name => "The learning object made learning fun.",
        :type=> "integer"},
      {:name => "I would like to use learning objects like this again.",
        :type=> "integer"},
      {:name => "What (if anything) did you LIKE about using the learning object?",
        :type=> "text"},
      {:name => "What (if anything) did you NOT LIKE about using the learning object?",
        :type=> "text"},
    ]
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