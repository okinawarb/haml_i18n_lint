require 'test_helper'

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
end
