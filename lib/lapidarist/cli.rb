module Lapidarist
  class CLI
    def initialize(args)
      @args = args
      @git = GitCommand.new
      @test = TestCommand.new
      @update = Update.new
      @sha = Sha.new
    end

    def run
      Options.new(args).parse
      Lapidarist.logger.header('Starting lapidarist')

      unless git.clean?
        Lapidarist.logger.footer('stopping, there are uncommitted changes')
        return 1
      end

      sha.record_good
      gems = Lapidarist::Outdated.new.run

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
          Lapidarist.logger.footer('test failed')
        end

        failed_gem = Lapidarist::FindFailure.new(
          gems: updated_gems,
          attempt: attempt,
          last_good_sha: sha.last_good
        ).run
        gems = gems.merge(updated_gems.take(sha.new_commit_count)).merge(failed_gem)
        sha.record_good
      end

      Summary.new(gems).display
      return status.to_i
    end

    private

    attr_reader :args, :git, :test, :update, :sha
  end
end
