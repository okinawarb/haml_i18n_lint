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
    # @param result [Linter::ResultSet] the lint result
    def report(result_set)
      print '.' and return if result_set.success?

      puts
      files = Hash.new { |h, k| h[k] = File.readlines(k) }
      result_set.each do |result|
        file = files[result.filename]
        node = result.node
        puts "#{result.filename}:#{node.line}"
        puts "#{node.line-1}:  #{file[node.line - 2]}" if file[node.line - 2] && !(node.line - 2).negative?
        puts "#{node.line}:  #{file[node.line - 1]}"
        puts "#{node.line+1}:  #{file[node.line]}" if file[node.line]
        puts '-' * 16
      end
      puts
    end

    # @return [Array<String>] the list of files to be linted.
    def files
      Dir[*@options.files].uniq
    end

    # @return [String] the list of methods, which takes string. The string is no translation required.
    def ignore_methods
      %w(
        asset_path
        image_path
        image_tag
        javascript_include_tag
        pluralize
        render
        singularize
        stylesheet_link_tag
        t
      )
    end

    # @return [String] the list of key of attributes hash. The key is no translation required.
    def ignore_keys
      %w(id class style type lang selected checked href src language rel media method controller action)
    end

    private

    def load_config(config_content)
      singleton_class.class_eval { eval(config_content, binding) }
    end
  end
end
