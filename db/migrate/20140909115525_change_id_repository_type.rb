class ChangeIdRepositoryType < ActiveRecord::Migration
  def up
    change_column :los, :id_repository, :string
  end

  def down
    change_column :los, :id_repository, :integer
  end
end
