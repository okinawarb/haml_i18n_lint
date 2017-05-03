require 'yaml'
travis_yml_path = File.expand_path('../.travis.yml', __dir__)
travis_yml = YAML.load_file(travis_yml_path)
ruby_version = travis_yml.fetch('rvm').first
if ENV['TRAVIS'] && RUBY_VERSION == ruby_version
  require 'coveralls'
  Coveralls.wear!
end

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "haml_i18n_lint"
require "test/unit"
require "tempfile"
require "tmpdir"

class HamlI18nLint::TestCase < Test::Unit::TestCase
  # When get assert {} error message, chdir cause problem if execute single test file like following
  #     $ bundle exec ruby test/haml_i18n_lint/runner_test.rb
  #     => Error: test_foo(HamlI18nLint::RunnerTest): Errno::ENOENT: No such file or directory @ rb_sysopen - test/haml_i18n_lint/runner_test.rb
  # class << self
  #   def startup
  #     @old_pwd = Dir.pwd
  #     Dir.chdir(File.expand_path("fixtures", __dir__))
  #     super
  #   end

  #   def shutdown
  #     Dir.chdir(@old_pwd)
  #     @old_pwd = nil
  #   end
  # end

  def with_config(config:)
    options = ::HamlI18nLint::Options.new
    tempfile = Tempfile.open { |fp| fp.puts(config); fp }
    yield tempfile.path
  ensure
    tempfile.close
  end

  def with_template(filename: 'temp.html.haml', template:)
    Dir.mktmpdir do |dir|
      File.open(File.join(dir, filename), 'w') { |fp| fp.puts(template); fp }
      Dir.chdir(dir) { yield }
    end
  end

  module SuppressRunnerOutput
    def run(result)
      capture_output { return super }
    end
  end
end
