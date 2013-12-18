class MetricsHaveAndBelongToManyEvmethods < ActiveRecord::Migration
  def up
  	create_table :evmethods_metrics, :id => false do |t|
      t.references :evmethod, :metric
    end
    create_table :metrics_evmethods, :id => false do |t|
      t.references :metric, :evmethod
    end
  end

  def down
  	drop_table :evmethods_metrics
    drop_table :metrics_evmethods
  end
end