module Lapidarist
  class FindFailure
    def initialize(gems:, attempt:, last_good_sha:)
      @gems = gems
      @attempt = attempt
      @last_good_sha = last_good_sha
      @git = GitCommand.new
      @test = TestCommand.new
    end

    def run
      Lapidarist.logger.header('Investigating failure')

      updated_but_failed_gem =
        if gems.one?
          git.reset_hard('HEAD^')
          gems.first
        else
          failed_gem_name = git.bisect(last_good_sha, test)
          gems.detect { |gem| gem.name == failed_gem_name }
        end

      Gem.from(
        updated_but_failed_gem,
        attempt: attempt,
        status: :failed,
        updated_version: updated_but_failed_gem.latest_attempt.version
      )
    end

    private

    attr_reader :gems, :attempt, :last_good_sha, :git, :test
  end
end
