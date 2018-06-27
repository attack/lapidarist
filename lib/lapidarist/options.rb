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
      options.verbosity = 0
      options.commit_flags = ''
      options.debug = false
      options.log_path = Pathname.new('./tmp/lapidarist.log')

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
      end

      opt_parser.parse!(args)
      options
    end

    private

    attr_reader :args
  end
end
