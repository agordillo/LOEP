class Evmethod < ActiveRecord::Base
  attr_accessible :name, :module
  has_and_belongs_to_many :assignments
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

  def new_evaluation_path(lo)
    evaluationModule = getEvaluationModule
    # controller_name = self.module.underscore + "s"
    helper_method_name = "new_" + self.module.underscore + "_path"
    new_evaluation_path = Rails.application.routes.url_helpers.send(helper_method_name)

    #Add params
    new_evaluation_path + "?lo_id=" + lo.id.to_s
  end

  def new_evaluation_path_with_assignment(assignment)
    new_evaluation_path(assignment.lo) + "&assignment_id=" + assignment.id.to_s
  end

  def documentation_path
    Rails.application.routes.url_helpers.evmethods_path + "/" + self.nickname
  end

  def nickname
    self.name.split(/\s+/).join("__").gsub(/\./, "_")
    # URI.encode(self.name)
  end

  def self.getEvMethodFromNickname(nickname)
    name = nickname.gsub(/\_/, ".").split("__").join(" ")
    # name = URI.decode(nickname)
    Evmethod.find_by_name(name);
  end

  def getEvaluationModule
    klass = self.module
    evaluationModule = klass.singularize.classify.constantize
  end

end
