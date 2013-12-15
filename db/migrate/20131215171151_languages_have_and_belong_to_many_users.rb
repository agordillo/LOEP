class LanguagesHaveAndBelongToManyUsers < ActiveRecord::Migration
  def up
  	create_table :languages_users, :id => false do |t|
      t.references :language, :user
    end
    create_table :users_languages, :id => false do |t|
      t.references :user, :language
    end
  end

  def down
  	drop_table :languages_users
    drop_table :users_languages
  end
end