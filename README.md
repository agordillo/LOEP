LOEP
====

Learning Object Evaluation Platform

Installation:

1. bundle install
2. Rename config/initializers/secret_token_example.rb to config/initializers/secret_token.rb and execute 'rake secret' to generate a new secret_token and copy it to config/initializers/secret_token.rb
3. Rename config/initializers/recaptcha_example.rb to config/initializers/recaptcha.rb , and get new keys at https://www.google.com/recaptcha
4. Rename config/database_example.yml to config/database.yml , and write db configuration
5. Make migrations rake db:migrate
6. Populate db rake db:populate
rails s and enjoy!


#Production
Create symbolik links
ln -s /home/loep/LOEP/loepConfFiles/secret_token.rb /home/loep/LOEP/current/config/initializers/secret_token.rb
ln -s /home/loep/LOEP/loepConfFiles/secret_token.rb /home/loep/LOEP/current/config/initializers/session_store.rb
ln -s /home/loep/LOEP/loepConfFiles/recaptcha.rb /home/loep/LOEP/current/config/initializers/recaptcha.rb
ln -s /home/loep/LOEP/loepConfFiles/database.yml /home/loep/LOEP/current/config/database.yml


