class AddRankingSurveyAs < ActiveRecord::Migration
  def change
    create_table :survey_ranking_as do |t|
      t.text :results
      t.timestamps
    end
  end
end
