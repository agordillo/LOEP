class CreateApps < ActiveRecord::Migration
  def up
    create_table :apps do |t|
      t.string :name
      t.string :auth_token

      t.timestamps
    end
  end

  def down
    drop_table :apps
  end
end
