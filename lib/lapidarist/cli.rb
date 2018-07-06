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

      progress = Progress.new
      update = Update.new(options)
      outdated = Outdated.new(options)

      for i in 1..Float::INFINITY
        attempt = progress.attempt!
        logger.header("Attempt ##{progress.attempts.length}")

        outdated_gems = outdated.run(
          failed_gem_names: progress.failed_gems,
          updated_count: progress.updated_gems
        )

        if outdated_gems.empty?
          logger.footer('stopping, there are no applicable outdated gems')
          break
        end

        update.run(outdated_gems)

        logger.header("Testing gem updates")
        if test.success?
          progress.updated_gems!(outdated_gems.length)
          logger.footer('test passed, nothing left to do')
          break
        else
          logger.footer('test failed, investigating failure')
        end

        if outdated_gems.one?
          progress.failed_gem!(outdated_gems.first.name)
          git.reset_hard('HEAD^')
        else
          failed_gem = git.bisect(last_good_sha, test)
          progress.failed_gem!(failed_gem)
        end

        previous_good_sha = last_good_sha
        last_good_sha = git.head
        logger.debug("retry from sha: #{last_good_sha}")
        new_commits = git.count_commits(previous_good_sha, last_good_sha)
        progress.updated_gems!(new_commits)
      end

      return progress.exit_status
    end

    private

    attr_reader :options, :git, :test, :logger

    class Progress
      attr_reader :attempts, :updated_gems, :failed_gems

      def initialize
        @attempts = []
        @updated_gems = 0
        @failed_gems = []
      end

      def attempt!
        attempt = Attempt.new
        @attempts << attempt
        attempt
      end

      def updated_gems!(count)
        @updated_gems += count
      end

      def failed_gem!(gem)
        @failed_gems << gem
      end

      def exit_status
        success? ? 0 : 1
      end

      private

      def success?
        updated_gems > 0 || attempts.one?
      end
    end

    class Attempt
    end
  end
end
