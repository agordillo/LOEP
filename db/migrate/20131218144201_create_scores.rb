class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :value
      t.integer :metric_id
      t.integer :lo_id

      t.timestamps
    end
  end
end
