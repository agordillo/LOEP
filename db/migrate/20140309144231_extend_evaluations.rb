class ExtendEvaluations < ActiveRecord::Migration
  def up
  	#Extend to 40 slots for Integer items and text items
  	add_column :evaluations, :item26, :integer
  	add_column :evaluations, :item27, :integer
  	add_column :evaluations, :item28, :integer
  	add_column :evaluations, :item29, :integer
  	add_column :evaluations, :item30, :integer
  	add_column :evaluations, :item31, :integer
  	add_column :evaluations, :item32, :integer
  	add_column :evaluations, :item33, :integer
  	add_column :evaluations, :item34, :integer
  	add_column :evaluations, :item35, :integer
  	add_column :evaluations, :item36, :integer
  	add_column :evaluations, :item37, :integer
  	add_column :evaluations, :item38, :integer
  	add_column :evaluations, :item39, :integer
  	add_column :evaluations, :item40, :integer
  	add_column :evaluations, :titem11, :text
  	add_column :evaluations, :titem12, :text
  	add_column :evaluations, :titem13, :text
  	add_column :evaluations, :titem14, :text
  	add_column :evaluations, :titem15, :text
  	add_column :evaluations, :titem16, :text
  	add_column :evaluations, :titem17, :text
  	add_column :evaluations, :titem18, :text
  	add_column :evaluations, :titem19, :text
  	add_column :evaluations, :titem20, :text
  	add_column :evaluations, :titem21, :text
  	add_column :evaluations, :titem22, :text
  	add_column :evaluations, :titem23, :text
  	add_column :evaluations, :titem24, :text
  	add_column :evaluations, :titem25, :text
  	add_column :evaluations, :titem26, :text
  	add_column :evaluations, :titem27, :text
  	add_column :evaluations, :titem28, :text
  	add_column :evaluations, :titem29, :text
  	add_column :evaluations, :titem30, :text
  	add_column :evaluations, :titem31, :text
  	add_column :evaluations, :titem32, :text
  	add_column :evaluations, :titem33, :text
  	add_column :evaluations, :titem34, :text
  	add_column :evaluations, :titem35, :text
  	add_column :evaluations, :titem36, :text
  	add_column :evaluations, :titem37, :text
  	add_column :evaluations, :titem38, :text
  	add_column :evaluations, :titem39, :text
  	add_column :evaluations, :titem40, :text

  	#Add a field to store an overall score
  	add_column :evaluations, :score, :decimal, :precision => 12, :scale => 6
  end

  def down
  	remove_column :evaluations, :item26
  	remove_column :evaluations, :item27
  	remove_column :evaluations, :item28
  	remove_column :evaluations, :item29
  	remove_column :evaluations, :item30
  	remove_column :evaluations, :item31
  	remove_column :evaluations, :item32
  	remove_column :evaluations, :item33
  	remove_column :evaluations, :item34
  	remove_column :evaluations, :item35
  	remove_column :evaluations, :item36
  	remove_column :evaluations, :item37
  	remove_column :evaluations, :item38
  	remove_column :evaluations, :item39
  	remove_column :evaluations, :item40

  	remove_column :evaluations, :titem11
  	remove_column :evaluations, :titem12
  	remove_column :evaluations, :titem13
  	remove_column :evaluations, :titem14
  	remove_column :evaluations, :titem15
  	remove_column :evaluations, :titem16
  	remove_column :evaluations, :titem17
  	remove_column :evaluations, :titem18
  	remove_column :evaluations, :titem19
  	remove_column :evaluations, :titem20
  	remove_column :evaluations, :titem21
  	remove_column :evaluations, :titem22
  	remove_column :evaluations, :titem23
  	remove_column :evaluations, :titem24
  	remove_column :evaluations, :titem25
  	remove_column :evaluations, :titem26
  	remove_column :evaluations, :titem27
  	remove_column :evaluations, :titem28
  	remove_column :evaluations, :titem29
  	remove_column :evaluations, :titem30
  	remove_column :evaluations, :titem31
  	remove_column :evaluations, :titem32
  	remove_column :evaluations, :titem33
  	remove_column :evaluations, :titem34
  	remove_column :evaluations, :titem35
  	remove_column :evaluations, :titem36
  	remove_column :evaluations, :titem37
  	remove_column :evaluations, :titem38
  	remove_column :evaluations, :titem39
  	remove_column :evaluations, :titem40

  	remove_column :evaluations, :score
  end
end
