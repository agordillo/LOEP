class AddParamsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :birthday, :datetime
    add_column :users, :gender, :integer
    add_column :users, :lan, :string
  end
end
