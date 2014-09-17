class AddEncryptedPasswordToApps < ActiveRecord::Migration
  def up
    add_column :apps, :encrypted_password, :string, :null => false, :default => ""
  end

  def down
    remove_column :apps, :encrypted_password, :string
  end
end
