LOEP
====

Learning Object Evaluation Platform

Installation:

1. Rename config/initializers/secret_token_example.rb to config/initializers/secret_token.rb and execute 'rake secret' to generate a new secret_token and copy it to config/initializers/secret_token.rb
2. Rename config/initializers/recaptcha_example.rb to config/initializers/recaptcha.rb , and get new keys at https://www.google.com/recaptcha
3. Make migrations rake db:migrate
4. Populate db rake db:populate
rails s and enjoy!
