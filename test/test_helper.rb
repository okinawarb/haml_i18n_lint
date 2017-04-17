$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "haml/i18n_lint"
require "test/unit"

class Haml::I18nLint::TestCase < Test::Unit::TestCase
end
