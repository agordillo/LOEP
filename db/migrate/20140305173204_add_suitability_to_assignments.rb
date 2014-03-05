class AddSuitabilityToAssignments < ActiveRecord::Migration
  def change
  	add_column :assignments, :suitability, :integer
  end
end
