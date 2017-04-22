require 'test_helper'

class Haml::I18nLint::ConfigTest < Haml::I18nLint::TestCase
  def setup
    @options = ::Haml::I18nLint::Options.new
    @config = ::Haml::I18nLint::Config.new(@options)
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

  def test_files
    assert { @config.files == %w(test/fixtures/hi.html.haml) }

    @options.files = ''
    config = ::Haml::I18nLint::Config.new(@options)
    assert { config.files == [] }
  end

  def test_load_config_from_options
    with_config(config: "def foo; true; end") do |config_path|
      options = ::Haml::I18nLint::Options.new
      options.config_path = config_path
      config = ::Haml::I18nLint::Config.new(options)
      assert { config.foo }
    end

    assert_raise(NoMethodError) { @config.foo }
  end
end
