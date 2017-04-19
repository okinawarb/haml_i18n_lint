require 'test_helper'

class Haml::I18nLint::MatchContentTest < Haml::I18nLint::TestCase
  def setup
    @content = Haml::I18nLint::MatchContent.new('hi.html.haml', 4)
  end

  def test_filename
    assert { @content.filename == 'hi.html.haml' }
  end

  def test_lineno
    assert { @content.lineno == 4 }
  end
end
