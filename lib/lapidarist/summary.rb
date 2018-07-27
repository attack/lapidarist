module Lapidarist
  class Summary
    def initialize(gems, logger)
      @gems = gems
      @logger = logger
    end

    def display
      logger.summary ''
      logger.summary 'Summary'
      logger.summary '-'*50
      logger.summary "#{object_count(gems.updated, 'gem', 'gems')} updated, #{object_count(gems.failed, 'gem', 'gems')} failed and #{object_count(gems.skipped, 'gem', 'gems')} skipped in #{object_count(gems.attempts, 'attempt', 'attempts')}"
      gems.grouped_by_attempt.each do |attempt, gems_for_attempt|
        if attempt
          logger.summary "attempt ##{attempt}: #{object_count(gems_for_attempt.updated, 'gem', 'gems')} updated, #{object_count(gems_for_attempt.failed, 'gem', 'gems')} failed"
        end
      end
      gems.grouped_by_attempt.each do |attempt, gems_for_attempt|
        gems_for_attempt.updated.each do |updated_gem|
          logger.summary " + updated #{updated_gem.what_changed}"
        end
        gems_for_attempt.skipped.each do |skipped_gem|
          logger.summary " - skipped #{skipped_gem.name} (#{skipped_gem.reason})"
        end
        gems_for_attempt.failed.each do |failed_gem|
          logger.summary " x failed #{failed_gem.name}"
        end
      end
    end

    private

    attr_reader :gems, :logger

    def object_count(objects_or_length, singlular, plural)
      length =
        if objects_or_length.respond_to?(:length)
          objects_or_length.length
        else
          objects_or_length
        end

      if length == 1
        "1 #{singlular}"
      else
        "#{length} #{plural}"
      end
    end
  end
end
