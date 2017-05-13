# You can override Config#need_i18n? that returns the content in Haml template need i18n or not.
def need_i18n?(content)
  # the default behaviours is ignore white spaces and digits
  /^[\s]+$/ !~ content && /\p{Alpha}/ =~ content
end

# You can override Config#report in configuration file
# to customize output format or send result to other location.
#
# The default output format is like following:
#
# $ haml_i18n_lint
# test/fixtures/hi.html.haml:4
# 3:    %head
# 4:      %title Hi
# 5:    %body
#
# For example, to use short format:
def report(result)
  result.each do |r|
    puts "%30s\t%s" % ["#{r.filename}:#{r.node.line}", r.text]
  end
end

# You can override Config#files for complex file pattern.
def files
  Dir['**/*.haml'].reject { |path| path.start_with?('app/assets/') || path.start_with?('node_modules') }
end
