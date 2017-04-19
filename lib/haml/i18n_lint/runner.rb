require "haml"

module Haml
  module I18nLint
    class Runner
      attr_reader :options

      def initialize(options)
        @options = options
        @config = ::Haml::I18nLint::Config.new(@options)
      end

      def run
        true
      end
    end
  end
end
