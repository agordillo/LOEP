namespace :db do
  task :populate => :environment do
  	desc "Populating db"

  	#Removing data
  	Role.delete_all
  	User.delete_all

  	#Creating Roles
  	role_admin = Role.create!  :name  => "Admin"
  	role_reviewer = Role.create!  :name  => "Reviewer"
	role_user = Role.create!  :name  => "User"

	#Creating users
	user_admin = User.new
	user_admin.name = "admin"
	user_admin.email = "admin@loep.com"
	user_admin.password = "admin"
	user_admin.password_confirmation = "admin"
	user_admin.roles.push(role_admin) #Role.first
	user_admin.save(:validate => false)

	user_reviewer = User.new
	user_reviewer.name = "reviewer"
	user_reviewer.email = "reviewer@loep.com"
	user_reviewer.password = "reviewer"
	user_reviewer.password_confirmation = "reviewer"
	user_reviewer.roles.push(role_reviewer)
	user_reviewer.save(:validate => false)

	puts "Populate finish"
  end
end