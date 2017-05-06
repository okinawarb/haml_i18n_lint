require 'test_helper'

class CommandTest < HamlI18nLint::TestCase
  def test_command_exists
    assert { system('bundle exec haml_i18n_lint foo.html.haml') }
    assert { !system('bundle exec haml_i18n_lint > /dev/null') }
  end
end
