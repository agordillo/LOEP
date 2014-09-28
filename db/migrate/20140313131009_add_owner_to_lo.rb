class AddOwnerToLo < ActiveRecord::Migration
  def change
    add_column :los, :owner_id, :integer
    add_column :los, :app_id, :integer
  end
end
