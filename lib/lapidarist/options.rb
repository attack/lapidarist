require 'optparse'

module Lapidarist
  class Options
    def initialize(args)
      @args = args
    end

    def parse
      opt_parser = OptionParser.new do |opts|
        opts.on("--go", "Update dependencies for a Go project using go.mod. Default is a Ruby project with Bundler.") do |t|
          Lapidarist.config.project = :go_mod
        end

        opts.on("-d", "--directory DIRECTORY", "Directory of project to run Lapidarist for.") do |d|
          Lapidarist.config.directory = Pathname.new(d)
        end

        opts.on("-t", "--test TEST_SCRIPT", "Test script to assert that the dependency updates are safe to commit.") do |t|
          Lapidarist.config.test_script = t
        end

        # TODO: for Go
        opts.on("-a", "--all", "Update dependencies that are sub-dependencies.") do |t|
          Lapidarist.config.all = true
        end

        opts.on("-q", "--quiet", "Do not print anything to stdout.") do |t|
          Lapidarist.config.quiet = true
        end

        opts.on("-v", "Increase verbosity, repeat for more verbosity.") do |t|
          Lapidarist.config.verbosity += 1
        end

        opts.on("-f", "--commit-flags FLAGS", "Append flags to the commit command.") do |t|
          Lapidarist.config.commit_flags = t
        end

        opts.on("--debug", "Display debug output.") do |t|
          Lapidarist.config.debug = true
        end

        opts.on("-l LOG_PATH", "Path to log file") do |t|
          Lapidarist.config.log_path = Pathname.new(t)
        end

        opts.on("-n NUMBER_OF_DEPENDENCIES", "Limit the number of dependencies to be updated.") do |t|
          Lapidarist.config.update_limit = t.to_i
        end

        opts.on("--one", "Limit the number of dependencies to be updated to just one.") do |t|
          Lapidarist.config.update_limit = 1
        end

        opts.on("-g GROUP_NAME", "--group GROUP_NAME", "Limit gems to be updated to a specified group(s). Bundler only.") do |g|
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

        opts.on("--promote DEPENDENCIES", "Promoted dependencies are updated first, in order as they are promoted.") do |dependency_names|
          Lapidarist.config.promoted += dependency_names.split(',').map(&:strip)
        end

        opts.on("--demote DEPENDENCIES", "Demoted dependencies are updated last, in reverse order as they are demoted.") do |dependency_names|
          Lapidarist.config.demoted += dependency_names.split(',').map(&:strip).reverse
        end

        opts.on("--only DEPENDENCIES", "Only update dependencies that are included in this list.") do |dependency_names|
          Lapidarist.config.only += dependency_names.split(',').map(&:strip)
        end

        opts.on("--except DEPENDENCIES", "Only update dependencies that are not included in this list.") do |dependency_names|
          Lapidarist.config.except += dependency_names.split(',').map(&:strip)
        end
      end

      opt_parser.parse!(args)
    end

    private

    attr_reader :args
  end
end
