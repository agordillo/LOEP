class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.integer :user_id
      t.integer :assignment_id
      t.integer :lo_id
      t.integer :evmethod_id
      t.datetime :completed_at
      t.string :type

      t.timestamps
    end
  end
end
