module Lapidarist
  class Summary
    def initialize(gems)
      @gems = gems
    end

    def display
      Lapidarist.logger.summary ''
      Lapidarist.logger.summary 'Summary'
      Lapidarist.logger.summary '-'*50
      Lapidarist.logger.summary "#{object_count(gems.updated, 'gem', 'gems')} updated, #{object_count(gems.failed, 'gem', 'gems')} failed and #{object_count(gems.skipped, 'gem', 'gems')} skipped in #{object_count(gems.attempts, 'attempt', 'attempts')}"
      gems.each do |gem|
        gem.attempts.each do |i, data|
          case data[:status]
          when :updated
            Lapidarist.logger.summary " + updated #{gem.name} from #{gem.installed_version} to #{data[:version]}"
          when :failed
            Lapidarist.logger.summary " x failed #{gem.name} from #{gem.installed_version} to #{data[:version]}"
          when :skipped
            Lapidarist.logger.summary " - skipped #{gem.name} (#{data[:reason]})"
          end
        end
      end
    end

    private

    attr_reader :gems

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
