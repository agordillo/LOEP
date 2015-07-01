class AddLomProfiles < ActiveRecord::Migration
  def up
    create_table :loms do |t|
      t.integer :lo_id
      t.text :profile

      t.timestamps
    end
    add_column :los, :lom_profile_url, :text
  end

  def down
    remove_column :los, :lom_profile_url
  	drop_table :loms
  end
end
