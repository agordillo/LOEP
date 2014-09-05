# encoding: utf-8

class Evaluations::Wbltt < Evaluation
  # this is for Evaluations with evMethod=WBLT-T (type=WblttEvaluation)
  #Override methods here

  def init
    self.evmethod_id ||= Evmethod.find_by_name("WBLT-T").id
    super
  end

  def self.getItems
    [
      {:name => "The learning object was easy for me to use.",
        :shortname => "Usability for teachers",
        :type=> "integer"},
      {:name => "The learning object was easy for students to use.",
        :shortname => "Usability for students",
        :type=> "integer"},
      {:name => "The students found the learning object instructions clear.",
        :shortname => "Instructions",
        :type=> "integer"},
      {:name => "The graphics and animations from the learning object helped students learn.",
        :shortname => "Graphics",
        :type=> "integer"},
      {:name => "The learning object enhanced student learning.",
        :shortname => "Learning",
        :type=> "integer"},
      {:name => "The learning object helped clarify the concept(s) being taught.",
        :shortname => "Help at clarifying concepts",
        :type=> "integer"},
      {:name => "Overall, it was beneficial to us the learning object for teaching.",
        :shortname => "Teaching",
        :type=> "integer"},
      {:name => "The students were on task or focused when the learning objects was being used.",
        :shortname => "Ability to keep students focused",
        :type=> "integer"},
      {:name => "The students liked the interactive quality of the learning object.",
        :shortname => "Interactivity",
        :type=> "integer"},
      {:name => "The students appeared to like the learning object.",
        :shortname => "Students opinion",
        :type=> "integer"},
      {:name => "Overall, the students were engaged when the learning object was being used.",
        :shortname => "Engagement",
        :type=> "integer"},
      {:name => "What was the overall impact of the learning object on your teaching?",
        :type=> "text"},
      {:name => "Were there any technology-based problems that you encountered while using your learning object? Please explain.",
        :type=> "text"},
      {:name => "What advice would you give to future teachers about using this learning object in their lessons?",
        :type=> "text"}
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