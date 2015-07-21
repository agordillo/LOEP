class AddAutomaticToEvMethods < ActiveRecord::Migration
  def change
  	add_column :evmethods, :automatic, :boolean, :default => false
  end
end
