module Lapidarist
  class CLI
    def initialize(args)
      @args = args
      @git = GitCommand.new
      @test = TestCommand.new
      @outdated = Outdated.new
      @update = Update.new
      @sha = Sha.new
    end

    def run
      Options.new(args).parse
      Lapidarist.logger.header('Starting lapidarist')
      Lapidarist.logger.debug("directory: #{Lapidarist.config.directory}", :options)
      Lapidarist.logger.debug("test_script: #{Lapidarist.config.test_script}", :options)

      unless git.clean?
        Lapidarist.logger.footer('stopping, there are uncommitted changes')
        return 1
      end

      sha.record_good
      gems = outdated.run

      status = nil
      attempt = 0
      loop do
        attempt += 1
        Lapidarist.logger.header("Attempt ##{attempt}")

        if gems.outdated.none?
          Lapidarist.logger.footer('stopping, there are no applicable outdated gems')
          status = Status.new(gems, attempt)
          break
        end

        updated_gems = update.run(gems, attempt)

        if sha.new_commit_count.zero?
          Lapidarist.logger.footer('nothing updated, trying again')
          gems = gems.merge(updated_gems)
          next
        end

        Lapidarist.logger.header("Testing gem updates")
        if test.success?
          Lapidarist.logger.footer('test passed, nothing left to do')
          gems = gems.merge(updated_gems)
          status = Status.new(gems, attempt)
          break
        else
          Lapidarist.logger.footer('test failed, investigating failure')
        end

        failed_gem =
          if updated_gems.one?
            updated_but_failed_gem = updated_gems.first
            git.reset_hard('HEAD^')

            Gem.from(
              updated_but_failed_gem,
              attempt: attempt,
              status: :failed,
              updated_version: updated_but_failed_gem.latest_attempt.version
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
              updated_version: updated_but_failed_gem.latest_attempt.version
            )
          end
        gems = gems.merge(failed_gem)
      end

      Summary.new(gems).display
      return status.to_i
    end

    private

    attr_reader :args, :git, :test, :outdated, :update, :sha
  end
end
