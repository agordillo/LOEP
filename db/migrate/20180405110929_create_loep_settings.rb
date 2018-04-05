class CreateLoepSettings < ActiveRecord::Migration
  def change
    create_table :loep_settings do |t|
      t.string :key
      t.text :value

      t.timestamps
    end
  end
end