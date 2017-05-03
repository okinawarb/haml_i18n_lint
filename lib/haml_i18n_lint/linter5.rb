require 'ripper'

module HamlI18nLint
  class Linter5 < Linter
    private

    def parse(haml_options, template)
      ::Haml::Parser.new(haml_options).call(template)
    end
  end
end
