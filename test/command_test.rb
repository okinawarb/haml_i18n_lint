require 'test_helper'

class CommandTest < Test::Unit::TestCase
  def test_command_exists
    assert { system('bundle exec haml-i18n-lint') }
  end
end
