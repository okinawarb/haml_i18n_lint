module Haml
  module I18nLint
    class LoadConfigError < StandardError; end

    class Options
      attr_accessor :config_path
      attr_writer :files

      def config_content
        unless config_path && File.exist?(config_path)
          raise LoadConfigError, "Config not exist: #{config_path.inspect}"
        end

        File.read(config_path)
      end

      def files
        @files ||= ["**/*.haml"]
      end
    end
  end
end
