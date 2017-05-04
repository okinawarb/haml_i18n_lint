module HamlI18nLint
  # Configuration for the lint
  class Config
    # Returns a new lint configuration by given options
    #
    # @param options [Options]
    def initialize(options)
      @options = options
      if (@options.config_path)
        load_config(@options.config_content)
      end
    end

    # @param content [String] the text content found in haml template
    # @return [true, false] the content need i18n or not.
    def need_i18n?(content)
      /^[\s]+$/ !~ content && /\p{Alpha}/ =~ content
    end

    # Output the formatted result
    #
    # @param result [Linter::Result] the lint result
    def report(result)
      print '.' and return if result.success?

      puts
      file = File.readlines(result.filename)
      result.matched_nodes.each do |node|
        puts "#{result.filename}:#{node.line}"
        puts "#{node.line-1}:  #{file[node.line - 2]}" if file[node.line - 2]
        puts "#{node.line}:  #{file[node.line - 1]}"
        puts "#{node.line+1}:  #{file[node.line]}" if file[node.line]
        puts '-' * 16
      end
      puts
    end

    # @return [Array<String>] the list of files to be linted.
    def files
      Dir[*@options.files]
    end

    # @return [String] the list of methods, which takes string. The string is no translation required.
    def ignore_methods
      %w(t render)
    end

    private

    def load_config(config_content)
      singleton_class.class_eval { eval(config_content, binding) }
    end
  end
end
