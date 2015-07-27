class AddMetadataFieldInstances < ActiveRecord::Migration
  def up
    create_table :metadata_fields do |t|
      t.string :name
      t.string :field_type
      t.string :value
      t.integer :n, :default => 1
      t.integer :metadata_id
      t.string :repository
      t.timestamps
    end
  end

  def down
    drop_table :metadata_fields
  end
end
