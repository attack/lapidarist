module Lapidarist
  class CLI
    def initialize(args)
      @args = args
      @git = GitCommand.new
      @test = TestCommand.new
      @sha = Sha.new
    end

    def run
      Options.new(args).parse
      Lapidarist.logger.header('Starting lapidarist')
      trap_interrupt

      case Lapidarist.config.project
      when :go_mod
        command_class = Lapidarist::GoCommand
        dependency_class = Lapidarist::Mod
      else
        command_class = Lapidarist::BundleCommand
        dependency_class = Lapidarist::Gem
      end
      @update = Lapidarist::Update.new(command_class, dependency_class)

      unless git.clean?
        Lapidarist.logger.footer('stopping, there are uncommitted changes')
        return STATUS_ERROR
      end

      sha.record_good
      dependencies = Lapidarist::Outdated.new(command_class, dependency_class).run

      status = nil
      attempt = 0
      loop do
        attempt += 1
        Lapidarist.logger.header("Attempt ##{attempt}")

        if dependencies.outdated.none?
          Lapidarist.logger.footer('stopping, there are no applicable outdated dependencies')
          status = Status.new(dependencies, attempt)
          break
        end

        updated_dependencies = update.run(dependencies, attempt)

        if sha.new_commit_count.zero?
          Lapidarist.logger.footer('nothing updated, trying again')
          dependencies = dependencies.merge(updated_dependencies)
          next
        end

        Lapidarist.logger.header("Testing dependency updates")
        if test.success?
          Lapidarist.logger.footer('test passed, nothing left to do')
          dependencies = dependencies.merge(updated_dependencies)
          status = Status.new(dependencies, attempt)
          break
        else
          Lapidarist.logger.footer('test failed')
        end

        failed_dependency = Lapidarist::FindFailure.new(
          dependency_class,
          dependencies: updated_dependencies,
          attempt: attempt,
          last_good_sha: sha.last_good
        ).run
        dependencies = dependencies.merge(updated_dependencies.take(sha.new_commit_count)).merge(failed_dependency)
        sha.record_good

        if Lapidarist.config.debug
          Summary.new(dependencies).display_debug
        end
      end

      Summary.new(dependencies).display
      return status.to_i

    rescue OptionParser::InvalidOption => e
      warn e.message
      warn 'For usage information, use --help'
      return STATUS_ERROR
    rescue Lapidarist::Abort => e
      git.reset_hard(sha.last_good)
      Summary.new(dependencies).display
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
