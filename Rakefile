require "bundler/gem_tasks"
require "rake/testtask"
require "appraisal"
require "yard"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

YARD::Rake::YardocTask.new

if ENV["APPRAISAL_INITIALIZED"] || ENV["TRAVIS"]
  task default: :test
else
  task default: :appraisal
end
