module Lapidarist
  class Sha
    def initialize
      @good_shas = []
      @git = GitCommand.new
    end

    def record_good
      good_sha = git.head
      Lapidarist.logger.debug("good sha: #{good_sha}")
      @good_shas << good_sha
    end

    def last_good
      good_shas.last
    end

    def new_commit_count
      git.count_commits(last_good, 'HEAD')
    end

    private

    attr_reader :good_shas, :git
  end
end
