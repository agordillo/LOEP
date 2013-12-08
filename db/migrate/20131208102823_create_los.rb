class CreateLos < ActiveRecord::Migration
  def change
    create_table :los do |t|
      t.string :url
      t.string :name
      t.string :description
      t.string :type
      t.string :repository
      t.string :callback
      t.string :technology
      t.boolean :hasQuizzes
      t.string :category

      t.timestamps
    end
  end
end
