# LOEP (Learning Object Evaluation Platform)

LOEP aims to provide teachers and educators with a set of tools to facilitate the evaluation of small and self-contained web educational resources, known as Learning Objects. LOEP provides user and Learning Object management functionality, review assignments, a suite of evaluation tools (web and downloadable forms, peer review mechanisms, ...) to evaluate Learning Objects according to several formal evaluation models, and training material for reviewers and educators.


# Installation

1. bundle install
2. Rename config/initializers/secret_token_example.rb to config/initializers/secret_token.rb and execute 'rake secret' to generate a new secret_token and copy it to config/initializers/secret_token.rb
3. Rename config/initializers/recaptcha_example.rb to config/initializers/recaptcha.rb , and get new keys at https://www.google.com/recaptcha
4. Rename config/database_example.yml to config/database.yml , and write db configuration
5. Make migrations rake db:migrate
6. Populate db rake db:populate
rails s and enjoy!


# Discussion and contribution
  
Feel free to send us your comments and suggestions at [github](http://github.com/agordillo/LOEP/issues).  


# Installation and documentation

Do you want to install LOEP for development purposes? <br/>
Do you want to use LOEP in your project? <br/>
Do you want to deploy your own LOEP istance? <br/>
Are you looking to contribute to this open source project?  <br/>

Visit our [wiki](http://github.com/agordillo/LOEP/wiki) to see all the available documentation.  



# Copyright

Copyright 2015 Aldo Gordillo Méndez

LOEP is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

LOEP is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with LOEP. If not, see [http://www.gnu.org/licenses](http://www.gnu.org/licenses).

