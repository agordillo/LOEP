# encoding: utf-8

class Evaluations::Loem < Evaluation
  # this is for Evaluations with evMethod=LOEM (type=LoemEvaluation)
  #Override methods here

  def init
    self.evmethod_id ||= Evmethod.find_by_name("LOEM").id
    super
  end

  def self.getItems
    [
      {:name => "Meaningful Interactions",
        :type=> "integer"},
      {:name => "Overall Control",
        :type=> "integer"},
      {:name => "Multimedia adds learning value ",
        :type=> "integer"},
      {:name => "Consistency",
        :description => "Pages have consistent look and feel",
        :type=> "integer"},
      {:name => "Layout",
        :description => "Clear and well organized",
        :type=> "integer"},
      {:name => "Labeling",
        :description => "Title on menu buttons, words on clickable buttons, any labels used to guide navigation",
        :type=> "integer"},
      {:name => "Readability",
        :description => "Look of text",
        :type=> "integer"},
      {:name => "Quality of Feedback",
        :description => "Refers to feedback given to user to help him/her progress through the learning object",
        :type=> "integer"},
      {:name => "Attractive",
        :description => "Has modern, appealing look",
        :type=> "integer"},
      {:name => "Graphics",
        :description => "Not video",
        :type=> "integer"},
      {:name => "Learning Mode",
        :type=> "integer"},
      {:name => "Motivation",
        :type=> "integer"},
      {:name => "Natural to Use",
        :description => "Intuitiveness of the interface, easy of use",
        :type=> "integer"},
      {:name => "Orientation",
        :description => "Does the user know where he/she is at all times?",
        :type=> "integer"},
      {:name => "Navigation Cues",
        :description => "Breadcrumb paths, page numbering, coloured buttons to indicate change of state, pop‐up boxes or mouseovers",
        :type=> "integer"},
      {:name => "Instructions",
        :type=> "integer"},
      {:name => "Appropriate Language Level ",
        :description => "Appropriate for the user",
        :type=> "integer"}
    ]
  end

  def self.getScale
    return [1,3]
  end

  #############
  # Representation Data
  #############

  def self.representationData(lo)
    super
    # super(lo,Metric.find_by_type("Metrics::LOEMAM"))
  end

  def representationDataForLos(los)
    super
  end

  def representationDataForComparingLos(los)
    super
  end

end