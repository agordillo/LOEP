class AddRankingSurveyAs < ActiveRecord::Migration
  def up
    unless table_exists? 'survey_ranking_as'
      create_table :survey_ranking_as do |t|
        t.text :results
        t.timestamps
      end
    end
  end

  def down
    if table_exists? 'survey_ranking_as'
     drop_table :survey_ranking_as
    end
  end

end
