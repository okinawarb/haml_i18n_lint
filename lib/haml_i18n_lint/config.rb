module HamlI18nLint
  class Config
    def initialize(options)
      @options = options
      if (@options.config_path)
        load_config(@options.config_content)
      end
    end

    def match(content)
      /^[\s]+$/ !~ content && /[A-Za-z]/ =~ content
    end

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

    def files
      Dir[*@options.files]
    end

    private

    def load_config(config_content)
      singleton_class.class_eval { eval(config_content, binding) }
    end
  end
end
