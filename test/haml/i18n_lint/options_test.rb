require 'test_helper'
require 'tempfile'

class Haml::I18nLint::OptionsTest < Haml::I18nLint::TestCase
  def setup
    @options = Haml::I18nLint::Options.new
  end

  def test_config
    assert { @options.config.nil? }
  end

  def test_config=
    @options.config = 'path/to/config'
    assert { @options.config == 'path/to/config' }
  end

  def test_files
    assert { @options.files == %w(hi.html.haml) }
  end

  def test_files=
    @options.files = 'nothing'
    assert { @options.files == [] }
  end

  def test_config_content
    tempfile = Tempfile.open { |fp| fp.puts "hi"; fp }
    @options.config = tempfile.path
    assert { @options.config_content == "hi\n" }
  ensure
    tempfile.close
  end

  def test_config_content_without_set_config
    assert_raise(Haml::I18nLint::LoadConfigError.new("Config not exist: nil")) { @options.config_content }
  end

  def test_config_content_with_not_exist_path
    @options.config = 'foo'
    assert_raise(Haml::I18nLint::LoadConfigError.new('Config not exist: "foo"')) { @options.config_content }
  end
end
