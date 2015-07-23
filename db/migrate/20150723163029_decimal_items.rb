class DecimalItems < ActiveRecord::Migration
  def up
    add_column :evaluations, :ditem1, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem2, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem3, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem4, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem5, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem6, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem7, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem8, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem9, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem10, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem11, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem12, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem13, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem14, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem15, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem16, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem17, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem18, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem19, :decimal, :precision => 12, :scale => 6
    add_column :evaluations, :ditem20, :decimal, :precision => 12, :scale => 6
  end

  def down
    remove_column :evaluations, :ditem1
    remove_column :evaluations, :ditem2
    remove_column :evaluations, :ditem3
    remove_column :evaluations, :ditem4
    remove_column :evaluations, :ditem5
    remove_column :evaluations, :ditem6
    remove_column :evaluations, :ditem7
    remove_column :evaluations, :ditem8
    remove_column :evaluations, :ditem9
    remove_column :evaluations, :ditem10
    remove_column :evaluations, :ditem11
    remove_column :evaluations, :ditem12
    remove_column :evaluations, :ditem13
    remove_column :evaluations, :ditem14
    remove_column :evaluations, :ditem15
    remove_column :evaluations, :ditem16
    remove_column :evaluations, :ditem17
    remove_column :evaluations, :ditem18
    remove_column :evaluations, :ditem19
    remove_column :evaluations, :ditem20
  end
end
