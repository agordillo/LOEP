class AddOcupationToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :occupation, :string, :default => "education"
  end
end
