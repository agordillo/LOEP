class CreateLorics < ActiveRecord::Migration
  def change
    create_table :lorics do |t|
      t.integer :user_id

      t.integer :item1
      t.integer :item2
      t.integer :item3
      t.integer :item4
      t.integer :item5
      t.integer :item6
      t.integer :item7
      t.integer :item8
      t.integer :item9

      t.text :comments

      t.timestamps
    end
  end
end
