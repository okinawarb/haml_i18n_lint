module Haml
  module I18nLint
    class Config
      def match(content)
        /^[\s]+$/ !~ content && /[A-Za-z]/ =~ content
      end
    end
  end
end
