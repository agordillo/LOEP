class AddLoInteractions < ActiveRecord::Migration
  def change
    drop_table "lo_interactions" if (table_exists? "lo_interactions")
    drop_table "lo_interaction_fields" if (table_exists? "lo_interaction_fields")

    create_table "lo_interactions" do |t|
      t.integer :lo_id
      t.integer :nsamples
      t.timestamps
    end

    create_table "lo_interaction_fields" do |t|
      t.integer :lo_interaction_id
      t.string :name
      t.decimal :average_value, :precision => 12, :scale => 6
      t.decimal :std, :precision => 12, :scale => 6
      t.decimal :min_value, :precision => 12, :scale => 6
      t.decimal :max_value, :precision => 12, :scale => 6
      t.decimal :percentil, :precision => 12, :scale => 6
      t.decimal :percentil_value, :precision => 12, :scale => 6
      t.timestamps
    end
  end
end
