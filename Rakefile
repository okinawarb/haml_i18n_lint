require "bundler/gem_tasks"
require "rake/testtask"
require "appraisal"
require "yard"
require "digest/sha2"

version = Bundler::GemHelper.gemspec.version
desc "Create checksum of pkg/haml_i18n_lint-#{version}.gem"
task :checksum do
  built_gem_path = "pkg/haml_i18n_lint-#{version}.gem"
  checksum = Digest::SHA512.new.hexdigest(File.read(built_gem_path))
  mkdir_p 'checksum'
  checksum_path = "checksum/haml_i18n_lint-#{version}.gem.sha512"
  File.write(checksum_path, checksum)
end

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
