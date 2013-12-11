class CreateEvmethods < ActiveRecord::Migration
  def change
    create_table :evmethods do |t|
      t.string :name

      t.timestamps
    end
  end
end
