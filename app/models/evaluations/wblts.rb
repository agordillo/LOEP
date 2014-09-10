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
      {:name => I18n.t("evmethods.Wblts.item1.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item1.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item2.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item2.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item3.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item3.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item4.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item4.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item5.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item5.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item6.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item6.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item7.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item7.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item8.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item8.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item9.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item9.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item10.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item10.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item11.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item11.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item12.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item12.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item13.name") + ".",
        :shortname => I18n.t("evmethods.Wblts.item13.shortname"),
        :type=> "integer"},
      {:name => I18n.t("evmethods.Wblts.item14.name"),
        :type=> "text"},
      {:name => I18n.t("evmethods.Wblts.item15.name"),
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