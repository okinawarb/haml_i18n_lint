module Haml
  module I18nLint
    class Options
      attr_accessor :config
      attr_writer :files

      def files
        files = @files || '**/*.haml'
        Dir[*files]
      end
    end
  end
end
