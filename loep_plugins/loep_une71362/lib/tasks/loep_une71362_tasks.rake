# encoding: utf-8

namespace :loep_une71362 do
	
	#bundle exec rake loep_une71362:install
	#bundle exec rake loep_une71362:install RAILS_ENV=production
	task :install => :environment do
		desc 'Plugin installation'
		#puts "Installing LOEP plugin: UNE 71362"

		#Create Roles, Languages, Evaluation Models, Metrics and Scores
		Rake::Task["loep_une71362:populate_evmethods"].invoke
		Rake::Task["loep_une71362:populate_metrics"].invoke

		#puts "The plugin 'UNE 71362' was succesfully installed"
	end

	task :populate_evmethods => :environment do
		desc "Create Evaluation Models"
		
		#Create the evaluation models in the database if they are not created
		Plugin_EvMethods = [
			{name:"UNE 71362 - Student", module_name:"Evaluations::Une71362Student", multiple:true, automatic: false},
			{name:"UNE 71362 - Teacher", module_name:"Evaluations::Une71362Teacher", multiple:false, automatic: false}
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
			{name:"UNE 71362 Student AM", module_name:"Metrics::Une71362StudentAm", evmethods:["UNE 71362 - Student"]},
			{name:"UNE 71362 Teacher AM", module_name:"Metrics::Une71362TeacherAm", evmethods:["UNE 71362 - Teacher"]}
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