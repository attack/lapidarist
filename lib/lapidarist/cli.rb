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
      trap_interrupt

      unless git.clean?
        Lapidarist.logger.footer('stopping, there are uncommitted changes')
        return STATUS_ERROR
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

    rescue OptionParser::InvalidOption => e
      warn e.message
      warn 'For usage information, use --help'
      return STATUS_ERROR
    rescue Lapidarist::Abort => e
      git.reset_hard(sha.last_good)
      Summary.new(gems).display
      return STATUS_ERROR
    end

    def trap_interrupt
      Signal.trap('INT') do
        warn
        warn 'Cleaning up and exiting... Interrupt again to exit immediately.'

        Lapidarist.threads.stop

        raise Lapidarist::Abort
      end
    end

    private

    attr_reader :args, :git, :test, :update, :sha
  end
end
