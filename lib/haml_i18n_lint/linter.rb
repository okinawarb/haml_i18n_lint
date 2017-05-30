module HamlI18nLint
  # Linter linting a Haml template
  class Linter
    # Raised if failed to parse the attributes hash
    class AttributesParseError < StandardError; end

    # The lint result
    class Result < Struct.new(:filename, :node, :text)
      # @!attribute [r] filename
      #   @return [String] name of the linted file

      # @!attribute [r] node
      #   @return [Haml::Parser::ParseNode] the node that needs i18n.

      # @!attribute [r] text
      #   @return [String] the text that needs i18n.
    end

    # The lint results
    class ResultSet
      include Enumerable

      # @param filename [String]
      def initialize
        @results = []
      end

      # @param result [Result] the result
      def add_result(result)
        @results << result
      end

      # @yield [result] Gives each result to a block.
      def each
        @results.each do |r|
          yield r
        end
      end

      # @return [true, false] passed lint or not.
      def success?
        count.zero?
      end
    end

    # @param config [Config] the configuration
    # @return [Lint] new linter with given configuration
    def initialize(config)
      @config = config
    end

    # Linting given template
    #
    # @param filename [String] the filename
    # @param template [String] the Haml template
    # @return [Linter::ResultSet] the result of lint
    # @raise [Linter::AttributesParseError] if failed to parse attributes hash in the template.
    def lint(filename:, template:)
      haml_options = ::Haml::Options.new
      haml_options[:filename] = filename
      node = parse(haml_options, template)
      compiler(haml_options).compile(node)
    end

    private

    def parse(haml_options, template)
      ::Haml::Parser.new(template, haml_options).parse
    end

    def compiler_extension
      self.class::CompilerExtension
    end

    def compiler(haml_options)
      config = @config
      result_set = ResultSet.new

      ext = compiler_extension
      compiler_result_extension = Module.new do
        include ext

        define_method(:compile) do |node|
          super(node)
          result_set
        end

        private

        define_method(:lint_config) do
          config
        end

        define_method(:lint_add) do |text|
          result_set.add_result(Result.new(haml_options[:filename], @node, text))
        end
      end

      ::Haml::Compiler.new(haml_options).tap { |c| c.extend(compiler_result_extension, compiler_extension) }
    end
  end
end
