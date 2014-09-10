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
      {:name => I18n.t("evmethods.lori.item1.name"),
         :description => I18n.t("evmethods.lori.item1.description"), 
         :type=> "integer"},
      {:name => I18n.t("evmethods.lori.item2.name"),
         :description => I18n.t("evmethods.lori.item2.description"), 
         :type=> "integer"},
      {:name => I18n.t("evmethods.lori.item3.name"),
         :description => I18n.t("evmethods.lori.item3.description"), 
         :type=> "integer"},
      {:name => I18n.t("evmethods.lori.item4.name"),
         :description => I18n.t("evmethods.lori.item4.description"), 
         :type=> "integer"},
      {:name => I18n.t("evmethods.lori.item5.name"),
         :description => I18n.t("evmethods.lori.item5.description"), 
         :type=> "integer"},
      {:name => I18n.t("evmethods.lori.item6.name"),
         :description => I18n.t("evmethods.lori.item6.description"), 
         :type=> "integer"},
      {:name => I18n.t("evmethods.lori.item7.name"),
         :description => I18n.t("evmethods.lori.item7.description"), 
         :type=> "integer"},
      {:name => I18n.t("evmethods.lori.item8.name"),
         :description => I18n.t("evmethods.lori.item8.description"), 
         :type=> "integer"},
      {:name => I18n.t("evmethods.lori.item9.name"),
         :description => I18n.t("evmethods.lori.item9.description"), 
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