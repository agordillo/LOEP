class CreateLos < ActiveRecord::Migration
  def change
    create_table :los do |t|
      t.text :url
      t.string :name
      t.text :description
      t.string :lotype
      t.string :repository
      t.text :callback
      t.string :technology
      t.text :categories
      t.integer :language_id

      t.boolean :hasText
      t.boolean :hasImages
      t.boolean :hasVideos
      t.boolean :hasAudios
      t.boolean :hasQuizzes
      t.boolean :hasWebs
      t.boolean :hasFlashObjects
      t.boolean :hasApplets
      t.boolean :hasDocuments
      t.boolean :hasFlashcards
      t.boolean :hasVirtualTours
      t.boolean :hasEnrichedVideos

      t.timestamps
    end
  end
end
