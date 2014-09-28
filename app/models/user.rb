class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

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
  :exclusion => { in: "all", message: I18n.t("dictionary.errors.reserved_word") }

  validates :birthday, :presence => { :message => I18n.t("dictionary.errors.blank") }
  validates :gender, :presence => { :message => I18n.t("dictionary.errors.blank") }
  validates :roles, :presence => { :message => I18n.t("dictionary.errors.blank") }
  validates :language_id, :presence => { :message => I18n.t("dictionary.errors.blank") }
  validates :language_id, :exclusion => { :in => [-1], :message => I18n.t("dictionary.errors.unspecified")}
  validates :occupation, :presence => { :message => I18n.t("dictionary.errors.blank") }
  validates_inclusion_of :occupation, :in => I18n.t("occupations", :locale => :en).map{|k,v| k.to_s}, :allow_nil => false, :message => ": " + I18n.t("dictionary.invalid")

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

  def readable_role
    self.role.readable unless self.role.nil?
  end

  def readable_occupation
    I18n.t("occupations."+self.occupation.downcase) unless self.occupation.nil?
  end


  #Methods

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

  def getLanguages
    unless self.languages.empty?
      self.languages.map { |l| l.id }
    end
  end

  def compareUsers(user)
    if self.compareRole != user.compareRole
      return self.compareRole <=> user.compareRole
    else
       return self.created_at <=> user.created_at
    end
  end


  #Role Management

  def role
    self.roles.sort_by{|r| r.comparisonValue }.reverse.first
  end

  def role_name
    role.name unless role.nil?
  end

  def role?(role)
    return !!self.roles.find_by_name(role.to_s.camelize)
  end

  def isAdmin?
    return self.role?("Admin") || self.role?("SuperAdmin")
  end

  def assignRole(newRole,delete=true)
    if self.role?("SuperAdmin") or newRole.nil?
      #SuperAdmin is always superAdmin
      return
    end

    if delete
      self.roles.delete_all
    end
    self.roles.push(newRole)

    if newRole.name == "SuperAdmin"
      self.roles.push(Role.admin);
    end
  end

  def addRole(newRole)
    assignRole(newRole,false)
  end

  def compareRole
    return self.role.comparisonValue
  end

  def canChangeRole?(user, newRole)
    unless self.isAdmin?
      return false
    end

    unless self.compareRole > user.compareRole or self.id == user.id
      return false
    end

    unless !newRole.nil? and self.compareRole >= newRole.comparisonValue
      return false
    end

    return true
  end


  #Class extra attrs and methods
  def self.superAdmins
    Role.admin.users
  end

  def self.admins
    (Role.superadmin.users + Role.admin.users).uniq
  end

  def self.reviewers
    Role.reviewer.users
  end

  def self.users
    Role.user.users
  end


  private

  def checkLanguages
    if !self.languages.include? Language.find(self.language_id)
      self.languages.push(Language.find(self.language_id))
    end
  end

end
