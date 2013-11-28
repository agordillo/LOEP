namespace :db do
  task :populate => :environment do
  	desc "Populating db"

  	#Creating Roles
  	role_admin = Role.create!  :name  => "Admin"
	role_user = Role.create!  :name  => "User"

	#Creating users
	user_admin = User.new
	user_admin.name = "admin"
	user_admin.email = "agordillo@dit.upm.es"
	user_admin.password = "admin"
	user_admin.password_confirmation = "admin"
	user_admin.roles.push(role_admin) #Role.first
	user_admin.save(:validate => false)


	puts "Populate finish"
  end
end