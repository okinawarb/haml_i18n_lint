require 'test_helper'

class HamlI18nLint::LinterTest < HamlI18nLint::TestCase
  def setup
    options = HamlI18nLint::Options.new
    config = HamlI18nLint::Config.new(options)
    @linter = HamlI18nLint.linter.new(config)
  end

  def test_lint
    assert { lint('123  456').success? }
    assert { lint('   ').success? }
    assert { lint('.empty').success? }
    assert { lint('%h1 123').success? }
    assert { lint('%input(value="123")').success? }
    assert { lint('%input(placeholder="123")').success? }
    assert { lint('%input{value: "123"}').success? }
    assert { lint('%input{placeholder: "123"}').success? }
    assert { lint('%input{placeholder: var}').success? }
    assert { lint("- if 'test'\n  123").success? }
    assert { lint("= foo do  \n  123").success? }
    assert { lint("= foo do |f|  \n  123").success? }
    assert { lint("= foo do |f|  \n  123").success? }
    assert { lint(<<~HAML).success? }
      = form_for(@foo, method: 'GET', action: '/foo', html: { id: 'form', class: 'form' })
    HAML
    assert { lint(<<~HAML).success? }
      = link_to 42, controller: 'answer', action: 'show'
    HAML
    assert { lint(<<~HAML).success? }
      %input(id="btn1" class="button" type="button" value="1")
      %input{id: "btn2", class: "button", type: "button", value: "2"}
    HAML
    assert { lint(<<~HAML).success? }
      %p(lang="en" style="color: red") $1
      %p{lang: "ja", style: "color: red"} ¥1
    HAML
    assert { lint(<<~HAML).success? }
      %input(selected="selected")
      %input(checked="checked")
      %input{ selected: "selected" }
      %input{ checked: "checked" }
    HAML
    assert { lint(<<~HAML).success? }
      %script(src="foo.js" language="javascript")
      %script{src: "foo.js", language: "javascript"}
    HAML
    assert { lint(<<~HAML).success? }
      %link(href="http://example.com" rel="stylesheet" media="all") 1
      %link{href: "http://example.com", rel: "stylesheet", media: "all"} 2
    HAML
    assert { lint(<<~'HAML').success? }
      %span= "0 <" + @foo.bars.count.to_s
    HAML
    assert { lint(<<~'HAML').success? }
      = params['foo']
    HAML
    assert { lint(<<~'HAML').success? }
      = asset_path('foo.png')
      = image_path('foo.png')
      = image_tag('foo.png')
      = javascript_include_tag('application')
      = pluralize(1, 'person')
      = render 'hello'
      = singularize('posts')
      = stylesheet_link_tag('application')
      = t('hello')
      = I18n.t('hello')
    HAML
    assert { !lint('hello').success? }
    assert { !lint('はいさい').success? }
    assert { !lint('%h1 hello').success? }
    assert { !lint('%input(value="hello")').success? }
    assert { !lint('%input(placeholder="hello")').success? }
    assert { !lint('%input{value: "hello"}').success? }
    assert { !lint('%input{placeholder: "hello"}').success? }
    assert { !lint("%form\n  %input{placeholder: 'hello'}").success? }
    assert { !lint("= 'hello'").success? }
    assert { !lint("- if 'test'\n  hello").success? }
    assert { !lint("= foo do  \n  hello").success? }
    assert { !lint("= foo do |f|  \n  hello").success? }
    assert { !lint(<<~'HAML').success? }
      %span= "count: " + @foo.bars.count.to_s
    HAML
  end

  def test_lint_result
    assert { lint('123').success? }
    assert { lint('hi').all? {|r| r.filename == 'test.html.haml' } }
    assert { !lint('hi').success? }
  end

  def test_dynamic_symbol_key
    with_config(config: "def ignore_keys; super + %w(data-href); end") do |config_path|
      options = HamlI18nLint::Options.new
      options.config_path = config_path
      config = HamlI18nLint::Config.new(options)
      @linter = HamlI18nLint.linter.new(config)

      assert { lint(%q|.fb-like{'data-href': 'http://example.com/'}|).success? }
    end
  end

  private

  def lint(template)
    @linter.lint(filename: 'test.html.haml', template: template)
  end
end
