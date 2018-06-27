module Lapidarist
  class CLI
    def initialize(args)
      @options = Options.new(args).parse
      @git = GitCommand.new(options)
      @test = TestCommand.new(options)
      @logger = Logger.new(options)
    end

    def run
      failing_gem_names = []
      logger.info('Starting lapidarist ...')
      logger.info("(options) > directory: #{options.directory}")
      logger.info("(options) > test_script: #{options.test_script}")
      logger.info("(options) > all: #{options.all}")
      logger.info("(options) > quiet: #{options.quiet}")
      logger.info("(options) > verbosity: #{options.verbosity}")

      start_sha = git.head
      logger.info("> start sha: #{start_sha}")

      update = Update.new(options)
      outdated = Outdated.new(options)

      # for i in 1..Float::INFINITY
      for i in 1..1
        logger.info("Attempt ##{i}")

        logger.info("... detecting outdated gems")
        outdated_gems = outdated.run
        remaining_outdated_gems = outdated_gems.select { |g| !failing_gem_names.include?(g.name) }

        if remaining_outdated_gems.empty?
          logger.info('stopping, there are no remaining outdated gems')
          break
        end

        logger.info("... updating outdated gems")
        update.run(remaining_outdated_gems)

        # break if test.success?

        # failing_gem_names << git.bisect(start_sha, test)
        # start_sha = git.head
      end

      return 1
    end

    private

    attr_reader :options, :git, :test, :logger
  end
end
