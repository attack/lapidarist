module Lapidarist
  class Summary
    def initialize(progress, logger)
      @progress = progress
      @logger = logger
    end

    def display
      logger.summary ''
      logger.summary 'Summary'
      logger.summary '-'*50
      logger.summary "updated #{object_count(progress.updated_gems, 'gem', 'gems')} and skipped #{object_count(progress.failed_gems, 'gem', 'gems')} in #{object_count(progress.attempts, 'attempt', 'attempts')}"
      progress.attempts.each_with_index do |attempt, i|
        logger.summary "attempt ##{i}: #{object_count(attempt.updated, 'gem', 'gems')} updated, #{object_count(attempt.failed, 'gem', 'gems')} failed"
      end
      progress.attempts.each do |attempt|
        attempt.updated.each do |updated_gem|
          logger.summary " + updated #{updated_gem.what_changed}"
        end
        logger.summary " - skipped #{attempt.failed.name}" unless attempt.failed.nil?
      end
    end

    private

    attr_reader :progress, :logger

    def object_count(objects, singlular, plural)
      if Array(objects).one?
        "1 #{singlular}"
      else
        "#{Array(objects).length} #{plural}"
      end
    end
  end
end
