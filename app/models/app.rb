class App < ActiveRecord::Base
  attr_accessible :user_id, :name, :auth_token, :callback

  belongs_to :user
  has_many :los
  has_many :evaluations
  has_many :session_token

  validates :user_id, :presence => true

  validates :name,
  :presence => true,
  :uniqueness => {
    :case_sensitive => false
  }

  validate :name_blank

  def name_blank
    if self.name.blank?
      errors.add(:emethods, I18n.t("dictionary.errors.name_blank"))
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
      errors.add(:authentication_token, I18n.t("dictionary.invalid").downcase)
    elsif self.auth_token.length < 32
      errors.add(:authentication_token, I18n.t("dictionary.errors.too_short"))
    else
      true
    end
  end

  before_validation :checkAuthToken

  ###########
  # Methods
  ###########

  def valid_session_tokens
    self.session_token.reject{|s| s.expired? }.sort_by{|s| s.expire_at }.reverse
  end

  def isSessionTokenValid(sessionToken)
    valid_session_tokens.map{ |s| s.auth_token }.include? sessionToken
  end

  def create_session_token
    s = SessionToken.new
    s.app_id = self.id
    s.save!
    s
  end

  def current_session_token
    currentToken = valid_session_tokens.first
    if currentToken.nil? or ((currentToken.expire_at-Time.now)/(60*60)<6)
      currentToken = create_session_token
    end
    currentToken
  end


#-------------------------------------------------------------------------------------

  private

  def checkAuthToken
    if self.auth_token.nil?
      self.auth_token = Utils.build_token(App)
    end
  end

end
