require 'test_helper'

class HamlI18nLint::RunnerTest < HamlI18nLint::TestCase
  include SuppressRunnerOutput

  def setup
    options = HamlI18nLint::Options.new
    @runner = HamlI18nLint::Runner.new(options)
  end

  def test_run
    with_template(template: "123") do
      assert { @runner.run }
    end

    assert { !@runner.run }
  end
end
