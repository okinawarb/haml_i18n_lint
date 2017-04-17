$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "haml/i18n_lint"
require "test/unit"

class Haml::I18nLint::TestCase < Test::Unit::TestCase
  class << self
    def startup
      @old_pwd = Dir.pwd
      Dir.chdir(File.expand_path("fixtures", __dir__))
      super
    end

    def shutdown
      Dir.chdir(@old_pwd)
      @old_pwd = nil
    end
  end
end
