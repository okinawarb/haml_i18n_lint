module Haml
  module I18nLint
    class Config
      def initialize(options)
        @options = options
        if (@options.config_path)
          load_config(@options.config_content)
        end
      end

      def match(content)
        /^[\s]+$/ !~ content && /[A-Za-z]/ =~ content
      end

      def files
        Dir[*@options.files]
      end

      private

      def load_config(config_content)
        singleton_class.class_eval { eval(config_content, binding) }
      end
    end
  end
end
