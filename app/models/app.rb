class App < ActiveRecord::Base
  attr_accessible :user_id, :name, :auth_token, :callback

  belongs_to :user

  validates :user_id, :presence => true

  validates :name,
  :presence => true,
  :uniqueness => {
    :case_sensitive => false
  }

  validate :name_blank

  def name_blank
    if self.name.blank?
      errors.add(:emethods, "Name can't be blank")
    else
      true
    end
  end

  validates :auth_token,
  :presence => true,
  :uniqueness => true

  validate :check_auth_token

  def check_auth_token
    if !self.auth_token.is_a? String
      errors.add(:authentication_token, "invalid")
    elsif self.auth_token.length < 32
      errors.add(:authentication_token, "is too short")
    else
      true
    end
  end

  before_validation :checkAuthToken


#-------------------------------------------------------------------------------------

  private

  def checkAuthToken
    if self.auth_token.nil?
      self.auth_token = Utils.build_token(60)
    end
  end

end
