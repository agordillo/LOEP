class RemoveCategoriesFromLos < ActiveRecord::Migration
  def change
    remove_column :los, :categories
  end
end
