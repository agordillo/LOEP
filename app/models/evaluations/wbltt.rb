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
      {:name => I18n.t("evmethods.Wbltt.item1.name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item1.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wbltt.item2.name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item2.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wbltt.item3.name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item3.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wbltt.item4.name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item4.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wbltt.item5.name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item5.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wbltt.item6.name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item6.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wbltt.item7.name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item7.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wbltt.item8.name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item8.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wbltt.item9.name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item9.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wbltt.item10.name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item10.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wbltt.item11.name") + ".",
        :shortname => I18n.t("evmethods.Wbltt.item11.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wbltt.item12.name"),
        :type=> "text"},
      {:name => I18n.t("evmethods.Wbltt.item13.name"),
        :type=> "text"},
      {:name => I18n.t("evmethods.Wbltt.item14.name"),
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