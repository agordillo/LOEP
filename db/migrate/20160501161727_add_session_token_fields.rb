class AddSessionTokenFields < ActiveRecord::Migration
  def change
    add_column :session_tokens, :multiple, :boolean, :default => false
    add_column :session_tokens, :action, :string
    add_column :session_tokens, :action_params, :text
  end
end
