require 'ripper'

module HamlI18nLint
  # Linter linting a Haml template
  class Linter
    # Raised if failed to parse the attributes hash
    class AttributesParseError < StandardError; end

    # The lint result of the file
    class Result < Struct.new(:filename, :matched_nodes)
      # @!attribute [r] matched_nodes
      #   @return [Array<Haml::Parser::ParseNode>] the nodes that needs i18n.

      # @!attribute [r] filename
      #   @return [String] name of the linted file

      # @return [true, false] passed lint or not.
      def success?
        matched_nodes.empty?
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
    # @return [Linter::Result] the result of lint
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
      result = Result.new(haml_options[:filename], [])

      ext = compiler_extension
      compiler_result_extension = Module.new do
        include ext

        define_method(:compile) do |node|
          super(node)
          result
        end

        private

        define_method(:lint_config) do
          config
        end

        define_method(:lint_add_matched_node) do |node|
          result.matched_nodes << node
        end
      end

      ::Haml::Compiler.new(haml_options).tap { |c| c.extend(compiler_result_extension, compiler_extension) }
    end
  end
end
