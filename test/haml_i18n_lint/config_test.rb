require 'test_helper'

class HamlI18nLint::ConfigTest < HamlI18nLint::TestCase
  def setup
    @options = ::HamlI18nLint::Options.new
    @config = ::HamlI18nLint::Config.new(@options)
  end

  def test_text_needs_i18n
    assert { @config.need_i18n?('hi') }
  end

  def test_digits_does_not_need_i18n
    assert { !@config.need_i18n?('123') }
  end

  def test_spaces_does_not_need_i18n
    assert { !@config.need_i18n?('    ') }
  end

  def test_files
    assert { @config.files == %w(test/fixtures/hi.html.haml) }

    @options.files = ''
    config = ::HamlI18nLint::Config.new(@options)
    assert { config.files == [] }
  end

  def test_load_config_from_options
    with_config(config: "def foo; true; end") do |config_path|
      options = ::HamlI18nLint::Options.new
      options.config_path = config_path
      config = ::HamlI18nLint::Config.new(options)
      assert { config.foo }
    end

    assert_raise(NoMethodError) { @config.foo }
  end
end
