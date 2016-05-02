class SessionToken < ActiveRecord::Base
  attr_accessible :app_id, :auth_token, :expire_at, :permanent, :multiple, :hours, :action, :action_params
  attr_accessor :hours

  belongs_to :app

  before_validation :checkAuthToken
  before_validation :checkExpirationDate
  before_validation :checkAction

  validates :app_id, :presence => true
  validates :auth_token, :presence => true, :uniqueness => true
  validates :expire_at, :presence => true
  validates :action, :presence => true
  validates_inclusion_of :action, :in => ["all", "evaluate", "showchart"], :allow_nil => false, :message => ": " + I18n.t("dictionary.invalid")
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

  def self.expired
    self.where("expire_at < ?", Time.now)
  end

  ###########
  # Methods
  ###########

  def owner
    app
  end

  def expired?
    self.expire_at.nil? or self.expire_at < Time.now
  end

  def invalidate
    self.expire_at = Time.now
    self.save!
  end

  def hours_to_expire
    return 0 if expired?
    ((self.expire_at - Time.now)/3600).ceil
  end

  def allow_to?(action,params={})
    return false if self.expired?
    return false if self.action!="all" and self.action!=action
    #Check params
    selfActionParams = self.parsed_action_params
    selfActionParams.each do |k,v|
      return false if selfActionParams[k].to_s!=params[k].to_s
    end
    true
  end

  def parsed_action_params
    return {} if self.action_params.blank?
    JSON.parse(self.action_params) rescue {}
  end

  def lo
    self.app.los.find_by_id(parsed_action_params["lo"]) unless self.app.nil? or parsed_action_params.blank?
  end

  def evmethod
    Evmethod.allc.find_by_id(parsed_action_params["evmethod"]) unless parsed_action_params.blank?
  end

  def link
    return nil if self.expired?
    link = LOEP::Application.config.full_domain + "/"

    actionParams = self.parsed_action_params
    lo = Lo.find_by_id(actionParams["lo"])
    return nil if lo.nil? or lo.id_repository.blank? or lo.repository.blank?
    evMethod = Evmethod.allc.find_by_id(actionParams["evmethod"])
    return nil if evMethod.nil?

    case self.action
    when "evaluate"
      link += "evaluations/" + evMethod.shortname.pluralize + "/embed?lo_id=" + lo.id_repository + "&repository=" + lo.repository
    when "showchart"
      link += "los/" + lo.id_repository + "/representation?evmethods=" + evMethod.shortname + "&repository=" + lo.repository
    else
      return nil
    end

    link += "&app_name=" + self.app.name + "&session_token=" + self.auth_token + "&locale=" + I18n.locale.to_s
    # link += "&ajax=true"
    link
  end


  private

  def checkAuthToken
    self.auth_token = Utils.build_token(SessionToken) if self.auth_token.nil?
  end

  def checkExpirationDate
    if self.permanent
      self.expire_at = Time.now + 1000.years if self.expire_at.nil?
    else
      if (self.hours.is_a? String and self.hours.is_numeric? and self.hours.to_i > 0)
        self.expire_at = Time.now + (self.hours.to_i).hours
      end
      self.expire_at = Time.now + 12.hours if self.expire_at.nil?
    end
  end

  def checkAction
    self.action = "all" if self.action.nil?
    self.action_params = self.action_params.to_json rescue nil unless self.action_params.is_a? String
  end

end
