require 'test_helper'
require 'tempfile'

class HamlI18nLint::OptionsTest < HamlI18nLint::TestCase
  def setup
    @options = HamlI18nLint::Options.new
  end

  def test_config_path
    assert { @options.config_path.nil? }
  end

  def test_config_path=
    @options.config_path = 'path/to/config'
    assert { @options.config_path == 'path/to/config' }
  end

  def test_default_files
    assert { @options.files == ['**/*.haml'] }
  end

  def test_files=
    @options.files = 'nothing'
    assert { @options.files == 'nothing' }
  end

  def test_config_content
    tempfile = Tempfile.open { |fp| fp.puts "hi"; fp }
    @options.config_path = tempfile.path
    assert { @options.config_content == "hi\n" }
  ensure
    tempfile.close
  end

  def test_config_content_without_set_config
    assert_raise(HamlI18nLint::LoadConfigError.new("Config not exist: nil")) { @options.config_content }
  end

  def test_config_content_with_not_exist_path
    @options.config_path = 'foo'
    assert_raise(HamlI18nLint::LoadConfigError.new('Config not exist: "foo"')) { @options.config_content }
  end
end
