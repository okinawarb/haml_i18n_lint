module Haml
  module I18nLint
    class Config
      def match(content)
        /^[\s]+$/ !~ content && /[A-Za-z]/ =~ content
      end

      def load_config(config_content)
        singleton_class.class_eval { eval(config_content, binding) }
      end
    end
  end
end
