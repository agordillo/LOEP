class Icode < ActiveRecord::Base
  attr_accessible :code, :expire_at, :role_id, :permanent

  belongs_to :role

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

  before_validation :checkCode
  before_validation :checkExpirationDate


#-------------------------------------------------------------------------------------

  ###########
  # Methods
  ###########

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
    Icode.all.reject{|ic| ic.expired?}
  end

  def self.deleteExpiredIcodes
    expiredIcodes = Icode.all.select{|ic| ic.expired?}
    expiredIcodes.each do |ic|
      ic.destroy
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
      self.expire_at = Time.now + 15.days
    end
  end

end
