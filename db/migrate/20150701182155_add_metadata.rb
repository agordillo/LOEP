class AddMetadata < ActiveRecord::Migration
  def up
    create_table :metadata do |t|
      t.integer :lo_id
      t.string :schema
      t.text :content
      t.text :lom_content

      t.timestamps
    end
    add_column :los, :metadata_url, :text
  end

  def down
    remove_column :los, :metadata_url
    drop_table :metadata
  end
end
