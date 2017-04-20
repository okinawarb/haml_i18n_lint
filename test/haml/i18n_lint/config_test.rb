require 'test_helper'
require 'tempfile'

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
    assert { @config.files == %w(hi.html.haml) }

    @options.files = ''
    config = ::Haml::I18nLint::Config.new(@options)
    assert { config.files == [] }
  end

  def test_load_config_from_options
    options = ::Haml::I18nLint::Options.new
    tempfile = Tempfile.open { |fp| fp.puts "def foo; true; end"; fp }
    options.config_path = tempfile.path
    config = ::Haml::I18nLint::Config.new(options)

    assert { config.foo }
    assert_raise(NoMethodError) { @config.foo }
  ensure
    tempfile.close
  end
end
