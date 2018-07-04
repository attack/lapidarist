module Lapidarist
  class CLI
    def initialize(args)
      @options = Options.new(args).parse
      @git = GitCommand.new(options)
      @test = TestCommand.new(options)

      @logger = Logger.new(options)
      @logger.setup
    end

    def run
      failing_gem_names = []
      logger.header('Starting lapidarist')
      logger.debug("directory: #{options.directory}", :options)
      logger.debug("test_script: #{options.test_script}", :options)
      logger.debug("all: #{options.all}", :options)
      logger.debug("quiet: #{options.quiet}", :options)
      logger.debug("verbosity: #{options.verbosity}", :options)
      logger.debug("commit_flags: #{options.commit_flags}", :options)

      last_good_sha = git.head
      logger.debug("start sha: #{last_good_sha}")

      unless git.clean?
        logger.footer('stopping, there are uncommitted changes')
        return 1
      end

      update = Update.new(options)
      outdated = Outdated.new(options)

      for i in 1..Float::INFINITY
        logger.header("Attempt ##{i}")

        outdated_gems = outdated.run(failing_gem_names)

        if outdated_gems.empty?
          logger.footer('stopping, there are no applicable outdated gems')
          break
        end

        update.run(outdated_gems)

        logger.header("Testing gem updates")
        if test.success?
          logger.footer('test passed, nothing left to do')
          break
        else
          logger.footer('test failed, investigating failure')
        end

        if outdated_gems.one?
          failing_gem_names << outdated_gems.first.name
          git.reset_hard('HEAD^')
        else
          failing_gem_names << git.bisect(last_good_sha, test)
        end

        last_good_sha = git.head
        logger.debug("retry from sha: #{last_good_sha}")
      end

      return 1
    end

    private

    attr_reader :options, :git, :test, :logger
  end
end
