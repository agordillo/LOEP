$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "loep_une71362/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "loep_une71362"
  s.version     = LoepUne71362::VERSION
  s.authors     = ["Aldo Gordillo"]
  s.email       = ["agordillo@dit.upm.es"]
  s.homepage    = "https://github.com/agordillo/LOEP"
  s.summary     = "LOEP UNE 71362"
  s.description = "This plugin adds support for the teacher and student public profiles defined by the UNE 71362 standard"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.22"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
