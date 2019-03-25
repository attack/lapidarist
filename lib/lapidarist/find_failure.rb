module Lapidarist
  class FindFailure
    def initialize(dependencies:, attempt:, last_good_sha:)
      @dependencies = dependencies
      @attempt = attempt
      @last_good_sha = last_good_sha
      @git = GitCommand.new
      @test = TestCommand.new
    end

    def run
      Lapidarist.logger.header('Investigating failure')

      updated_but_failed_dependency =
        if dependencies.one?
          git.reset_hard('HEAD^')
          dependencies.first
        else
          failed_dependency_name = git.bisect(last_good_sha, test)
          dependencies.detect { |dependency| dependency.name == failed_dependency_name }
        end

      Gem.from(
        updated_but_failed_dependency,
        attempt: attempt,
        status: :failed,
        updated_version: updated_but_failed_dependency.latest_attempt.version
      )
    end

    private

    attr_reader :dependencies, :attempt, :last_good_sha, :git, :test
  end
end
