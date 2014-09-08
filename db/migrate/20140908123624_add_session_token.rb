class AddSessionToken < ActiveRecord::Migration
  def up
    create_table :session_tokens do |t|
      t.integer :app_id
      t.string :auth_token
      t.datetime :expire_at
      t.timestamps
    end
  end

  def down
    drop_table :session_tokens
  end
end
