class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :birthday, :gender, :tag_list, :language_id, :languages, :occupation

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :languages
  belongs_to :language
  belongs_to :loric, :class_name => "Surveys::Loric", :foreign_key => "loric_id"
  has_many :assignments, :dependent => :destroy
  has_many :evaluations
  has_many :los, through: :evaluations
  has_many :apps
  
  before_save :checkLanguages

  validates :name,
  :allow_nil => false,
  :length => { :in => 3..255 },
  :uniqueness => {
    :case_sensitive => false
  },
  :exclusion => { in: "all", message: "is a reserved word" }

  validates :birthday, :presence => { :message => "can't be blank" }
  validates :gender, :presence => { :message => "can't be blank" }
  validates :roles, :presence => { :message => "can't be blank" }
  validates :language_id, :presence => { :message => "can't be blank" }
  validates :language_id, :exclusion => { :in => [-1], :message => "has to be specified."}
  validates :occupation, :presence => { :message => "can't be blank" }
  validates_inclusion_of :occupation, :in => ["Education", "Technology", "Other"], :allow_nil => false, :message => ": Invalid field of expertise"

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login
  attr_accessible :login

  ### This is the correct devise method i override with the code below
  ### def self.find_for_database_authentication(warden_conditions)
  ### end
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def confirmation_required?
    false
  end

  #acts_as_taggable
  # Alias for acts_as_taggable_on :tags
  acts_as_taggable

  #CanCan. Allow to check abilities in the following way: user.can?(:action,@object)
  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, :to => :ability

  #---------------------------------------------------------------------------------

  #Extra Attrs

  def role
    if self.role?("SuperAdmin")
      "SuperAdmin"
    else
      self.roles.first.name
    end
  end

  def age
    unless self.birthday.nil?
      age = Date.today.year - self.birthday.year
      age -= 1 if Date.today < self.birthday.to_date + age.years #for days before birthday
      return age
    end
  end

  def readable_birthday
    unless self.birthday.nil?
      self.birthday.strftime("%d/%m/%Y")
    else
      ""
    end
  end

  #Get Learning Objects evaluated by this user
  def evLos
    self.los.uniq
  end

  #Get Learning Objects assigned to this user
  def asLos
    self.assignments.map{ |as| as.lo }.uniq
  end

  #Get Learning Objects both evaluated ny and assigned to this user
  def allLos
    (evLos+asLos).uniq
  end

  #Get LOs submitted by the user
  def getSubmittedLos
    Lo.where(:owner_id=>self.id)
  end

  #Extra Getters
  def getLanguages
    unless self.languages.empty?
      self.languages.map { |l| l.id }
    end
  end


  #Methods
  def checkLanguages
    if !self.languages.include? Language.find(self.language_id)
      self.languages.push(Language.find(self.language_id))
    end
  end


  #Role Management

  def role?(role)
    return !!self.roles.find_by_name(role.to_s.camelize)
  end

  def isAdmin?
    return self.role?("Admin") || self.role?("SuperAdmin")
  end

  def assignRole(newRoleName)
    if self.role?("SuperAdmin")
      #SuperAdmin is always superAdmin
      return
    end

    newRole = Role.find_by_name(newRoleName)
    if !newRole.nil?
      self.roles.delete_all
      self.roles.push(newRole)
      if newRole.name == "SuperAdmin"
        self.roles.push(Role.find_by_name("Admin"));
      end
    end
  end

  def compareRole
    if self.role == "SuperAdmin"
      return 4
    elsif self.role == "Admin"
      return 3
     elsif self.role == "Reviewer"
      return 2
     else
      return 1
    end
  end

  def compareUsers(user)
    if self.compareRole != user.compareRole
      return self.compareRole <=> user.compareRole
    else
       return self.created_at <=> user.created_at
    end
  end

  def check_permissions_to_change_role(current_user, newRole)
    unless current_user.role?("SuperAdmin") || current_user.role?("Admin")
      return false
    end

    if self.role?("SuperAdmin")
      return false
    end

    #SuperAdmin can change any role to any user (unless other SuperAdmins)
    if current_user.role?("SuperAdmin")
      return true
    end

    #current_user is Admin and self is not SuperAdmin

    if newRole=="SuperAdmin"
      return false
    end

    #Admins can change the role of other users that aren't admins
    #Admins cannot create SuperAdmins
    unless self.role?("Admin")
      return true
    end 

    #current_user is Admin and self is Admin too, newRole is not SuperAdmin

    #Admin can change its own role
    if current_user.id == self.id
      return true
    end

    return false
  end


  #Class extra attrs and methods
  def self.superAdmins
    sadmins = []
    User.find_each do |user|
      if user.role?("SuperAdmin")
        sadmins << user
      end
    end
    sadmins
  end

  def self.admins
    admins = []
    User.find_each do |user|
      if user.isAdmin?
        admins << user
      end
    end
    admins
  end

  def self.reviewers
    reviewers = []
    User.find_each do |user|
      if user.role?("Reviewer")
        reviewers << user
      end
    end
    reviewers
  end

end
