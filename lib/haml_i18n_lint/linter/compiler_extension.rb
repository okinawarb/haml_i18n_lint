module HamlI18nLint
  class Linter
    module CompilerExtension

      def compile_script
        super
        lint_add_matched_node(@node) if script_need_i18n?(@node.value[:text])
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
            assoc_new, (_label, key, _pos), value = assoc

            next if lint_config.ignore_keys.any? { |k| "#{k}:" == key }

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
        if @node.value[:parse]
          lint_add_matched_node(@node) if script_need_i18n?(@node.value[:value])
        else
          lint_add_matched_node(@node) if lint_config.need_i18n?(@node.value[:value])
        end
        lint_add_matched_node(@node) if lint_config.need_i18n?(@node.value.dig(:attributes, 'placeholder') || "")
        lint_add_matched_node(@node) if lint_config.need_i18n?(@node.value.dig(:attributes, 'value') || "")
        lint_add_matched_node(@node) if lint_attribute_need_i18n?
      end

      private

      def script_need_i18n?(script)
        script = script.dup
        if Ripper.lex(script.rstrip).any? { |(_, on_kw, kw_do)| on_kw == :on_kw && kw_do == "do" }
          script << "\nend\n"
        end
        program = Ripper.sexp(script).flatten
        str_num = program.flatten.count { |t| t == :string_literal }
        tstr_num = program.each_with_index.count do |t, i|
          lint_config.ignore_methods.any? do |m|
            [t, program[i + 1], program[i + 2]] == [:fcall, :@ident, m.to_s] ||
              [t, program[i + 1], program[i + 2]] == [:command, :@ident, m.to_s]
          end
        end

        ignore_key_num = program.count.times.count do |i|
          lint_config.ignore_keys.any? do |k|
            program[i, 3] == [:assoc_new, :@label, "#{k}:"] && program[i + 5] == :string_literal
          end
        end

        ignore_aref_key_num = program.count.times.count do |i|
          program[i, 2] == [:aref, :vcall] && program[i+6, 2] == [:args_add_block, :string_literal]
        end

        str_num != tstr_num + ignore_key_num + ignore_aref_key_num
      end

    end
  end
end
