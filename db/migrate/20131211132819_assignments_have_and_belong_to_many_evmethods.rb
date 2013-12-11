class AssignmentsHaveAndBelongToManyEvmethods < ActiveRecord::Migration
  def self.up
    create_table :evmethods_assignments, :id => false do |t|
      t.references :evmethod, :assignment
    end
    create_table :assignments_evmethods, :id => false do |t|
      t.references :assignment, :evmethod
    end
  end
 
  def self.down
    drop_table :evmethods_assignments
    drop_table :assignments_evmethods
  end
end