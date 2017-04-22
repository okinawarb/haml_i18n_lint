require 'test_helper'

class Haml::I18nLint::RunnerTest < Haml::I18nLint::TestCase
  def setup
    options = Haml::I18nLint::Options.new
    @runner = Haml::I18nLint::Runner.new(options)
  end

  def test_run
    with_template(template: "123") do
      assert { @runner.run }
    end

    assert { !@runner.run }
  end
end
