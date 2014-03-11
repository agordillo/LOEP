class Evmethod < ActiveRecord::Base
  attr_accessible :name, :module
  
  has_many :assignments, :dependent => :destroy
  has_and_belongs_to_many :metrics
  has_many :evaluations, :dependent => :destroy

  validates :name,
  :presence => true,
  :length => { :in => 2..255 },
  :uniqueness => {
    :case_sensitive => false
  }
  validates :module,
  :presence => true,
  :length => { :in => 2..255 },
  :uniqueness => {
    :case_sensitive => false
  }

  #############
  #Paths
  #############

  def new_evaluation_path(lo)
    evaluationModule = getEvaluationModule
    helper_method_name = "new_" + self.module.gsub(":","").underscore + "_path"
    new_evaluation_path = Rails.application.routes.url_helpers.send(helper_method_name)

    #Add params
    new_evaluation_path + "?lo_id=" + lo.id.to_s
  end

  def new_evaluation_path_with_assignment(assignment)
    new_evaluation_path(assignment.lo) + "&assignment_id=" + assignment.id.to_s
  end

  def root_path
    (Rails.application.routes.url_helpers.evmethods_path + "/" + self.nickname).downcase
  end

  def documentation_path
    self.root_path
  end

  def representation_path
    # puts '/evmethods/lori__v1_5'
    (self.root_path + "_representation").downcase
  end

  #############
  # Nick Name for Paths
  #############

  def nickname
    self.class.getNicknameFromName(self.name)
  end

  def self.getNicknameFromName(name)
    name.split(/\s+/).join("__").gsub(/\./, "_")
  end

  def self.getNameFromNickname(nickname)
    nickname.gsub(/\_/, ".").split("__").join(" ")
  end

  def self.getEvMethodFromNickname(nickname)
    name = getNameFromNickname(nickname)
    Evmethod.find_by_name(name)
  end

  def getEvaluationModule
    klass = self.module
    evaluationModule = klass.singularize.classify.constantize
  end

end
