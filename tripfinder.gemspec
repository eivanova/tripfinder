# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tripfinder/version.rb'
   
Gem::Specification.new do |s|
  s.name        = "tripfinder"
  s.version     = Tripfinder::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Elena Ivanova"]
  s.summary     = "Find trips for your vacation"
  s.description = "Searches data and builds routes in the mountains based on user preferences"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.files        = Dir.glob("{lib,datasets}/**/*") + %w(LICENSE)
end
