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

        opts.on("--commit-flags", "Append flags to the commit command.") do |t|
          options.commit_flags = t
        end
      end

      opt_parser.parse!(args)
      options
    end

    private

    attr_reader :args
  end
end
