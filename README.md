# Lapidarist

[![CircleCI](https://circleci.com/gh/attack/lapidarist.svg?style=svg)](https://circleci.com/gh/attack/lapidarist)

Take the manual work out of updating your ruby gems, and let Lapidarist do the work.

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

### Options

To see all the options available
```sh
lapidarist -h
```

#### `-t`, `--test TEST_SCRIPT`

Test script to assert that the gems updates are safe to commit.
This is run after any batch of updates, or during git bisect to investigate a
failing update.

#### `-a`, `--all`

By default, Lapidarist will only update gems that are listed in the Gemfile.
Use this option to also selectively update gems (or sub-dependencies) that are
not listed in the Gemfile.

#### `-q`, `--quiet`

Do not print anything to stdout. This will take precedence over logging
verbosity levels and debugging output.

#### `-v`

Increase verbosity of stdout output. Repeat this option up to three times
for to control the level of detail.

#### `-f`, `--commit-flags`

When Lapidarist commits gem updates extra flags can be requested to append
to this command. A common use case is to bypass local git hooks with `--no-verify`.

#### `-l`

Path to log file. This is location where Lapidarist will write a log with full
verbosity. This file will be reset for each run.

#### `-n`

By default, Lapidarist will attempt to update all outdated gems. Use this option
to limit the number of gems that are updated to a maximum number.

#### `--one`, `-n 1`

This is the same as `-n 1`, and limits Lapidarist to only update one gem.

#### `-g`, `--group`

Limit gems to be updated to a specified group(s). Multiple groups can be can
be permitted by using this option multiple times.

#### `--major`, `--minor`, `--patch`

Limit gem updates to a specific maximum level.  This option is passed directly to
`bundle update` and follows the logic controlled by bundler.

#### `-r`, `--recursive`

By default, Lapidarist will only try to update a gem once.  With this option,
if an update fails then Lapidarist will try again using a lower maximum level.
For example, if a gem had updates available at a patch level, a minor level and
a major level, and an update failed when updating to the major level, then with
this option Lapidarist will try again at the minor then patch levels until all
levels are exhausted or an update is accepted.

This option will respect the maximum update level option, and will only try
lower available levels, if any.

#### `-o`, `--ordered`

By default, Lapidarist will randomize the order of gems it attempts to update.
This option can be used to prevent randomization and force Lapidarist to respect
the order from `bundle outdated`, which is essentially in alphabetical order.

#### `--seed`

By default, Lapidarist will randomize the order of gems it attempts to update
with a randomly generated seed. This option can be used to control the seed and
thus the resulting random order.

#### `--promote`

By default, Lapidarist will randomize the order of all gems it attempts to update.
With this option gems can be promoted to the top of the order so that the specified
gem(s) will be updated first before any non-promoted gems.

This option can be a comma delimited list or the result of using this option
multiple times.

#### `--demote`

By default, Lapidarist will randomize the order of all gems it attempts to update.
With this option gems can be demoted to the bottom of the order so that the specified
gem(s) will be updated last after any non-demoted gems.

This option can be a comma delimited list or the result of using this option
multiple times.

If a gem is both promoted and demoted, then demoted will be preferred and the
promotion will be ignored.

#### `--only`

By default, Lapidarist will attempt to update all outdated gems.  With this
option Lapidarist will only attempt to update the outdated gems that match
those specified, and ignore updating any other gems.

This option can be a comma delimited list or the result of using this option
multiple times.

#### `--except`

By default, Lapidarist will attempt to update all outdated gems.  With this
option Lapidarist will attempt to update the all outdated gems except those that
match the ones specified.

This option can be a comma delimited list or the result of using this option
multiple times.

If both `--only` and `--except` are given, then a hybrid of the two options will
be used, essentially behaving like `--only` but excluding any gems provided
using `--except` (ie `lapidarist --only foo,bar --except foo` is equivalent to
`lapidarist --only bar`)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/attack/lapidarist.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
