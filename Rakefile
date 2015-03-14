require 'rake/testtask'
require 'rspec/core/rake_task'

task :default => [:spec, :unit]

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "test/*_spec.rb"
end

Rake::TestTask.new(:unit) do |t|
  t.test_files = FileList.new("test/*_test.rb")
end

Rake::TestTask.new(:integration) do |t|
  t.pattern = "test/integration/*_test.rb"
end
