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
            git.reset_hard('HEAD^')
            Gem.from(updated_gems.first, attempt: attempt, status: :failed)
          else
            failed_gem_name = git.bisect(sha.last_good, test)
            sha.record_good
            gems = gems.merge(updated_gems.take(sha.new_commit_count))
            Gem.from(gems.select_by_name(failed_gem_name), attempt: attempt, status: :failed)
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
