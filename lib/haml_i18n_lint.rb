require "haml_i18n_lint/version"
require "haml_i18n_lint/config"
require "haml_i18n_lint/linter"
require "haml_i18n_lint/linter/compiler_extension"
require "haml_i18n_lint/linter5"
require "haml_i18n_lint/linter5/compiler_extension"
require "haml_i18n_lint/options"
require "haml_i18n_lint/runner"

# Lint for the lines that needs i18n
module HamlI18nLint
  class << self
    def linter
      if Haml::VERSION.start_with?('5')
        ::HamlI18nLint::Linter5
      else
        ::HamlI18nLint::Linter
      end
    end
  end
end
