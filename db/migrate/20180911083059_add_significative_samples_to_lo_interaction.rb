class AddSignificativeSamplesToLoInteraction < ActiveRecord::Migration
  def change
  	add_column :lo_interactions, :nsignificativesamples, :integer
  end
end