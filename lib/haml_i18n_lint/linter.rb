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

      node = ::Haml::Parser.new(template, haml_options).parse

      compiler(haml_options).compile(node)
    end

    private

    def compiler(haml_options)
      config = @config
      result = Result.new(haml_options[:filename], [])

      compiler_ext = Module.new do
        define_method(:compile) do |node|
          super(node)
          result
        end

        private

        define_method(:compile_script) do |&block|
          super(&block)
          program = Ripper.sexp(@node.value[:text]).flatten
          str_num = program.flatten.count { |t| t == :string_literal }
          tstr_num = program.each_with_index.count { |t, i| [t, program[i + 1], program[i + 2]] == [:fcall, :@ident, config.i18n_method.to_s] }

          result.matched_nodes << @node unless str_num == tstr_num
        end

        define_method(:compile_plain) do |&block|
          super(&block)
          result.matched_nodes << @node if config.need_i18n?(@node.value[:text])
        end

        find_literal_exp = -> (config, attributes_hashes) do
          attributes_hashes.any? do |attributes_hash|
            sexp = Ripper.sexp("{#{attributes_hash}}")
            program, ((hash,(assoclist_from_args,assocs)),) = sexp

            unless program == :program &&
                   hash == :hash &&
                   assoclist_from_args == :assoclist_from_args &&
                   assocs.respond_to?(:all?) &&
                   assocs.all? { |assoc| assoc.first == :assoc_new }
              raise AttributesParseError
            end

            assocs.any? do |assoc|
              assoc_new, key, value = assoc
              raise AttributesParseError unless assoc_new == :assoc_new
              string_literal, *strings = value
              next unless string_literal == :string_literal
              strings.any? do |(string_content, (tstring_content,val,pos))|
                string_content == :string_content &&
                  tstring_content == :@tstring_content &&
                  config.need_i18n?(val)
              end
            end
          end
        end

        define_method(:compile_tag) do |&block|
          super(&block)
          result.matched_nodes << @node if config.need_i18n?(@node.value[:value])
          result.matched_nodes << @node if config.need_i18n?(@node.value.dig(:attributes, 'placeholder') || "")
          result.matched_nodes << @node if config.need_i18n?(@node.value.dig(:attributes, 'value') || "")
          result.matched_nodes << @node if find_literal_exp.(config, @node.value[:attributes_hashes])
        end
      end

      ::Haml::Compiler.new(haml_options).tap { |c| c.extend(compiler_ext) }
    end
  end
end
