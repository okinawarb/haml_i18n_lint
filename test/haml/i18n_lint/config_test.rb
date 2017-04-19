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

  def test_load_config
    @config.load_config('def foo; true; end')
    assert { @config.foo }
    assert_raise(NoMethodError) { Haml::I18nLint::Config.new.foo }
  end
end
