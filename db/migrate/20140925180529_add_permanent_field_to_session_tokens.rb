class AddPermanentFieldToSessionTokens < ActiveRecord::Migration
  def up
    add_column :session_tokens, :permanent, :boolean, :default => false
  end

  def down
    remove_column :session_tokens, :permanent
  end
end
