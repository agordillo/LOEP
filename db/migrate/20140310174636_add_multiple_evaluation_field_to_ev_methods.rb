class AddMultipleEvaluationFieldToEvMethods < ActiveRecord::Migration
  def change
  	add_column :evmethods, :allow_multiple_evaluations, :boolean, :default => false
  end
end
