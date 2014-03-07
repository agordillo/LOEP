class Evaluations::Lori < Evaluation
  # this is for Evaluations with evMethod=LORI (type=LoriEvaluation)
  #Override methods here

  def create
    #LORI creator
    super
  end

  def self.getLoriItems
    [
      ["Content Quality","Veracity, accuracy, balanced presentation of ideas, and appropriate level of detail"],
      ["Learning Goal Alignment","Alignment among learning goals, activities, assessments, and learner characteristics"],
      ["Feedback and Adaptation","Adaptive content or feedback driven by differential learner input or learner modeling"],
      ["Motivation","Ability to motivate and interest an identified population of learners"],
      ["Presentation Design","Design of visual and auditory information for enhanced learning and efficient mental processing"],
      ["Interaction Usability","Ease of navigation, predictability of the user interface, and quality of the interface help features"],
      ["Accessibility","Design of controls and presentation formats to accommodate disabled and mobile learners"],
      ["Reusability","Ability to use in varying learning contexts and with learners from differing backgrounds"],
      ["Standards Compliance","Adherence to international standards and specifications"]
    ]
  end

end