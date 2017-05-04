module HamlI18nLint
  class Linter
    module CompilerExtension

      def compile_script
        super
        _, on_kw, kw_do = Ripper.lex(@node.value[:text].rstrip).last
        if on_kw == :on_kw && kw_do == "do"
          program = Ripper.sexp(@node.value[:text] + "\nend").flatten
        else
          program = Ripper.sexp(@node.value[:text]).flatten
        end
        str_num = program.flatten.count { |t| t == :string_literal }
        tstr_num = program.each_with_index.count do |t, i|
          lint_config.ignore_methods.any? do |m|
            [t, program[i + 1], program[i + 2]] == [:fcall, :@ident, m.to_s] ||
              [t, program[i + 1], program[i + 2]] == [:command, :@ident, m.to_s]
          end
        end

        lint_add_matched_node(@node) unless str_num == tstr_num
      end

      def compile_plain
        super
        lint_add_matched_node(@node) if lint_config.need_i18n?(@node.value[:text])
      end

      def lint_attributes_hashes
        @node.value[:attributes_hashes]
      end

      def lint_attribute_need_i18n?
        attributes_hashes = lint_attributes_hashes
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
                lint_config.need_i18n?(val)
            end
          end
        end
      end

      def compile_tag
        super
        lint_add_matched_node(@node) if lint_config.need_i18n?(@node.value[:value])
        lint_add_matched_node(@node) if lint_config.need_i18n?(@node.value.dig(:attributes, 'placeholder') || "")
        lint_add_matched_node(@node) if lint_config.need_i18n?(@node.value.dig(:attributes, 'value') || "")
        lint_add_matched_node(@node) if lint_attribute_need_i18n?
      end

    end
  end
end
