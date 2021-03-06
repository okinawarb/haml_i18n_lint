# HamlI18nLint

[![Gem Version](https://badge.fury.io/rb/haml_i18n_lint.svg)](http://rubygems.org/gems/haml_i18n_lint)
[![Build Status](https://travis-ci.org/okinawarb/haml_i18n_lint.svg?branch=master)](https://travis-ci.org/okinawarb/haml_i18n_lint)
[![Code Climate](http://img.shields.io/codeclimate/github/okinawarb/haml_i18n_lint.svg)](https://codeclimate.com/github/okinawarb/haml_i18n_lint)
[![Coverage Status](https://coveralls.io/repos/github/okinawarb/haml_i18n_lint/badge.svg?branch=master)](https://coveralls.io/github/okinawarb/haml_i18n_lint?branch=master)
[![Inline docs](http://inch-ci.org/github/okinawarb/haml_i18n_lint.svg?branch=master)](http://inch-ci.org/github/okinawarb/haml_i18n_lint)

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

    $ haml_i18n_lint --version
    haml_i18n_lint 0.1.0
    $ haml_i18n_lint --help
    Usage: haml_i18n_lint [OPTION]... [FILE]...
    -c, --config=FILE                configuration file
    -f, --files=PATTERN              pattern to find Haml template files, default: -f '**/*.haml'

The configuration file examples are in the `examples` directory.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/okinawarb/haml_i18n_lint. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
