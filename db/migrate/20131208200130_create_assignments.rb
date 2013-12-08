class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :author_id
      t.integer :user_id
      t.integer :lo_id
      t.string :status
      t.datetime :deadline
      t.datetime :completed_at
      t.text :description
      t.text :emethods

      t.timestamps
    end
  end
end
