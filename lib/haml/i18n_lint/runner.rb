require "haml"

module Haml
  module I18nLint
    class Runner
      attr_reader :options

      def initialize(options)
        @options = options
        @config = ::Haml::I18nLint::Config.new

        if @options.config
          @config.load_config(@options.config_content)
        end
      end

      def run
        true
      end
    end
  end
end
