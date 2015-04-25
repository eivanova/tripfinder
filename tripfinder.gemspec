# -*- encoding: utf-8 -*-
require_relative 'bin/config'
   
Gem::Specification.new do |s|
  s.name        = "tripfinder"
  s.version     = TripfinderGem.VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Elena Ivanova"]
  s.summary     = "Find trips for your vacation"
  s.description = "Searches data and builds routes in the mountains based on user preferences"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.files        = Dir.glob("{bin,datasets}/**/*") + %w(LICENSE)
end
