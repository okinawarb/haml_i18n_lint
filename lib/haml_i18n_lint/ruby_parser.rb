require "ripper"

module HamlI18nLint
  class RubyParser < Ripper::SexpBuilderPP

    def self.sexp(src, filename = '-', lineno = 1)
      builder = new(src, filename, lineno)
      sexp = builder.parse
      sexp unless builder.error?
    end

    def initialize(src, *)
      @src = src
      super
    end

    def on_tstring_beg(tok)
      @buf ||= []
      @buf << [[lineno, column]]
      super
    end

    def on_heredoc_beg(tok)
      @buf ||= []
      @buf << [[lineno, column]]
      super
    end

    def on_tstring_end(tok)
      @buf.last << [lineno, column]
      super
    end

    def on_heredoc_end(tok)
      @buf.last << [lineno, column + tok.size-1]
      super
    end

    def on_string_literal(*args)
      pos = @buf.pop
      lineno_pos = pos.map(&:first)
      column_pos = pos.map(&:last)
      lines = @src.lines[lineno_pos.first-1...lineno_pos.last]
      if lineno_pos.first == lineno_pos.last
        lines[0] = lines[0].byteslice(column_pos.first..column_pos.last).force_encoding(@src.encoding)
      else
        lines[0] = lines[0].dup.tap { |l| l.force_encoding(Encoding::BINARY)[0...column_pos.first] = ''; l.force_encoding(@src.encoding) }
        lines[-1] = lines[-1].dup.tap { |l| l.force_encoding(Encoding::BINARY)[column_pos.last+1..-1] = ''; l.force_encoding(@src.encoding) }
      end
      args.unshift(:string_literal, lines.join, pos)
      args
    end
  end
end
