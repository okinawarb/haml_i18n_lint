require 'test_helper'

class Haml::I18nLint::LinterTest < Haml::I18nLint::TestCase
  def setup
    options = Haml::I18nLint::Options.new
    config = Haml::I18nLint::Config.new(options)
    @linter = Haml::I18nLint::Linter.new(config)
  end

  def test_lint
    assert { lint('123  456').success? }
    assert { lint('   ').success? }
    assert { lint('%h1 123').success? }
    assert { lint('%input(value="123")').success? }
    assert { lint('%input(placeholder="123")').success? }
    assert { lint('%input{value: "123"}').success? }
    assert { lint('%input{placeholder: "123"}').success? }
    assert { lint('%input{placeholder: var}').success? }
    assert { !lint('hello').success? }
    assert { !lint('%h1 hello').success? }
    assert { !lint('%input(value="hello")').success? }
    assert { !lint('%input(placeholder="hello")').success? }
    assert { !lint('%input{value: "hello"}').success? }
    assert { !lint('%input{placeholder: "hello"}').success? }
    assert { !lint("%form\n  %input{placeholder: 'hello'}").success? }
  end

  def test_lint_result
    assert { lint('123').matched_nodes.empty? }
    assert { lint('123').filename == 'test.html.haml' }
    assert { lint('123').success? }

    assert { !lint('hi').matched_nodes.empty? }
    assert { !lint('hi').success? }
  end

  private

  def lint(template)
    @linter.lint(filename: 'test.html.haml', template: template)
  end
end
