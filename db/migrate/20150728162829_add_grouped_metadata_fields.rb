class AddGroupedMetadataFields < ActiveRecord::Migration
  def up
    create_table :grouped_metadata_fields do |t|
      t.string :name
      t.string :field_type
      t.string :value
      t.integer :n, :default => 1
      t.string :repository
      t.timestamps
    end
  end

  def down
    drop_table :grouped_metadata_fields
  end
end
