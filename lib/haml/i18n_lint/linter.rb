require 'ripper'

module Haml
  module I18nLint
    class Linter
      class AttributesParseError < StandardError; end

      class Result < Struct.new(:matched_nodes)
        def success?
          matched_nodes.empty?
        end
      end

      def initialize(config)
        @config = config
      end

      def lint(filename:, template:)
        haml_options = ::Haml::Options.new
        haml_options[:filename] = filename

        node = ::Haml::Parser.new(template, haml_options).parse

        compiler(haml_options).compile(node)
      end

      private

      def compiler(haml_options)
        config = @config
        result = Result.new([])

        compiler_ext = Module.new do
          define_method(:compile) do |node|
            super(node)
            result
          end

          private

          define_method(:compile_plain) do |&block|
            super(&block)
            result.matched_nodes << @node if config.match(@node.value[:text])
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
                    config.match(val)
                end
              end
            end
          end

          define_method(:compile_tag) do |&block|
            super(&block)
            result.matched_nodes << @node if config.match(@node.value[:value])
            result.matched_nodes << @node if config.match(@node.value.dig(:attributes, 'placeholder') || "")
            result.matched_nodes << @node if config.match(@node.value.dig(:attributes, 'value') || "")
            result.matched_nodes << @node if find_literal_exp.(config, @node.value[:attributes_hashes])
          end
        end

        ::Haml::Compiler.new(haml_options).tap { |c| c.extend(compiler_ext) }
      end
    end
  end
end
