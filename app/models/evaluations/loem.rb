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
      ["Meaningful Interactions",""],
      ["Overall Control",""],
      ["Multimedia adds learning value ",""],
      ["Consistency","Pages have consistent look and feel"],
      ["Layout","Clear and well organized"],
      ["Labeling","Title on menu buttons, words on clickable buttons, any labels used to guide navigation"],
      ["Readability","Look of text"],
      ["Quality of Feedback","Refers to feedback given to user to help him/her progress through the learning object"],
      ["Attractive","Has modern, appealing look"],
      ["Graphics","Not video"],
      ["Learning Mode",""],
      ["Motivation",""],
      ["Natural to Use","Intuitiveness of the interface, easy of use"],
      ["Orientation ","Does the user know where he/she is at all times?"],
      ["Navigation Cues ","Breadcrumb paths, page numbering, coloured buttons to indicate change of state, pop‐up boxes or mouseovers"],
      ["Instructions ",""],
      ["Appropriate Language Level ","Appropriate for the user"]
    ]
  end

end