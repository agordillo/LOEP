# encoding: utf-8

class Evaluations::Une71362Teacher < Evaluation
  # this is for Evaluations with evMethod=UNE 71362 - Teacher (type=Une71362TeacherEvaluation)

  def init
    self.evmethod_id ||= Evmethod.find_by_name("UNE 71362 - Teacher").id
    super
  end

  def self.getItems
    items = []
    87.times do |i|
      item = {
        :name => I18n.t("evmethods.une71362_teacher.item" + (i+1).to_s + ".name"),
        :shortname => (i+1).to_s,
        :type=> "integer"
      }
      description = I18n.t("evmethods.une71362_teacher.item" + (i+1).to_s + ".description", default: "")
      item[:description] = description unless description.blank?
      items << item
    end
    2.times do |i|
      items << {
        :name => I18n.t("evmethods.une71362_teacher.item" + (i+88).to_s + ".name"),
        :type=> "text"
      }
    end
    items
  end

  def self.getScale
    return [0,10]
  end

  def self.getFormOptions
    {
      :scaleLegend => {
        :min => 0, 
        :max => 10
      },
      :explicitSkipAnswer => {
        :title => I18n.t("forms.evmethod.na")
      }
    }
  end

  def self.getSections
    [6,7,4,5,5,5,8,3,5,4,4,11,6,7,7,2]
  end

end