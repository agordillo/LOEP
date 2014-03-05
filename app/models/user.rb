class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :birthday, :gender, :tag_list, :language_id, :languages

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :languages
  belongs_to :language
  has_many :assignments, :dependent => :destroy
  has_many :los, through: :assignments #and through evaluations...
  has_many :evaluations
  belongs_to :loric

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

  #---------------------------------------------------------------------------------

  def role
    if self.role?("SuperAdmin")
      "SuperAdmin"
    else
      self.roles.first.name
    end
  end

  def role?(role)
    return !!self.roles.find_by_name(role.to_s.camelize)
  end

  def isAdmin?
    return self.role?("Admin") || self.role?("SuperAdmin")
  end

  def readable_birthday
    unless self.birthday.nil?
      self.birthday.strftime("%d/%m/%Y")
    else
      ""
    end
  end

  def age
    unless self.birthday.nil?
      age = Date.today.year - self.birthday.year
      age -= 1 if Date.today < self.birthday.to_date + age.years #for days before birthday
      return age
    end
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

  def self.reviewers
    reviewers = []
    User.find_each do |user|
      if user.role?("Reviewer")
        reviewers << user
      end
    end
    reviewers
  end

  def getLanguages
    unless self.languages.empty?
      self.languages.map { |l| l.id }
    end
  end

  def checkLanguages
    if !self.languages.include? Language.find(self.language_id)
      self.languages.push(Language.find(self.language_id))
    end
  end

end
