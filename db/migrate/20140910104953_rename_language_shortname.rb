class RenameLanguageShortname < ActiveRecord::Migration
  def change
    rename_column :languages, :shortname, :code
  end
end
