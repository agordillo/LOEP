class AddCallbackToApps < ActiveRecord::Migration
  def change
  	remove_column :los, :callback
  	add_column :apps, :callback, :text
  end
end
