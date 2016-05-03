class AddIdUserInAppToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :id_user_app, :string
    rename_column :evaluations, :anonymous, :external
  end
end
