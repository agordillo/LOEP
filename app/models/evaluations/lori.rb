# encoding: utf-8

class Evaluations::Lori < Evaluation
  # this is for Evaluations with evMethod=LORI (type=LoriEvaluation)
  #Override methods here

  def init
    self.evmethod_id ||= Evmethod.find_by_name("LORI v1.5").id
    super
  end

  def self.getItems
    [
      {:name => "Content Quality",
         :description => "Veracity, accuracy, balanced presentation of ideas, and appropriate level of detail", 
         :type=> "integer"},
      {:name => "Learning Goal Alignment",
        :description => "Alignment among learning goals, activities, assessments, and learner characteristics",
        :type=> "integer"},
      {:name => "Feedback and Adaptation",
        :description => "Adaptive content or feedback driven by differential learner input or learner modeling",
        :type=> "integer"},
      {:name => "Motivation",
        :description => "Ability to motivate and interest an identified population of learners",
        :type=> "integer"},
      {:name => "Presentation Design",
        :description => "Design of visual and auditory information for enhanced learning and efficient mental processing",
        :type=> "integer"},
      {:name => "Interaction Usability",
        :description => "Ease of navigation, predictability of the user interface, and quality of the interface help features",
        :type=> "integer"},
      {:name => "Accessibility",
        :description => "Design of controls and presentation formats to accommodate disabled and mobile learners",
        :type=> "integer"},
      {:name => "Reusability",
        :description => "Ability to use in varying learning contexts and with learners from differing backgrounds",
        :type=> "integer"},
      {:name => "Standards Compliance",
        :description => "Adherence to international standards and specifications",
        :type=> "integer"}
    ]
  end

  def self.getScale
    return [1,5]
  end


  #############
  # Representation Data
  #############

  def self.representationData(lo)
    super(lo,Metric.find_by_type("Metrics::LORIAM"))
  end

  def self.representationDataForLos(los)
    super
  end

  def self.representationDataForComparingLos(los)
    super
  end

end