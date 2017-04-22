require "haml"

module HamlI18nLint
  class Runner
    def initialize(options)
      @options = options
      @config = ::HamlI18nLint::Config.new(@options)
      @linter = ::HamlI18nLint::Linter.new(@config)
    end

    def run
      @config.files.all? do |file|
        result = lint(file)

        if result.success?
          true
        else
          @config.report(result)
          false
        end
      end
    end

    private

    def lint(filename)
      template = File.read(filename)
      @linter.lint(filename: filename, template: template)
    end
  end
end
