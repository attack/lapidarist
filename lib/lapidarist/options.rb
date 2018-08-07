require 'optparse'

module Lapidarist
  class Options
    def initialize(args)
      @args = args
    end

    def parse
      opt_parser = OptionParser.new do |opts|
        opts.on("-d", "--directory DIRECTORY", "Directory to run Lapidarist from.") do |d|
          Lapidarist.config.directory = Pathname.new(d)
        end

        opts.on("-t", "--test TEST_SCRIPT", "Test script given to git bisect.") do |t|
          Lapidarist.config.test_script = t
        end

        opts.on("-a", "--all", "Update gems that are sub-dependencies.") do |t|
          Lapidarist.config.all = true
        end

        opts.on("-q", "--quiet", "Do not print anything to stdout.") do |t|
          Lapidarist.config.quiet = true
        end

        opts.on("-v", "Increase verbosity, repeat for more verbosity.") do |t|
          Lapidarist.config.verbosity += 1
        end

        opts.on("-f", "--commit-flags flags", "Append flags to the commit command.") do |t|
          Lapidarist.config.commit_flags = t
        end

        opts.on("--debug", "Display debug output.") do |t|
          Lapidarist.config.debug = true
        end

        opts.on("-l LOG_PATH", "Path to log file") do |t|
          Lapidarist.config.log_path = t
        end

        opts.on("-n NUMBER_OF_GEMS", "Limit the number of gems to be updated.") do |t|
          Lapidarist.config.update_limit = t.to_i
        end

        opts.on("--one", "Limit the number of gems to be updated to just one.") do |t|
          Lapidarist.config.update_limit = 1
        end

        opts.on("-g GROUP_NAME", "--group GROUP_NAME", "Limit gems to be updated to a specified group(s).") do |g|
          Lapidarist.config.groups << Lapidarist::GroupConstraint.new(g)
        end

        opts.on("--major", "Limit updates to major, minor and patch versions (essentially everything).") do |p|
          Lapidarist.config.version = MAJOR
        end

        opts.on("--minor", "Limit updates to minor and patch versions.") do |p|
          Lapidarist.config.version = MINOR
        end

        opts.on("--patch", "Limit updates to patch versions.") do |p|
          Lapidarist.config.version = PATCH
        end

        opts.on("-r", "--recursive", "Try updating a the major version, minor version then patch version.") do |t|
          Lapidarist.config.recursive = true
        end

        opts.on("-o", "--ordered", "Do not randomize outdated list and keep alphabetical ordering.") do |t|
          Lapidarist.config.random = false
        end

        opts.on("--seed SEED", "When randomizing the outdated order, use the provided seed.") do |s|
          Lapidarist.config.seed = s.to_i
        end

        opts.on("--promote GEMS", "Promoted gems are updated first, in order as they are promoted.") do |gem_names|
          Lapidarist.config.promoted += gem_names.split(',').map(&:strip)
        end

        opts.on("--demote GEMS", "Demoted gems are updated last, in reverse order as they are demoted.") do |gem_names|
          Lapidarist.config.demoted += gem_names.split(',').map(&:strip).reverse
        end

        opts.on("--only GEMS", "Only update gems that are included in this list.") do |gem_names|
          Lapidarist.config.only += gem_names.split(',').map(&:strip)
        end

        opts.on("--except GEMS", "Only update gems that are not included in this list.") do |gem_names|
          Lapidarist.config.except += gem_names.split(',').map(&:strip)
        end
      end

      opt_parser.parse!(args)
    end

    private

    attr_reader :args
  end
end
