require 'optparse'
require 'ostruct'

module Lapidarist
  class Options
    def initialize(args)
      @args = args
    end

    def parse
      options = OpenStruct.new
      options.directory = Pathname.new('.')
      options.test_script = 'test.sh'
      options.all = false
      options.quiet = false
      options.verbosity = 0
      options.commit_flags = ''
      options.debug = false
      options.log_path = Pathname.new('./tmp/lapidarist.log')
      options.update_limit = nil
      options.groups = []
      options.version = :major

      opt_parser = OptionParser.new do |opts|
        opts.on("-d", "--directory DIRECTORY", "Directory to run Lapidarist from.") do |d|
          options.directory = Pathname.new(d)
        end

        opts.on("-t", "--test TEST_SCRIPT", "Test script given to git bisect.") do |t|
          options.test_script = t
        end

        opts.on("-a", "--all", "Update gems that are sub-dependencies.") do |t|
          options.all = true
        end

        opts.on("-q", "--quiet", "Do not print anything to stdout.") do |t|
          options.quiet = true
        end

        opts.on("-v", "Increase verbosity, repeat for more verbosity.") do |t|
          options.verbosity += 1
        end

        opts.on("-f", "--commit-flags flags", "Append flags to the commit command.") do |t|
          options.commit_flags = t
        end

        opts.on("--debug", "Display debug output.") do |t|
          options.debug = true
        end

        opts.on("-l LOG_PATH", "Path to log file") do |t|
          options.log_path = t
        end

        opts.on("-n NUMBER_OF_GEMS", "Limit the number of gems to be updated.") do |t|
          options.update_limit = t.to_i
        end

        opts.on("-g GROUP_NAME", "--group GROUP_NAME", "Limit gems to be updated to a specified group(s).") do |g|
          options.groups << g
        end

        opts.on("--major", "Limit updates to major, minor and patch versions (essentially everything).") do |p|
          options.version = :major
        end

        opts.on("--minor", "Limit updates to minor and patch versions.") do |p|
          options.version = :minor
        end

        opts.on("--patch", "Limit updates to patch versions.") do |p|
          options.version = :patch
        end
      end

      opt_parser.parse!(args)
      options
    end

    private

    attr_reader :args
  end
end
