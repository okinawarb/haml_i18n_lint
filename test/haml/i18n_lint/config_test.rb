require 'test_helper'

class Haml::I18nLint::ConfigTest < Haml::I18nLint::TestCase
  def setup
    @config = Haml::I18nLint::Config.new
  end

  def test_match_str
    assert { @config.match('hi') }
  end

  def test_not_match_number
    assert { !@config.match('123') }
  end

  def test_not_match_spaces
    assert { !@config.match('    ') }
  end
end
