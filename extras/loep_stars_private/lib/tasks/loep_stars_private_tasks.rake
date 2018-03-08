namespace :loep_stars_private do
	#bundle exec rake loep_stars_private:install
	#bundle exec rake loep_stars_private:install RAILS_ENV=production
	task :install => :environment do
		desc 'Plugin installation'
		puts "Installing LOEP plugin 'Stars Private'"

		#A. Create a new ev method

		#Check that the evmethod doesn't exists
		ev = Evmethod.where(:module => "Evaluations::Starp").first
		abort("Task aborted. An evaluation model with module 'Evaluations::Starp' already exists.") unless ev.nil?

		#Create database instance for the evmethod
		ev = Evmethod.new
		ev.name = "Starp"
		ev.module = "Evaluations::Starp"
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
		evMethods = (Evmethod.find_all_by_name("Starp".split(",").map{|s| s.strip})) rescue []
		abort("Task aborted. Evmethod 'Starp' not found.") if evMethods.blank?

		#Check that the metric doesn't exists
		m = Metric.where(:name => "Starp Metric").first
		abort("Task aborted. A metric with name 'Starp Metric' already exists.") unless m.nil?

		#Create database instance for the metric
		m = Metrics::Starp_metric.new
		m.name = "Starp Metric"
		m.evmethods.push(evMethods)
		m.valid?

		unless m.errors.blank? and m.save
			puts "Some error has ocurred:"
			puts m.errors.full_messages
			abort("Task aborted.")
		end

		puts "Remember that to use the new evaluation model 'Starp' you need to enable it in the config/application_config.yml file"
		puts "Remember that to use the new metric 'Starp Metric' you need to enable it in the config/application_config.yml file"
    	puts "The plugin was succesfully installed"
	end
end