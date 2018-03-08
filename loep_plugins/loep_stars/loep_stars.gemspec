$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "loep_stars/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "loep_stars"
  s.version     = LoepStars::VERSION
  s.authors     = ["Aldo Gordillo"]
  s.email       = ["agordillo@dit.upm.es"]
  s.homepage    = "https://github.com/agordillo/LOEP"
  s.summary     = "LOEP Stars"
  s.description = "A simple template for LOEP plugins"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  
  s.add_dependency "rails", "~> 3.2.22"
end
