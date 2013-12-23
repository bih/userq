$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "userq/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "userq"
  s.version     = UserQ::VERSION
  s.authors     = ["Bilawal Hameed"]
  s.email       = ["bilawal@studenthack.com"]
  s.homepage    = "http://studenthack.github.io/userq"
  s.summary     = "Lightweight user-based queue for Rails."
  s.description = "Designed to improve user experience, UserQ helps you queue users until space is available in the queue. Example usage is ticket sales."

  s.files       = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files  = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "json"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "json"
end
