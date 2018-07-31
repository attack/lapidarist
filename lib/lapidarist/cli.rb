module Lapidarist
  class CLI
    def initialize(args)
      @options = Options.new(args).parse
      @git = GitCommand.new(options)
      @test = TestCommand.new(options)
      @outdated = Outdated.new(options)
      @update = Update.new(options)
      @sha = Sha.new(options)

      @logger = Logger.new(options)
      @logger.setup
    end

    def run
      logger.header('Starting lapidarist')
      logger.debug("directory: #{options.directory}", :options)
      logger.debug("test_script: #{options.test_script}", :options)

      unless git.clean?
        logger.footer('stopping, there are uncommitted changes')
        return 1
      end

      sha.record_good
      gems = outdated.run

      status = nil
      1.step do |attempt|
        logger.header("Attempt ##{attempt}")

        if gems.outdated.none?
          logger.footer('stopping, there are no applicable outdated gems')
          status = Status.new(gems, attempt)
          break
        end

        updated_gems = update.run(gems, attempt)

        if sha.new_commit_count.zero?
          logger.footer('nothing updated, trying again')
          gems = gems.merge(updated_gems)
          next
        end

        logger.header("Testing gem updates")
        if test.success?
          logger.footer('test passed, nothing left to do')
          gems = gems.merge(updated_gems)
          status = Status.new(gems, attempt)
          break
        else
          logger.footer('test failed, investigating failure')
        end

        failed_gem =
          if updated_gems.one?
            updated_but_failed_gem = updated_gems.first
            git.reset_hard('HEAD^')

            Gem.from(
              updated_but_failed_gem,
              attempt: attempt,
              status: :failed,
              updated_version: updated_but_failed_gem.latest_attempt[:version],
              level: updated_but_failed_gem.latest_attempt[:level]
            )
          else
            failed_gem_name = git.bisect(sha.last_good, test)
            updated_but_failed_gem = updated_gems.detect { |g| g.name == failed_gem_name }
            gems = gems.merge(updated_gems.take(sha.new_commit_count))
            sha.record_good

            Gem.from(
              updated_but_failed_gem,
              attempt: attempt,
              status: :failed,
              updated_version: updated_but_failed_gem.latest_attempt[:version],
              level: updated_but_failed_gem.latest_attempt[:level]
            )
          end
        gems = gems.merge(failed_gem)
      end

      Summary.new(gems, logger).display
      return status.to_i
    end

    private

    attr_reader :options, :git, :test, :outdated, :update, :sha, :logger
  end
end
