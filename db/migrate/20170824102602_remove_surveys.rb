class RemoveSurveys < ActiveRecord::Migration
  def up
    drop_table :lorics if table_exists? 'lorics'
    drop_table :survey_ranking_as if table_exists? 'survey_ranking_as'
  end

  def down
  end
end