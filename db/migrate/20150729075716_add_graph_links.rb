class AddGraphLinks < ActiveRecord::Migration
  def up
    create_table :metadata_graph_links do |t|
      t.integer :metadata_id
      t.string :keyword
      t.string :repository
      t.timestamps
    end
  end

  def down
    drop_table :metadata_graph_links
  end
end
