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
      end

      opt_parser.parse!(args)
      options
    end

    private

    attr_reader :args
  end
end
