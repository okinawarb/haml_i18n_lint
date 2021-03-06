require "haml_i18n_lint/ruby_parser"

module HamlI18nLint
  class Linter
    module CompilerExtension

      def compile_script
        super
        lint_script(@node.value[:text])
      end

      def compile_plain
        super
        text = @node.value[:text]
        lint_add(text) if lint_config.need_i18n?(text)
      end

      def lint_attributes_hashes
        @node.value[:attributes_hashes]
      end

      def lint_attributes
        lint_attributes_hashes.any? do |attributes_hash|
          lint_script("{#{attributes_hash}}")
        end
      end

      def compile_tag
        super
        if @node.value[:parse]
          lint_script(@node.value[:value])
        else
          value = @node.value[:value]
          lint_add(value) if lint_config.need_i18n?(value)
        end

        placeholder = @node.value.dig(:attributes, 'placeholder') || ""
        lint_add(placeholder) if lint_config.need_i18n?(placeholder)

        value = @node.value.dig(:attributes, 'value') || ""
        lint_add(value) if lint_config.need_i18n?(value)

        lint_attributes
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
        when :string_literal
          _type, _s, _lineno, k = assoc_key
          return k.size == 2 &&
                 k.first == :string_content &&
                 k.last[0] == :@tstring_content &&
                 k.last[1] == key
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

      def lint_fcall?(sexp, method_name)
        return unless sexp.first == :method_add_arg

        _method_add_arg, (fcall, (ident, m, _lineno)), * = sexp

        fcall == :fcall && ident == :@ident && m == method_name
      end

      def lint_call?(sexp, method_name)
        return unless sexp.first == :method_add_arg

        _method_add_arg, (call, _receiver, _dot, (ident, m, _lineno)), * = sexp

        call == :call && ident == :@ident && m == method_name
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

      def lint_ignore_method?(sexp, m)
        lint_command?(sexp, m) || lint_fcall?(sexp, m) || lint_call?(sexp, m)
      end

      def lint_script(script)
        script = script.dup
        if Ripper.lex(script.rstrip).any? { |(_, on_kw, kw_do)| on_kw == :on_kw && kw_do == "do" }
          script << "\nend\n"
        end
        sexp = RubyParser.sexp(script)

        string_literal_found = false
        walk = -> (sexp) do
          return if !sexp.is_a?(Array)
          return if lint_aref?(sexp)
          return if lint_config.ignore_methods.any? { |m| lint_ignore_method?(sexp, m) }
          return if lint_config.ignore_keys.any? { |k| lint_assoc_new?(sexp, k) }

          if lint_string_literal?(sexp) && lint_string_literal_need_i18n?(sexp)
            string_literal_found = sexp[1]
            return
          end

          sexp.each do |sexp|
            walk.(sexp)
          end
        end

        walk.(sexp)

        lint_add(string_literal_found) if string_literal_found
      end

    end
  end
end
