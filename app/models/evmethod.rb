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

  def self.allc
    Evmethod.where("name in (?)",LOEP::Application.config.evmethod_names)
  end

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
    Rails.application.routes.url_helpers.evmethods_path + "/" + self.shortname
  end

  def documentation_path
    # e.g. '/evmethods/lori/documentation'
    self.root_path + "/documentation"
  end

  def representation_path
    # e.g. '/evmethods/lori/representation'
    self.root_path + "/representation"
  end

  #############
  # Nick Name for Paths
  #############

  def shortname
    self.module.split("Evaluations::")[1].downcase
  end

  def self.getShortnameFromName(name)
    Evmethod.find_by_name("LORI v1.5").shortname
  end

  def self.getNameFromShortname(shortname)
    Evmethod.getEvMethodFromShortname(shortname).name
  end

  def self.getEvMethodFromShortname(shortname)
    Evmethod.find_by_module("Evaluations::" + shortname.capitalize)
  end

  def getEvaluationModule
    self.module.constantize
  end

  #############
  # Utils
  #############

  def hasDocumentation
    lookup_context.template_exists?("documentation", "evmethods/"+self.shortname, true)
  end

  def hasRepresentation
    lookup_context.template_exists?("representation", "evmethods/"+self.shortname, true)
  end

end
