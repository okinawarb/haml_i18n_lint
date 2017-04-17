require 'test_helper'

class Haml::I18nLint::RunnerTest < Test::Unit::TestCase
  def setup
    @runner = Haml::I18nLint::Runner.new
  end

  def test_run
    assert { @runner.run }
  end
end
