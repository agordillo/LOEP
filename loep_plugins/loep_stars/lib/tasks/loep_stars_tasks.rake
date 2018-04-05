# encoding: utf-8

namespace :loep_stars do
	
	#bundle exec rake loep_stars:install
	#bundle exec rake loep_stars:install RAILS_ENV=production
	task :install => :environment do
		desc 'Plugin installation'
		#puts "Installing LOEP plugin: Stars"

		#Create Roles, Languages, Evaluation Models, Metrics and Scores
		Rake::Task["loep_stars:populate_evmethods"].invoke
		Rake::Task["loep_stars:populate_metrics"].invoke

		#puts "Remember that to use the new evaluation model 'Star' you need to enable it in the config/application_config.yml file"
		#puts "Remember that to use the new metric 'Star Metric' you need to enable it in the config/application_config.yml file"
		#puts "The plugin 'Stars' was succesfully installed"
	end

	task :populate_evmethods => :environment do
		desc "Create Evaluation Models"
		
		#Create the evaluation models in the database if they are not created
		Plugin_EvMethods = [
			{name:"Star", module_name:"Evaluations::Star", multiple:false, automatic: false}
		]

		addedEvmethods = []

		Plugin_EvMethods.each do |evmethod|
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

	task :populate_metrics => :environment do
		desc "Create Metrics"

		#Create the metrics in the database if they are not created
		Plugin_Metrics = [
			{name:"Star Metric", module_name:"Metrics::Starmetric", evmethods:["Star"]}
		]

		addedMetrics = []

		Plugin_Metrics.each do |metric|
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

end