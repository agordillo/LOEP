class AddLoInteractions < ActiveRecord::Migration
  def change
    create_table "lo_interactions", :force => true do |t|
      t.integer :lo_id
      t.integer :nsamples
    end

    create_table "lo_interaction_fields", :force => true do |t|
      t.integer :lo_interaction_id
      t.string :name
      t.decimal :average_value, :precision => 12, :scale => 6
      t.decimal :std, :precision => 12, :scale => 6
      t.decimal :min_value, :precision => 12, :scale => 6
      t.decimal :max_value, :precision => 12, :scale => 6
      t.decimal :percentil, :precision => 12, :scale => 6
      t.decimal :percentil_value, :precision => 12, :scale => 6
    end
  end
end
