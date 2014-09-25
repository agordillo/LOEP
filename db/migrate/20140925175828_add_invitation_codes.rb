class AddInvitationCodes < ActiveRecord::Migration
  def up
    create_table :icodes do |t|
      t.string :code, :null => false
      t.datetime :expire_at, :null => false
      t.integer :role_id, :null => false
      t.boolean :permanent, :default => false
      t.timestamps
    end
  end

  def down
    drop_table :icodes
  end
end
