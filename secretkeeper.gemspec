$:.push File.expand_path("../lib", __FILE__)

require "secretkeeper/version"

Gem::Specification.new do |s|
  s.name        = "secretkeeper"
  s.version     = Secretkeeper::VERSION
  s.authors     = ["Igor Korepanov"]
  s.email       = ["secretkeeper.gem@gmail.com"]
  s.homepage    = "https://github.com/igorkorepanov/secretkeeper"
  s.summary     = "Token based authentication"
  # s.description = "Token based authentication"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4"

  s.add_development_dependency "rspec-rails", "~>3.6"
  s.add_development_dependency "rspec-activemodel-mocks", "~>1.0"
  s.add_development_dependency "factory_girl_rails", "~> 4.8"
  s.add_development_dependency "generator_spec", "~>0.9.4"
end
