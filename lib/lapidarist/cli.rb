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

      last_good_sha = git.head
      logger.debug("start sha: #{last_good_sha}")

      unless git.clean?
        logger.footer('stopping, there are uncommitted changes')
        return 1
      end

      progress = Progress.new
      update = Update.new(options)
      outdated = Outdated.new(options)

      loop do
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

        updated_gems = update.run(outdated_gems)

        logger.header("Testing gem updates")
        if test.success?
          attempt.updated!(updated_gems)
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

      Summary.new(progress, logger).display

      return progress.exit_status
    end

    private

    attr_reader :options, :git, :test, :logger
  end
end
