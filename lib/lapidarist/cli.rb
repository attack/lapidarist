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
          failed_gems: progress.failed_gems,
          updated_count: progress.updated_gems.length
        )

        if outdated_gems.empty?
          logger.footer('stopping, there are no applicable outdated gems')
          break
        end

        update.run(outdated_gems)

        logger.header("Testing gem updates")
        if test.success?
          attempt.updated!(outdated_gems)
          logger.footer('test passed, nothing left to do')
          break
        else
          logger.footer('test failed, investigating failure')
        end

        if outdated_gems.one?
          attempt.failed!(outdated_gems.first)
          git.reset_hard('HEAD^')
        else
          failed_gem_name = git.bisect(last_good_sha, test)
          failed_gem = outdated_gems.detect { |g| failed_gem_name == g.name }
          attempt.failed!(failed_gem)
        end

        previous_good_sha = last_good_sha
        last_good_sha = git.head
        logger.debug("retry from sha: #{last_good_sha}")

        new_commit_count = git.count_commits(previous_good_sha, last_good_sha)
        attempt.updated!(outdated_gems.take(new_commit_count))
      end

      return progress.exit_status
    end

    private

    attr_reader :options, :git, :test, :logger

    class Progress
      attr_reader :attempts

      def initialize
        @attempts = []
      end

      def attempt!
        attempt = Attempt.new
        @attempts << attempt
        attempt
      end

      def failed_gems
        attempts.map { |a| a.failed }.compact
      end

      def updated_gems
        attempts.map { |a| a.updated }.flatten(1).compact
      end

      def exit_status
        success? ? 0 : 1
      end

      private

      def success?
        updated_gems.any? || attempts.one?
      end
    end

    class Attempt
      attr_reader :updated, :failed

      def updated!(gems)
        @updated = gems
      end

      def failed!(gem)
        @failed = gem
      end
    end
  end
end
