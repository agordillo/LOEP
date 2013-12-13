class CreateEvaluations < ActiveRecord::Migration
  def self.up
    create_table :evaluations do |t|
      t.integer :user_id
      t.integer :assignment_id
      t.integer :lo_id
      t.integer :evmethod_id
      t.string :type

      t.datetime :completed_at

      t.integer :item1
      t.integer :item2
      t.integer :item3
      t.integer :item4
      t.integer :item5
      t.integer :item6
      t.integer :item7
      t.integer :item8
      t.integer :item9
      t.integer :item10
      t.integer :item11
      t.integer :item12
      t.integer :item13
      t.integer :item14
      t.integer :item15
      t.integer :item16
      t.integer :item17
      t.integer :item18
      t.integer :item19
      t.integer :item20
      t.integer :item21
      t.integer :item22
      t.integer :item23
      t.integer :item24
      t.integer :item25

      t.text    :comments
      t.text    :titem1
      t.text    :titem2
      t.text    :titem3
      t.text    :titem4
      t.text    :titem5
      t.text    :titem6
      t.text    :titem7
      t.text    :titem8
      t.text    :titem9
      t.text    :titem10

      t.string  :sitem1
      t.string  :sitem2
      t.string  :sitem3
      t.string  :sitem4
      t.string  :sitem5

      t.timestamps
    end
  end
 
  def self.down
    drop_table :evaluations
  end
end
