$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "userq/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "userq"
  s.version     = UserQ::VERSION
  s.authors     = ["Bilawal Hameed"]
  s.email       = ["bilawal@studenthack.com"]
  s.homepage    = "http://github.com/studenthack/userq"
  s.summary     = "Lightweight user-based queue for Rails."
  s.description = "UserQ allows you to very quickly integrate awesome user-based queues into your Rails application."

  s.files       = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files  = Dir["test/**/*"]

  s.add_dependency "rails", "> 4.0.0"

  s.add_development_dependency "sqlite3"

  s.add_runtime_dependency "json"
end
