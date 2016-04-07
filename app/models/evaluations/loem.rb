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
      {:name => I18n.t("evmethods.loem.item1.name"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item2.name"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item3.name"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item4.name"),
        :description => I18n.t("evmethods.loem.item4.description"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item5.name"),
        :description => I18n.t("evmethods.loem.item5.description"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item6.name"),
        :description => I18n.t("evmethods.loem.item6.description"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item7.name"),
        :description => I18n.t("evmethods.loem.item7.description"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item8.name"),
        :description => I18n.t("evmethods.loem.item8.description"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item9.name"),
        :description => I18n.t("evmethods.loem.item9.description"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item10.name"),
        :description => I18n.t("evmethods.loem.item10.description"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item11.name"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item12.name"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item13.name"),
        :description => I18n.t("evmethods.loem.item13.description"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item14.name"),
        :description => I18n.t("evmethods.loem.item14.description"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item15.name"),
        :description => I18n.t("evmethods.loem.item15.description"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item16.name"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.loem.item17.name"),
        :description => I18n.t("evmethods.loem.item17.description"),
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
    super(lo,Metric.find_by_type("Metrics::LOEMAM"))
  end

end