module HamlI18nLint
  class Linter5
    module CompilerExtension
      include ::HamlI18nLint::Linter::CompilerExtension

      def lint_attributes_hashes
        [@node.value[:dynamic_attributes]&.old&.gsub(/(^\{|\}$)/, '')].compact
      end
    end
  end
end
