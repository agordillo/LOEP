class SessionToken < ActiveRecord::Base
  attr_accessible :app_id, :auth_token, :expire_at

  belongs_to :app

  validates :app_id, :presence => true

  validates :auth_token,
  :presence => true,
  :uniqueness => true

  validates :expire_at,
  :presence => true

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
  before_validation :checkExpirationDate


#-------------------------------------------------------------------------------------

  ###########
  # Methods
  ###########

  def expired?
    self.expire_at < Time.now
  end

  def self.deleteExpiredTokens
    expiredSessionTokens = SessionToken.all.select{|s| s.expired?}
    expiredSessionTokens.each do |s|
      s.destroy
    end
  end


  private

  def checkAuthToken
    if self.auth_token.nil?
      self.auth_token = Utils.build_token(SessionToken)
    end
  end

  def checkExpirationDate
    if self.expire_at.nil?
      self.expire_at = Time.now + 12.hours
    end
  end

end
