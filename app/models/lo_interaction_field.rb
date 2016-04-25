class LoInteractionField < ActiveRecord::Base
  belongs_to :lo_interaction

  validates :name, :presence => true
  validates :lo_interaction_id, uniqueness: { :scope => :name, :case_sensitive => false }, :presence => true
  validates :average_value, :presence => true, :numericality => true

  # Examples
  #
  # "nclics" => 25
  #
  # "tlo" => {
  #   "average_value" => 125.8,
  #   "min_value" => 5.25,
  #   "max_value" => 285.2,
  #   "percentil" => 70,
  #   "percentil_value" => 135
  # }
  def self.createWithHash(loInteraction,key,value={})
    f = LoInteractionField.new(:lo_interaction_id => loInteraction.id)
    f.name = key if key.is_a? String
    if value.is_a? Hash
      value.each do |key,value|
        f.send("#{key}=", value) if f.respond_to?(key) and !value.blank?
      end
    else
      f.average_value = value
    end
    f.valid?
    raise(f.errors.full_messages.to_sentence) unless f.errors.blank? and f.save
    f
  end

  def attributes_for_lo_interaction
    attrs = {}
    self.attributes.each do |name,value|
      unless value.blank? or ["id","lo_interaction_id","name"].include?(name)
        attrs[name] = self.send(name)
        attrs[name] = attrs[name].to_f if attrs[name].is_a? BigDecimal
      end
    end
    attrs
  end
end