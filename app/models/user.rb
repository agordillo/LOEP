class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :birthday, :gender, :tag_list

  has_and_belongs_to_many :roles

  validates :name,
  :allow_nil => false,
  :length => { :in => 3..255 },
  :uniqueness => {
    :case_sensitive => false
  }

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

  def rol
    self.roles.first.name
  end

  def readable_birthday
    unless self.birthday.nil?
      self.birthday.strftime("%d/%m/%Y")
    else
      ""
    end
  end

end
