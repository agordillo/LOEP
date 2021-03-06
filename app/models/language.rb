class Language < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :users
  has_many :los

  validates :name,
  :presence => true,
  :uniqueness => {
    :case_sensitive => false
  }

  validates :code,
  :presence => true,
  :uniqueness => {
    :case_sensitive => false
  }

  def sym
  	self.code.to_sym
  end

  def translated_name
    I18n.t("language."+self.code, :default => self.name)
  end

end
