class AddLoricToUser < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.integer :loric_id
    end
  end

  def down
    change_table :users do |t|
      t.remove :loric_id
    end
  end

end
