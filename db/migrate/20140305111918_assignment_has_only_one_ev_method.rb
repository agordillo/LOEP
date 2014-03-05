class AssignmentHasOnlyOneEvMethod < ActiveRecord::Migration
  def up
  	drop_table :evmethods_assignments
    drop_table :assignments_evmethods

    add_column :assignments, :evmethod_id, :integer
  end

  def down
  	remove_column :assignments, :evmethod_id
  end
end
