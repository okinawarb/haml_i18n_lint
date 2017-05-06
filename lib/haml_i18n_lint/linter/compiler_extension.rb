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

      def lint_aref?(sexp)
        sexp.first == :aref
      end

      def lint_assoc_new?(sexp, key)
        return false unless sexp.first == :assoc_new

        _assoc_new, assoc_key, _value = sexp

        type, k, _lineno = assoc_key

        case type
        when :@label
          return k == "#{key}:"
        when :dyna_symbol
          return k.size == 2 &&
                 k.first == :string_content &&
                 k.last[0] == :@tstring_content &&
                 k.last[1] == key
        end

        false
      end

      def lint_command?(sexp, method_name)
        return unless sexp.first == :command

        _command, (ident, m, _lineno), * = sexp

        ident == :@ident && m == method_name
      end

      def lint_method_call?(sexp, method_name)
        return unless sexp.first == :method_add_arg

        _method_add_arg, (fcall, (ident, m, _lineno)), * = sexp

        fcall == :fcall && ident == :@ident && m == method_name
      end

      def lint_string_literal?(sexp)
        sexp.first == :string_literal
      end

      def lint_string_literal_need_i18n?(sexp)
        exps = sexp.flatten
        exps.each_with_index.any? do |exp, i|
          exp == :@tstring_content && exps[i + 1].is_a?(String) && lint_config.need_i18n?(exps[i + 1])
        end
      end

      def script_need_i18n?(script)
        script = script.dup
        if Ripper.lex(script.rstrip).any? { |(_, on_kw, kw_do)| on_kw == :on_kw && kw_do == "do" }
          script << "\nend\n"
        end
        sexp = Ripper.sexp(script)

        string_literal_found = false
        walk = -> (sexp) do
          return if !sexp.is_a?(Array)
          return if lint_aref?(sexp)
          return if lint_config.ignore_methods.any? { |m| lint_command?(sexp, m) || lint_method_call?(sexp, m) }
          return if lint_config.ignore_keys.any? { |k| lint_assoc_new?(sexp, k) }

          if lint_string_literal?(sexp) && lint_string_literal_need_i18n?(sexp)
            string_literal_found = true
            return
          end

          sexp.each do |sexp|
            walk.(sexp)
          end
        end

        walk.(sexp)

        string_literal_found
      end

    end
  end
end
