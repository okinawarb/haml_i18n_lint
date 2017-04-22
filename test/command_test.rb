require 'test_helper'

class CommandTest < HamlI18nLint::TestCase
  def test_command_exists
    assert { system('bundle exec haml-i18n-lint foo.html.haml') }
    assert { !system('bundle exec haml-i18n-lint') }
  end
end
