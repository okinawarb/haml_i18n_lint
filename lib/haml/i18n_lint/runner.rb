require "haml"

module Haml
  module I18nLint
    class Runner
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def run
        true
      end
    end
  end
end
