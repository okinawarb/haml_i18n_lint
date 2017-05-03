# HamlI18nLint

[![Build Status](https://travis-ci.org/okinawarb/haml_i18n_lint.svg?branch=master)](https://travis-ci.org/okinawarb/haml_i18n_lint)
[![Code Climate](http://img.shields.io/codeclimate/github/okinawarb/haml_i18n_lint.svg)](https://codeclimate.com/github/okinawarb/haml_i18n_lint)

find out not translated yet plain text from your Haml template.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'haml_i18n_lint'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install haml_i18n_lint

## Usage

    $ haml-i18n-lint --version
    haml-i18n-lint 0.1.0
    $ haml-i18n-lint --help
    Usage: haml-i18n-lint [OPTION]... [FILE]...
    -c, --config=FILE                configuration file
    -f, --files=PATTERN              pattern to find Haml template files, default: -f '**/*.haml'

The configuration file sample:

    # You can override Config#need_i18n? that returns the content in Haml template need i18n or not.
    def need_i18n?(content)
      # the default behaviours is ignore white spaces and digits
      /^[\s]+$/ !~ content && /[A-Za-z]/ =~ content
    end

    # You can override Config#report in configuration file
    # to customize output format or send result to other location.
    #
    # The default output format is like following:
    #
    # $ haml-i18n-lint
    # test/fixtures/hi.html.haml:4
    # 3:    %head
    # 4:      %title Hi
    # 5:    %body
    #
    # For example, to use short format:
    def report(result)
      result.matched_nodes.each do |node|
        puts "#{result.filename}:#{node.line}"
      end
    end

    # You can override Config#files for complex file pattern.
    def files
      Dir['**/*.haml'].reject { |path| path.start_with?('app/assets/') || path.start_with?('node_modules') }
    end

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/okinawarb/haml_i18n_lint. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
