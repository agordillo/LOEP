class LoInteraction < ActiveRecord::Base
  belongs_to :lo
  has_many :lo_interaction_fields

  validates :lo_id, :presence => true, :uniqueness => true

  after_destroy :remove_interaction_fields

  #Allow to create a LoInteraction record with a hash representing the interactions
  # Example:
  # { 
  #   "nsamples" => 100,
  #   "interactions" => {
  #     "nclics" => 25,
  #     "tlo" => {
  #       "average_value" => 125.8,
  #       "min_value" => 5.25,
  #       "max_value" => 285.2,
  #       "percentil" => 70,
  #       "percentil_value" => 135
  #     }
  #   }
  # }
  def self.createWithHash(lo,h={})
    h = {} unless h.is_a? Hash
    h = h.parse_types #Convert strings to numbers when possible

    loInteraction = lo.getInteraction
    loInteraction.destroy unless loInteraction.blank? #Remove previous record

    i = LoInteraction.new(:lo_id => lo.id)
    i.nsamples = h["nsamples"].to_i unless h["nsamples"].blank?
    i.valid?
    raise(i.errors.full_messages.to_sentence) unless i.errors.blank? and i.save
    if h["interactions"].is_a? Hash
      h["interactions"].each do |key,value|
        LoInteractionField.createWithHash(i,key,value)
      end
    end
    i
  end

  def extended_attributes
    attrs = self.attributes
    self.lo_interaction_fields.each do |f|
      attrs[f.name] = f.attributes_for_lo_interaction
    end
    attrs
  end


  private

  def remove_interaction_fields
    self.lo_interaction_fields.destroy_all
  end
end