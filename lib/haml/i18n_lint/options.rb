module Haml
  module I18nLint
    class LoadConfigError < StandardError; end

    class Options
      attr_accessor :config
      attr_writer :files

      def load_config(binding)
        unless config && File.exist?(config)
          raise LoadConfigError, "Config not exist: #{config.inspect}"
        end

        eval(File.read(config), binding)
      end

      def files
        files = @files || '**/*.haml'
        Dir[*files]
      end
    end
  end
end
