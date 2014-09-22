class ExtendEvaluationSlots < ActiveRecord::Migration
  def up
  	#Extend to 100 slots for Integer items
    add_column :evaluations, :item41, :integer
    add_column :evaluations, :item42, :integer
    add_column :evaluations, :item43, :integer
    add_column :evaluations, :item44, :integer
    add_column :evaluations, :item45, :integer
    add_column :evaluations, :item46, :integer
    add_column :evaluations, :item47, :integer
    add_column :evaluations, :item48, :integer
    add_column :evaluations, :item49, :integer
    add_column :evaluations, :item50, :integer
    add_column :evaluations, :item51, :integer
    add_column :evaluations, :item52, :integer
    add_column :evaluations, :item53, :integer
    add_column :evaluations, :item54, :integer
    add_column :evaluations, :item55, :integer
    add_column :evaluations, :item56, :integer
    add_column :evaluations, :item57, :integer
    add_column :evaluations, :item58, :integer
    add_column :evaluations, :item59, :integer
    add_column :evaluations, :item60, :integer
    add_column :evaluations, :item61, :integer
    add_column :evaluations, :item62, :integer
    add_column :evaluations, :item63, :integer
    add_column :evaluations, :item64, :integer
    add_column :evaluations, :item65, :integer
    add_column :evaluations, :item66, :integer
    add_column :evaluations, :item67, :integer
    add_column :evaluations, :item68, :integer
    add_column :evaluations, :item69, :integer
    add_column :evaluations, :item70, :integer
    add_column :evaluations, :item71, :integer
    add_column :evaluations, :item72, :integer
    add_column :evaluations, :item73, :integer
    add_column :evaluations, :item74, :integer
    add_column :evaluations, :item75, :integer
    add_column :evaluations, :item76, :integer
    add_column :evaluations, :item77, :integer
    add_column :evaluations, :item78, :integer
    add_column :evaluations, :item79, :integer
    add_column :evaluations, :item80, :integer
    add_column :evaluations, :item81, :integer
    add_column :evaluations, :item82, :integer
    add_column :evaluations, :item83, :integer
    add_column :evaluations, :item84, :integer
    add_column :evaluations, :item85, :integer
    add_column :evaluations, :item86, :integer
    add_column :evaluations, :item87, :integer
    add_column :evaluations, :item88, :integer
    add_column :evaluations, :item89, :integer
    add_column :evaluations, :item90, :integer
    add_column :evaluations, :item91, :integer
    add_column :evaluations, :item92, :integer
    add_column :evaluations, :item93, :integer
    add_column :evaluations, :item94, :integer
    add_column :evaluations, :item95, :integer
    add_column :evaluations, :item96, :integer
    add_column :evaluations, :item97, :integer
    add_column :evaluations, :item98, :integer
    add_column :evaluations, :item99, :integer
  end

  def down
    remove_column :evaluations, :item41
    remove_column :evaluations, :item42
    remove_column :evaluations, :item43
    remove_column :evaluations, :item44
    remove_column :evaluations, :item45
    remove_column :evaluations, :item46
    remove_column :evaluations, :item47
    remove_column :evaluations, :item48
    remove_column :evaluations, :item49
    remove_column :evaluations, :item50
    remove_column :evaluations, :item51
    remove_column :evaluations, :item52
    remove_column :evaluations, :item53
    remove_column :evaluations, :item54
    remove_column :evaluations, :item55
    remove_column :evaluations, :item56
    remove_column :evaluations, :item57
    remove_column :evaluations, :item58
    remove_column :evaluations, :item59
    remove_column :evaluations, :item60
    remove_column :evaluations, :item61
    remove_column :evaluations, :item62
    remove_column :evaluations, :item63
    remove_column :evaluations, :item64
    remove_column :evaluations, :item65
    remove_column :evaluations, :item66
    remove_column :evaluations, :item67
    remove_column :evaluations, :item68
    remove_column :evaluations, :item69
    remove_column :evaluations, :item70
    remove_column :evaluations, :item71
    remove_column :evaluations, :item72
    remove_column :evaluations, :item73
    remove_column :evaluations, :item74
    remove_column :evaluations, :item75
    remove_column :evaluations, :item76
    remove_column :evaluations, :item77
    remove_column :evaluations, :item78
    remove_column :evaluations, :item79
    remove_column :evaluations, :item80
    remove_column :evaluations, :item81
    remove_column :evaluations, :item82
    remove_column :evaluations, :item83
    remove_column :evaluations, :item84
    remove_column :evaluations, :item85
    remove_column :evaluations, :item86
    remove_column :evaluations, :item87
    remove_column :evaluations, :item88
    remove_column :evaluations, :item89
    remove_column :evaluations, :item90
    remove_column :evaluations, :item91
    remove_column :evaluations, :item92
    remove_column :evaluations, :item93
    remove_column :evaluations, :item94
    remove_column :evaluations, :item95
    remove_column :evaluations, :item96
    remove_column :evaluations, :item97
    remove_column :evaluations, :item98
    remove_column :evaluations, :item99
  end
end
