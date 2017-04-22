$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "haml/i18n_lint"
require "test/unit"
require "tempfile"

class Haml::I18nLint::TestCase < Test::Unit::TestCase
  # When get assert {} error message, chdir cause problem if execute single test file like following
  #     $ bundle exec ruby test/haml/runner_test.rb
  #     => Error: test_foo(Haml::I18nLint::RunnerTest): Errno::ENOENT: No such file or directory @ rb_sysopen - test/haml/i18n_lint/runner_test.rb
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
    options = ::Haml::I18nLint::Options.new
    tempfile = Tempfile.open { |fp| fp.puts(config); fp }
    yield tempfile.path
  ensure
    tempfile.close
  end
end
