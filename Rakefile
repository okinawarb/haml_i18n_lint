require "bundler/gem_tasks"
require "rake/testtask"
require "yard"
# require "yard/rake/yardoc_task"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

YARD::Rake::YardocTask.new do |t|
  # t.files   = ['app/**/*.rb', 'lib/**/*.rb', '-', 'doc/FAQ.md', 'doc/Changes.md']
end

task :default => :test
