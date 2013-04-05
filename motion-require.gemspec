# -*- encoding: utf-8 -*-
require File.expand_path('../lib/motion-require/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "motion-require"
  s.version     = Motion::Require::VERSION
  s.authors     = ["Clay Allsopp"]
  s.email       = ["clay@usepropeller.com"]
  s.homepage    = "https://github.com/clayallsopp/motion-require"
  s.summary     = "Dependency management for RubyMotion, using a pseudo `require`"
  s.description = "Dependency management for RubyMotion, using a pseudo `require`"

  s.files         = `git ls-files`.split($\)
  s.require_paths = ["lib"]
  s.test_files  = Dir.glob("spec/**/*.rb")
  s.add_development_dependency 'rspec', '~> 2.5'
end