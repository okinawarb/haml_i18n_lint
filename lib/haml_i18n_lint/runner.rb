require "haml"

module HamlI18nLint
  class Runner
    attr_reader :options

    def initialize(options)
      @options = options
      @config = ::HamlI18nLint::Config.new(@options)
      @linter = ::HamlI18nLint::Linter.new(@config)
    end

    def run
      @config.files.all? do |file|
        result = lint(file)

        next true if result.success?

        @config.report(result)
      end
    end

    private

    def lint(filename)
      template = File.read(filename)
      @linter.lint(filename: filename, template: template)
    end
  end
end
