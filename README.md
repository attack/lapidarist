# Lapidarist

[![CircleCI](https://circleci.com/gh/attack/lapidarist.svg?style=svg)](https://circleci.com/gh/attack/lapidarist)

Take the manual work out of updaeting your ruby gems, and let Lapidarist do the work.

You can run it from the command line yourself to update the gems of your project, or
automate it to run and update for you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lapidarist'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lapidarist

Lapidarist depends on `bundler` and `git`.

## Usage

```sh
lapidarist -d . -t 'rspec spec' --all
```

To see all the options available
```sh
lapidarist -h
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/attack/lapidarist.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
