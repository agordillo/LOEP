class AddDeviseToApps < ActiveRecord::Migration
  def self.up
    change_table(:apps) do |t|
      ## Token Authenticatable
      t.string :authentication_token
    end
  end

  def self.down
    remove_column :users, :authentication_token
  end
end
