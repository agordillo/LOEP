# encoding: utf-8

namespace :db do

	desc 'Populate database with fake data for development'
	task :populate => 'db:populate:reload'
	task :upgrade => 'db:populate:upgrade'

	namespace :populate do

		#bundle exec rake db:populate:reload
		task :reload => :environment do
			desc "Populate db"
			puts "Populating database for development"

			unless Rails.env == "development"
				fail "Prevent populate in production"
			end

			if Rails.env == "development"
				#Remove data
				Rake::Task["db:reset"].invoke
			end

			#Create Roles, Languages, Evaluation Models, Metrics and Scores
			Rake::Task["db:populate:components"].invoke

			#Create users
			Rake::Task["db:populate:create_users"].invoke
						
			#Create 10 fake users for development
			role_reviewer = Role.find_by_name("Reviewer")
			role_user = Role.find_by_name("User")
			english = Language.find_by_code("en")
			spanish = Language.find_by_code("es")

			if Rails.env == "development"
				10.times do |i|
					user = User.new
					user.name = Faker::Name.name
					user.email = Faker::Internet.free_email
					user.password = "demonstration"
					user.password_confirmation = "demonstration"
					user.language_id = english.id
					user.languages.push(english)
					user.languages.push(spanish)
					user.occupation = "education"
					user.gender = 1
					user.birthday = Time.now
					user.roles.push(role_reviewer)
					user.save!
				end
			end

			user_admin = User.find_by_email("admin@loep.com")
			user_reviewer = User.find_by_email("reviewer@loep.com")

			#Create LOs
			loA = Lo.new
			loA.url = "http://vishub.org/excursions/83"
			loA.name = "Curiosity Flashcard"
			loA.description = "A Flashcard about Curiosity, the car-sized robotic rover exploring Gale Crater on Mars."
			loA.lotype = "veslideshow"
			loA.repository = "ViSH"
			loA.technology = "html"
			loA.language_id = english.id
			loA.hasQuizzes = true
			loA.owner_id = user_admin.id
			loA.save!

			loB = Lo.new
			loB.url = "http://vishub.org/excursions/44"
			loB.name = "Chess: The Art of Learning"
			loB.description = "The Art of Learning, a journey in the pursuit of excellence. Amazing presentation with images, videos and 3d objects, generated by Vish Editor."
			loB.lotype = "veslideshow"
			loB.repository = "ViSH"
			loB.technology = "html"
			loB.language_id = spanish.id
			loB.hasQuizzes = false
			loB.hasWebs = true
			loB.owner_id = user_admin.id
			loB.save!

			#Create 10 fake LOs for development
			if Rails.env == "development"
				10.times do |i|
					lo = Lo.new
					lo.url = "http://vishub.org/fake_excursions/" + (i+1).to_s
					lo.name = "LO" + Faker::Name.name.split(" ").pop()
					lo.lotype = "veslideshow"
					lo.repository = "ViSH"
					lo.technology = "html"
					lo.language_id = spanish.id
					lo.owner_id = user_admin.id
					lo.save!
				end
			end

			#Create Assignments
			LORI = Evmethod.find_by_name("LORI v1.5")

			#Admin create an assigment to request the Reviewer to evaluate the Curiosity Flashcard
			asA = Assignment.new
			asA.author_id = user_admin.id
			asA.user_id = user_reviewer.id
			asA.lo_id = loA.id
			asA.evmethod_id = LORI.id
			asA.status = "Pending"
			#Deadline in one week
			asA.deadline = DateTime.now + 7
			asA.description = "Please, evaluate the following flashcard using LORI (Learning Object Review Instrument)."
			asA.save!

			#Also evaluate the LO titled: Chess: The Art of Learning
			#Admin create an assigment to request the Reviewer to evaluate the Curiosity Flashcard
			asB = Assignment.new
			asB.author_id = user_admin.id
			asB.user_id = user_reviewer.id
			asB.lo_id = loB.id
			asB.evmethod_id = LORI.id
			asB.status = "Pending"
			#Deadline in two weeks
			asB.deadline = DateTime.now + 14
			asB.description = "Please, evaluate the following LO using LORI (Learning Object Review Instrument)."
			asB.save!

			#Create evaluations
			#Reviewer evaluate the Curiosity Flashcard using LORI (Evaluation requested in the assignment)
			evA = Evaluations::Lori.new
			evA.user_id = user_reviewer.id
			evA.lo_id = loA.id
			evA.evmethod_id = LORI.id
			evA.assignment_id = asA.id #not mandatory
			evA.item1 = 4
			evA.item2 = 3
			evA.item3 = 5
			evA.item4 = 2
			evA.item5 = 3
			evA.item6 = 4
			evA.item7 = 1
			evA.item8 = 3
			evA.item9 = 5
			evA.comments = "This Learning Object is great!"
			evA.score = 8 #Propose an score for the LO
			evA.save!

			#Create (new) Scores
			Rake::Task["db:populate:scores"].invoke

			puts "Population finished"
		end

		#bundle exec rake db:populate:install
		#bundle exec rake db:populate:install RAILS_ENV=production
		task :install => :environment do
			desc 'Install LOEP'
			puts "Installing LOEP"

			installedVersionInstance = LoepSetting.find_by_key("installed_version")
			installedVersion = installedVersionInstance.nil? ? nil : installedVersionInstance.value
			abort("LOEP has been already installed.") unless installedVersion.blank?

			#Create Roles, Languages, Evaluation Models, Metrics and Scores
			Rake::Task["db:populate:components"].invoke

			#Create users
			Rake::Task["db:populate:create_users"].invoke

			installedVersionInstance = LoepSetting.new(:key => "installed_version") if installedVersionInstance.nil?
			installedVersionInstance.value = LOEP::Application.config.version
			installedVersionInstance.save!

			#Install plugins
			Rake::Task["db:populate:install_plugins"].invoke

			puts "Installation finished"
		end

		#bundle exec rake db:populate:upgrade
		#bundle exec rake db:populate:upgrade RAILS_ENV=production
		task :upgrade => :environment do
			currentVersion = LOEP::Application.config.version
			if ActiveRecord::Base.connection.table_exists?("loep_settings")
				installedVersionInstance = LoepSetting.find_by_key("installed_version")
			else
				installedVersionInstance = nil
			end
			installedVersion = installedVersionInstance.nil? ? nil : installedVersionInstance.value

			if installedVersion.blank?
				if !ActiveRecord::Base.connection.table_exists?("loep_settings") and ActiveRecord::Base.connection.table_exists?("roles") and Role.count > 0
					#An old version of LOEP that lacks of LoepSettings was previously installed
					installedVersion = "1.0"
				else
					abort("LOEP needs to be installed. Execute bundle exec rake db:populate:install.")
				end
			end

			abort("LOEP is already in version " + currentVersion + ". No upgrade was performed.") if installedVersion == currentVersion
			abort("A more recent version (" + installedVersion + ") of LOEP was previously installed. No upgrade was performed.") if Gem::Version.new(currentVersion) < Gem::Version.new(installedVersion)
			
			puts "Upgrading LOEP to version: " + currentVersion
			
			#Apply new migrations
			Rake::Task["db:migrate"].invoke

			#Create new Roles, Languages, Evaluation Models, Metrics and update scores
			Rake::Task["db:populate:components"].invoke

			installedVersionInstance = LoepSetting.new(:key => "installed_version") if installedVersionInstance.nil?
			installedVersionInstance.value = currentVersion
			installedVersionInstance.save!

			#Install plugins
			Rake::Task["db:populate:install_plugins"].invoke

			puts "Upgrade finished"
		end


		#############
		## Subtasks
		#############

		task :components => :environment do
			Rake::Task["db:populate:roles"].invoke
			Rake::Task["db:populate:languages"].invoke
			Rake::Task["db:populate:evmethods"].invoke
			Rake::Task["db:populate:metrics"].invoke
		end

		task :roles => :environment do
			roles = [
				{name:"SuperAdmin", value:9},
				{name:"Admin", value:8},
				{name:"Reviewer", value:2},
				{name:"User", value:1}
			]
			roles.each do |role|
				r = Role.find_by_name(role[:name])
				if r.nil?
					puts "Creating new role: " + role[:name]
					Role.create!  :name  => role[:name], :value => role[:value]
				end
			end
		end

		task :languages => :environment do
			desc "Create Languages"

			languages = [
				{name:"Language independent", code:"lanin"},
				{name:"Other", code:"lanot"},
				{name:"English", code:"en"},
				{name:"Español", code:"es"},
				{name:"Deutsch", code:"de"},
				{name:"Français", code:"fr"},
				{name:"Italiano", code:"it"},
				{name:"Nederlands", code:"nl"},
				{name:"Magyar", code:"hu"}
			]

			languages.each do |language|
				l = Language.find_by_code(language[:code])
				if l.nil?
					puts "Creating new language: " + language[:name]
					l = Language.new
					l.name = language[:name]
					l.code = language[:code]
					l.save!
				end
			end
		end

		task :evmethods => :environment do
			desc "Create Evaluation Models"
			
			#Create the evaluation models in the database if they are not created
			LOEP_VANILLA_EvMethods = [
				{name:"LORI v1.5", module_name:"Evaluations::Lori", multiple:false, automatic: false},
				{name:"LOEM", module_name:"Evaluations::Loem", multiple:false, automatic: false},
				{name:"WBLT-S", module_name:"Evaluations::Wblts", multiple:true, automatic: false},
				{name:"WBLT-T", module_name:"Evaluations::Wbltt", multiple:false, automatic: false},
				{name:"SUS", module_name:"Evaluations::Sus", multiple:false, automatic: false},
				{name:"Metadata Quality", module_name:"Evaluations::Metadata", multiple:false, automatic: true},
				{name:"Interaction Quality", module_name:"Evaluations::Qinteraction", multiple:false, automatic: true}
			]

			addedEvmethods = []

			LOEP_VANILLA_EvMethods.each do |evmethod|
				ev = Evmethod.find_by_name(evmethod[:name])
				if ev.nil?
					#Create ev method
					puts "Creating new evaluation model: " + evmethod[:name]
					ev = Evmethod.new
					ev.name = evmethod[:name]
					ev.module = evmethod[:module_name]
					ev.allow_multiple_evaluations = evmethod[:multiple]
					ev.automatic = evmethod[:automatic]
					ev.save!
					addedEvmethods.push(ev)
				end
			end

			unless addedEvmethods.blank?
				#Create scores for the new evaluation models (only possible for automatic evaluation models)
				Rake::Task["db:populate:scores"].reenable
				Rake::Task["db:populate:scores"].invoke([],addedEvmethods.map{|m| m.name}.join(","))
			end
		end

		task :metrics => :environment do
			desc "Create Metrics"

			#Create the metrics in the database if they are not created
			LOEP_VANILLA_Metrics = [
				{name:"LORI Arithmetic Mean", module_name:"Metrics::LORIAM", evmethods:["LORI v1.5"]},
				{name:"LORI WAM CW", module_name:"Metrics::LORIWAM1", evmethods:["LORI v1.5"]},
				{name:"LORI WAM IW", module_name:"Metrics::LORIWAM2", evmethods:["LORI v1.5"]},
				{name:"LORI Pedagogical WAM", module_name:"Metrics::LORIPWAM", evmethods:["LORI v1.5"]},
				{name:"LORI Technological WAM", module_name:"Metrics::LORITWAM", evmethods:["LORI v1.5"]},
				{name:"LORI Orthogonal", module_name:"Metrics::LORIORT", evmethods:["LORI v1.5"]},
				{name:"LORI Square Root", module_name:"Metrics::LORISQRT", evmethods:["LORI v1.5"]},
				{name:"LORI Logarithmic", module_name:"Metrics::LORILOG", evmethods:["LORI v1.5"]},
				{name:"LOEM Arithmetic Mean", module_name:"Metrics::LOEMAM", evmethods:["LOEM"]},
				{name:"WBLT-S Arithmetic Mean", module_name:"Metrics::WBLTSAM", evmethods:["WBLT-S"]},
				{name:"WBLT-T Arithmetic Mean", module_name:"Metrics::WBLTTAM", evmethods:["WBLT-T"]},
				{name:"Global SUS", module_name:"Metrics::SUSG", evmethods:["SUS"]},
				{name:"LORIEM", module_name:"Metrics::LORIEM", evmethods:["LORI v1.5","LOEM"]},
				{name:"LOM Metadata Quality", module_name:"Metrics::LomMetadata", evmethods:["Metadata Quality"]},
				{name:"LOM Completeness Metadata Quality", module_name:"Metrics::LomMetadataCompleteness", evmethods:["Metadata Quality"]},
				{name:"Interaction Quality", module_name:"Metrics::Qinteraction", evmethods:["Interaction Quality"]}
			]

			addedMetrics = []

			LOEP_VANILLA_Metrics.each do |metric|
				m = Metric.find_by_type(metric[:module_name])
				if m.nil?
					#Create metric
					puts "Creating new metric: " + metric[:name]
					m = metric[:module_name].constantize.new
					m.name = metric[:name]
					m.evmethods.push(Evmethod.find_all_by_name(metric[:evmethods]))
					m.save!
					addedMetrics.push(m)
				else
					if m.name != metric[:name]
						#Update name
						m.update_column :name, metric[:name]
					end
				end
			end

			unless addedMetrics.blank?
				#Create scores for the new metrics
				uploadScoreMetrics = addedMetrics.select{|m| Lo.evaluatedWithEvmethods(m.evmethods).length > 0}
				Rake::Task["db:populate:scores"].reenable
				Rake::Task["db:populate:scores"].invoke(uploadScoreMetrics.map{|m| m.name}.join(","),[])
			end
		end

		task :scores, [:metrics,:evmethods] => :environment do |t, args|
			load("#{Rails.root}/config/initializers/loep.rb")
			puts "Recalculating scores..."
			metrics = Metric.allc
			metrics = (metrics & (Metric.find_all_by_name(args[:metrics].split(",").map{|s| s.strip}))) rescue [] unless args[:metrics].nil?
			metrics.each do |m|
				puts "Recalculating scores for metric: " + m.name
				Lo.all.each do |lo|
					s = Score.new
					s.metric_id = m.id
					s.lo_id = lo.id
					s.save
				end
			end

			puts "Recalculating automatic scores..."
			evmethods = Evmethod.allc_automatic
			evmethods = (evmethods & (Evmethod.find_all_by_name(args[:evmethods].split(",").map{|s| s.strip}))) rescue [] unless args[:evmethods].nil?
			evmethods.each do |evmethod|
				puts "Recalculating scores for automatic evmethod: " + evmethod.name
				Lo.all.each do |lo|
					evmethod.getEvaluationModule.createAutomaticEvaluation(lo)
				end
			end
		end

		task :create_users => :environment do
			#Create users: an admin and a reviewer

			role_sadmin = Role.find_by_name("SuperAdmin")
			role_admin = Role.find_by_name("Admin")
			role_reviewer = Role.find_by_name("Reviewer")
			english = Language.find_by_code("en")
			spanish = Language.find_by_code("es")

			user_admin = User.new
			user_admin.name = "admin"
			user_admin.email = "admin@loep.com"
			user_admin.password = "demonstration"
			user_admin.password_confirmation = "demonstration"
			user_admin.language_id = english.id
			user_admin.languages.push(english)
			user_admin.languages.push(spanish)
			user_admin.occupation = "education"
			user_admin.gender = 1
			user_admin.birthday = Time.now
			user_admin.roles.push(role_sadmin)
			user_admin.roles.push(role_admin)
			user_admin.save!
			puts "Administrator created with email: '" + user_admin.email + "' and password: '" + user_admin.password + "'."

			user_reviewer = User.new
			user_reviewer.name = "reviewer"
			user_reviewer.email = "reviewer@loep.com"
			user_reviewer.password = "demonstration"
			user_reviewer.password_confirmation = "demonstration"
			user_reviewer.language_id = english.id
			user_reviewer.languages.push(english)
			user_reviewer.languages.push(spanish)
			user_reviewer.occupation = "education"
			user_reviewer.gender = 1
			user_reviewer.birthday = Time.now
			user_reviewer.roles.push(role_reviewer)
			user_reviewer.save!
			puts "Reviewer created with email: '" + user_reviewer.email + "' and password: '" + user_reviewer.password + "'."
		end

		#bundle exec rake db:populate:install_plugins
		#bundle exec rake db:populate:install_plugins RAILS_ENV=production
		task :install_plugins => :environment do
			puts "Installing and upgrading plugins"
			
			LOEP::Application.config.enabled_plugins.each do |p|
				if Rake::Task.task_defined?(p + ':install')
					#Install plugin
					
					pluginSettingsInstance = LoepSetting.find_by_key("plugin_" + p)
					pluginSettings = pluginSettingsInstance.nil? ? {} : (JSON.parse(pluginSettingsInstance.value) rescue {})
					installedVersion = pluginSettings["installed_version"]

					require p + '/version'
					currentVersion = eval(p.split(" ")[0].split("_").map{|s| s.downcase.capitalize}.join("") + "::VERSION")

					if !installedVersion.blank? and installedVersion == currentVersion
						puts "LOEP plugin '" + p + " (" + currentVersion + ")' is already installed"
						next
					end

					installed = false
					upgraded = false

					if installedVersion.blank?
						puts "Installing LOEP plugin '" + p + " (" + currentVersion + ")'"
						Rake::Task[p + ':install'].invoke
						installed = true
					elsif Gem::Version.new(currentVersion) > Gem::Version.new(installedVersion)
						puts "Upgrading LOEP plugin '" + p + "' to version " + currentVersion
						if Rake::Task.task_defined?(p + ':upgrade')
							#Update plugin
							Rake::Task[p + ':upgrade'].invoke(installedVersion)
						end
						upgraded = true
					else
						puts "A more recent version (" + installedVersion + ") of the LOEP plugin '" + p + "' was previously installed. No installation was performed."
						next
					end

					pluginSettings["installed_version"] = currentVersion
					pluginSettingsInstance = LoepSetting.new(:key => "plugin_" + p) if pluginSettingsInstance.nil?
					pluginSettingsInstance.value = (pluginSettings.to_json)
					pluginSettingsInstance.save!

					if installed
						puts "The LOEP plugin '" + p + " (" + currentVersion + ")' was succesfully installed"
					elsif upgraded
						puts "The LOEP plugin '" + p + "' was succesfully upgraded to version " + currentVersion
					end
				end
			end
			puts "Task finished"
		end

	end
end