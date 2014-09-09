class AddAppIdToEvaluations < ActiveRecord::Migration
  def up
    add_column :evaluations, :app_id, :integer
  end

  def down
    remove_column :evaluations, :app_id
  end
end
