class AddUserAndLoContextToEvaluations < ActiveRecord::Migration
  def up
    #User context
    add_column :evaluations, :uc_age, :integer
    add_column :evaluations, :uc_gender, :integer

    #LO context
    add_column :evaluations, :loc_context, :string
    add_column :evaluations, :loc_grade, :text
    add_column :evaluations, :loc_strategy, :string
  end

  def down
    remove_column :evaluations, :uc_age
    remove_column :evaluations, :uc_gender

    remove_column :evaluations, :loc_context
    remove_column :evaluations, :loc_grade
    remove_column :evaluations, :loc_strategy
  end
end
