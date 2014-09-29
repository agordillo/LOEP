class Icode < ActiveRecord::Base
  attr_accessible :code, :expire_at, :role_id, :owner_id, :permanent

  belongs_to :role
  belongs_to :user, :foreign_key => "owner_id"

  validates :code, :presence => true, :uniqueness => true
  validates :expire_at, :presence => true
  validates :role_id, :presence => true

  validate :check_code

  def check_code
    if !self.code.is_a? String
      errors.add(:code, I18n.t("dictionary.invalid").downcase)
    elsif self.code.length < 10
      errors.add(:code, I18n.t("dictionary.errors.too_short"))
    else
      true
    end
  end

  validates :owner_id, :presence => { :message => I18n.t("dictionary.errors.unspecified") }

  before_validation :checkCode
  before_validation :checkExpirationDate


#-------------------------------------------------------------------------------------

  ###########
  # Methods
  ###########

  def owner
    user
  end

  def getRole
    unless self.expired?
      self.role
    else
      nil
    end
  end

  def expired?
    self.expire_at < Time.now
  end

  def invalidate(force=false)
    unless self.permanent and force==false
      self.expire_at = Time.now
      self.save!
    end
  end

  def self.getValidIcodes
    Icode.where("expire_at > ?", Time.now)
  end

  def self.deleteExpiredIcodes
    expiredIcodes = Icode.where("expire_at < ?", Time.now)
    expiredIcodes.each do |ic|
      ic.destroy
    end
  end

  def invitation_url
    LOEP::Application.config.full_domain + Rails.application.routes.url_helpers.new_user_registration_path + "?icode=" + self.code.to_s
  end

  def readable_type
    if self.permanent
      I18n.t("dictionary.permanent.permanent")
    else
      I18n.t("dictionary.permanent.oneuse")
    end
  end


  private

  def checkCode
    if self.code.nil?
      self.code = Utils.build_token(Icode,16,"code")
    end
  end

  def checkExpirationDate
    if self.expire_at.nil?
      unless self.permanent===true
        self.expire_at = Time.now + 15.days
      else
        self.expire_at = Time.now + 1000.years
      end
    end
  end

end
