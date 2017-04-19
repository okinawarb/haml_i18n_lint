module Haml
  module I18nLint
    class LoadConfigError < StandardError; end

    class Options
      attr_accessor :config
      attr_writer :files

      def config_content
        unless config && File.exist?(config)
          raise LoadConfigError, "Config not exist: #{config.inspect}"
        end

        File.read(config)
      end

      def files
        @files || '**/*.haml'
      end
    end
  end
end
