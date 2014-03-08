class MakeScoreValuesDecimal < ActiveRecord::Migration
  def up
  	change_column :scores, :value, :decimal, :precision => 4, :scale => 2
  end

  def down
  	change_column :scores, :value, :integer
  end
end
