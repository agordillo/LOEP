class AddOwnerToIcode < ActiveRecord::Migration
  def change
    add_column :icodes, :owner_id, :integer
  end
end
