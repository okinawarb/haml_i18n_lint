require "haml"

module HamlI18nLint
  # Run lint and report the result.
  class Runner
    # @param options [Options] options
    # @return [Runner] new runner to run lint with given options
    def initialize(options)
      @options = options
      @config = ::HamlI18nLint::Config.new(@options)
      @linter = ::HamlI18nLint::Linter.new(@config)
    end

    # Run lint and report the result
    # @return [true, false] all of the files passed lint or not.
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
