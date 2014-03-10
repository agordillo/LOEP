# encoding: utf-8

namespace :db do
  task :populate => :environment do
  	desc "Populating db"
  	puts "Populate start"

  	unless Rails.env == "development" or User.all.length === 0
  		fail "Prevent populate in production without empty database"
  	end

  	if Rails.env == "development"
		#Removing data
		Role.delete_all
		Language.delete_all
		User.delete_all
		Lo.delete_all
		Evmethod.delete_all
		Assignment.delete_all
		Evaluation.delete_all
		App.delete_all
		Metric.delete_all
		Score.delete_all
	end

  	#Create Roles
  	role_sadmin = Role.create!  :name  => "SuperAdmin"
  	role_admin = Role.create!  :name  => "Admin"
  	role_reviewer = Role.create!  :name  => "Reviewer"
	role_user = Role.create!  :name  => "User"

	#Create Languages
	lindependant = Language.new
	lindependant.name = "Language independent"
	lindependant.shortname = "lanin"
	lindependant.save(:validate => false)

	english = Language.new
	english.name = "English"
	english.shortname = "en"
	english.save(:validate => false)

	spanish = Language.new
	spanish.name = "Español"
	spanish.shortname = "es"
	spanish.save(:validate => false)

	german = Language.new
	german.name = "Deutsch"
	german.shortname = "de"
	german.save(:validate => false)

	french = Language.new
	french.name = "Français"
	french.shortname = "fr"
	french.save(:validate => false)

	italiano = Language.new
	italiano.name = "Italiano"
	italiano.shortname = "it"
	italiano.save(:validate => false)
	
	nederlands = Language.new
	nederlands.name = "Nederlands"
	nederlands.shortname = "nl"
	nederlands.save(:validate => false)

	magyar = Language.new
	magyar.name = "Magyar"
	magyar.shortname = "hu"
	magyar.save(:validate => false)

	#Create users
	user_admin = User.new
	user_admin.name = "admin"
	user_admin.email = "admin@loep.com"
	user_admin.password = "admin"
	user_admin.password_confirmation = "admin"
	user_admin.language_id = spanish.id
	user_admin.languages.push(spanish)
	user_admin.languages.push(english)
	user_admin.roles.push(role_sadmin)
	user_admin.roles.push(role_admin)
	user_admin.save(:validate => false)

	user_reviewer = User.new
	user_reviewer.name = "reviewer"
	user_reviewer.email = "reviewer@loep.com"
	user_reviewer.password = "reviewer"
	user_reviewer.password_confirmation = "reviewer"
	user_reviewer.language_id = english.id
	user_reviewer.languages.push(english)
	user_reviewer.languages.push(spanish)
	user_reviewer.roles.push(role_reviewer)
	user_reviewer.save(:validate => false)

	if Rails.env == "development"
		10.times do |i|
			user = User.new
			user.name = Faker::Name.name
			user.email = Faker::Internet.free_email
			user.password = "reviewer"
			user.password_confirmation = "reviewer"
			user.language_id = spanish.id
			user.languages.push(spanish)
			user.roles.push(role_reviewer)
			user.save(:validate => false)
		end
	end

	#Create LOs
	loA = Lo.new
	loA.url = "http://vishub.org/excursions/83"
	loA.name = "Curiosity Flashcard"
	loA.description = "A Flashcard about Curiosity, the car-sized robotic rover exploring Gale Crater on Mars."
	loA.lotype = "VE slideshow"
	loA.repository = "ViSH"
	loA.technology = "HTML"
	loA.language_id = english.id
	loA.hasQuizzes = true
	loA.save(:validate => false)

	loB = Lo.new
	loB.url = "http://vishub.org/excursions/44"
	loB.name = "Chess: The Art of Learning"
	loB.description = "The Art of Learning, a journey in the pursuit of excellence. Amazing presentation with images, videos and 3d objects, generated by Vish Editor."
	loB.lotype = "VE slideshow"
	loB.repository = "ViSH"
	loB.technology = "HTML"
	loB.language_id = spanish.id
	loB.hasQuizzes = false
	loB.hasWebs = true
	loB.save(:validate => false)

	if Rails.env == "development"
		10.times do |i|
			lo = Lo.new
			lo.url = "http://vishub.org/excursions/44"
			lo.name = "LO" + Faker::Name.name.split(" ").pop()
			lo.lotype = "VE slideshow"
			lo.repository = "ViSH"
			lo.technology = "HTML"
			lo.language_id = spanish.id
			lo.save(:validate => false)
		end
	end

	#Create Evaluation Methods
	LORI = Evmethod.new
	LORI.name = "LORI v1.5"
	LORI.module = "LoriEvaluation"
	LORI.save(:validate => false)

	#Create Assignments

	#Admin create an assigment to request the Reviewer to evaluate the Curiosity Flashcard
	asA = Assignment.new
    asA.author_id = user_admin.id
    asA.user_id = user_reviewer.id
    asA.lo_id = loA.id
	asA.status = "Pending"
	#Deadline in one week
	asA.deadline = DateTime.now + 7
	asA.description = "Please, evaluate the following flashcard using LORI (Learning Object Review Instrument)."
	asA.evmethods.push(LORI)
	asA.save(:validate => false)

	#Also evaluate the LO titled: Chess: The Art of Learning
	#Admin create an assigment to request the Reviewer to evaluate the Curiosity Flashcard
	asB = Assignment.new
    asB.author_id = user_admin.id
    asB.user_id = user_reviewer.id
    asB.lo_id = loB.id
	asB.status = "Pending"
	#Deadline in two weeks
	asB.deadline = DateTime.now + 14
	asB.description = "Please, evaluate the following LO using LORI (Learning Object Review Instrument)."
	asB.evmethods.push(LORI)
	asB.save(:validate => false)

	#Create evaluations
	#Reviewer evaluate the Curiosity Flashcard using LORI (Evaluation requested in the assignment)
	evA = Evaluations::Lori.new
	evA.user_id = user_reviewer.id
	evA.lo_id = loA.id
	evA.evmethod_id = LORI.id
	evA.assignment_id = asA.id #not mandatory
	evA.save(:validate => false)

	#Create Metrics
	LORIAM = Metrics::LORIAM.new
	LORIAM.name = "LORI Arithmetic Mean"
	LORIAM.evmethods.push(LORI);
	LORIAM.save(:validate => false)

	LORIWAM = Metrics::LORIWAM.new
	LORIWAM.name = "LORI Weighted Arithmetic Mean"
	LORIWAM.evmethods.push(LORI);
	LORIWAM.save(:validate => false)

	#Create Scores
	Metric.all.each do |m|
		Lo.all.each do |lo|
			s = Score.new
			s.metric_id = m.id
			s.lo_id = lo.id
			s.save
		end
	end

	puts "Populate finish"
  end

end