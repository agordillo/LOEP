class AddValueToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :value, :integer, :default => 0
  end
end
