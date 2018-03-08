namespace :loep_stars do
	#bundle exec rake loep_stars:install
	#bundle exec rake loep_stars:install RAILS_ENV=production
	task :install => :environment do
		desc 'Plugin installation'
		puts "Installing LOEP plugin 'Stars'"

		#A. Create a new ev method

		#Check that the evmethod doesn't exists
		ev = Evmethod.where(:module => "Evaluations::Star").first
		abort("Task aborted. An evaluation model with module 'Evaluations::Star' already exists.") unless ev.nil?

		#Create database instance for the evmethod
		ev = Evmethod.new
		ev.name = "Star"
		ev.module = "Evaluations::Star"
		ev.allow_multiple_evaluations = false
		ev.automatic = false
		ev.valid?

		unless ev.errors.blank? and ev.save
			puts "Some error has ocurred:"
			puts ev.errors.full_messages
			puts ""
			abort("Task aborted.")
		end


		#B. Create a new metric

		#Validate evmethods
		evMethods = (Evmethod.find_all_by_name("Star".split(",").map{|s| s.strip})) rescue []
		abort("Task aborted. Evmethod 'Star' not found.") if evMethods.blank?

		#Check that the metric doesn't exists
		m = Metric.where(:name => "Star Metric").first
		abort("Task aborted. A metric with name 'Star Metric' already exists.") unless m.nil?

		#Create database instance for the metric
		m = Metrics::Starmetric.new
		m.name = "Star Metric"
		m.evmethods.push(evMethods)
		m.valid?

		unless m.errors.blank? and m.save
			puts "Some error has ocurred:"
			puts m.errors.full_messages
			abort("Task aborted.")
		end

		puts "Remember that to use the new evaluation model 'Star' you need to enable it in the config/application_config.yml file"
		puts "Remember that to use the new metric 'Star Metric' you need to enable it in the config/application_config.yml file"
    	puts "The plugin was succesfully installed"
	end
end