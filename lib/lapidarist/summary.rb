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
      gems.each do |gem|
        gem.attempts.each do |i, data|
          case data[:status]
          when :updated
            logger.summary " + updated #{gem.what_changed}"
          when :failed
            logger.summary " x failed #{gem.name}"
          when :skipped
            logger.summary " - skipped #{gem.name} (#{data[:reason]})"
          end
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
