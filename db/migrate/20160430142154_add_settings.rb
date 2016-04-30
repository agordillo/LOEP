class AddSettings < ActiveRecord::Migration
  def change
    create_table "settings" do |t|
      t.string :key
      t.text :value
      t.string :repository
      t.timestamps
    end
  end
end
