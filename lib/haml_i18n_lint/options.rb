module HamlI18nLint
  # Raised if given config file path is not exists
  class LoadConfigError < StandardError; end

  class Options
    # @return [String] path to config file
    attr_accessor :config_path
    attr_writer :files

    # @raise [LoadConfigError] if given config file path is not exists
    # @return [String] the content of config_path
    def config_content
      unless config_path && File.exist?(config_path)
        raise LoadConfigError, "Config not exist: #{config_path.inspect}"
      end

      File.read(config_path)
    end

    # @return [Array<String>] file patterns to list the files to be linted.
    def files
      @files ||= ["**/*.haml"]
    end
  end
end
