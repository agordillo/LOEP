class AddIdRepositoryToLos < ActiveRecord::Migration
  def change
    add_column :los, :id_repository, :integer
  end
end
