LOEP
====

Learning Object Evaluation Platform

Installation:

1. bundle install
2. Rename config/initializers/secret_token_example.rb to config/initializers/secret_token.rb and execute 'rake secret' to generate a new secret_token and copy it to config/initializers/secret_token.rb
3. Rename config/initializers/secret_token_example.rb to config/initializers/secret_token.rb and execute 'rake secret' to generate a new secret_token and copy it to config/initializers/secret_token.rb
4. Rename config/database_example.yml to config/database.yml , and write conf
5. Make migrations rake db:migrate
6. Populate db rake db:populate
rails s and enjoy!
