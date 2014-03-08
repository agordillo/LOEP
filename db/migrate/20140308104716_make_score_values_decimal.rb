class MakeScoreValuesDecimal < ActiveRecord::Migration
  def up
  	change_column :scores, :value, :decimal, :precision => 12, :scale => 6
  end

  def down
  	change_column :scores, :value, :integer
  end
end
