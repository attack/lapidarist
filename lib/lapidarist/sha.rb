module Lapidarist
  class Sha
    def initialize(options)
      @good_shas = []
      @git = GitCommand.new(options)
      @logger = Logger.new(options)
    end

    def record_good
      good_sha = git.head
      logger.debug("good sha: #{good_sha}")
      @good_shas << good_sha
    end

    def last_good
      good_shas.last
    end

    def new_commit_count
      git.count_commits(previous_good, last_good)
    end

    private

    attr_reader :good_shas, :git, :logger

    def previous_good
      good_shas[-2]
    end
  end
end
