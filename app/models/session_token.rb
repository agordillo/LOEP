class SessionToken < ActiveRecord::Base
  attr_accessible :app_id, :auth_token, :expire_at, :permanent

  belongs_to :app

  validates :app_id, :presence => true
  validates :auth_token, :presence => true, :uniqueness => true
  validates :expire_at, :presence => true

  validate :check_auth_token

  def check_auth_token
    if !self.auth_token.is_a? String
      errors.add(:authentication_token, I18n.t("dictionary.invalid").downcase)
    elsif self.auth_token.length < 32
      errors.add(:authentication_token, I18n.t("dictionary.errors.too_short"))
    else
      true
    end
  end

  before_validation :checkAuthToken
  before_validation :checkExpirationDate


#-------------------------------------------------------------------------------------

  ###########
  # Class Methods
  ###########
  
  def self.deleteExpiredTokens   
    expiredSessionTokens = SessionToken.where("expire_at < ?", Time.now)
    expiredSessionTokens.each do |s|
      s.destroy
    end
  end

  ###########
  # Methods
  ###########

  def owner
    app
  end

  def expired?
    self.expire_at < Time.now
  end

  def invalidate(force=false)
    return if self.permanent and force==false
    self.expire_at = Time.now
    self.save!
  end

  def hours_to_expire
    return 0 if expired?
    ((self.expire_at - Time.now)/3600).ceil
  end


  private

  def checkAuthToken
    self.auth_token = Utils.build_token(SessionToken) if self.auth_token.nil?
  end

  def checkExpirationDate
    if self.expire_at.nil?
      unless self.permanent===true
        self.expire_at = Time.now + 12.hours
      else
        self.expire_at = Time.now + 1000.years
      end
    end
  end

end
