class AddSessionTokenFields < ActiveRecord::Migration
  def change
    add_column :session_tokens, :multiple, :boolean, :default => false
  end
end
