class AddAnonymousEvaluations < ActiveRecord::Migration
  def up
    add_column :evaluations, :anonymous, :boolean, :default => false
  end

  def down
    remove_column :evaluations, :anonymous
  end
end
