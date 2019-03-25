module Lapidarist
  class Summary
    def initialize(dependencies)
      @dependencies = dependencies
    end

    def display
      Lapidarist.logger.summary ''
      Lapidarist.logger.summary 'Summary'
      Lapidarist.logger.summary '-'*50
      Lapidarist.logger.summary "#{object_count(dependencies.updated, 'dependency', 'dependencies')} updated, #{object_count(dependencies.failed, 'dependency', 'dependencies')} failed and #{object_count(dependencies.skipped, 'dependency', 'dependencies')} skipped in #{object_count(dependencies.attempts, 'attempt', 'attempts')}"
      summarize_attempts do |summary|
        Lapidarist.logger.summary summary
      end
    end

    def display_debug
      Lapidarist.logger.debug "#{object_count(dependencies.updated, 'dependency', 'dependencies')} updated, #{object_count(dependencies.failed, 'dependency', 'dependencies')} failed and #{object_count(dependencies.skipped, 'dependency', 'dependencies')} skipped in #{object_count(dependencies.attempts, 'attempt', 'attempts')}"
      summarize_attempts do |summary|
        Lapidarist.logger.debug summary
      end
    end

    private

    attr_reader :dependencies

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

    def summarize_attempts
      dependencies.each do |dependency|
        dependency.attempts.each do |i, data|
          summary =
            case data.status
            when :updated
              " + updated #{dependency.name} from #{dependency.installed_version} to #{data.version}"
            when :failed
              " x failed #{dependency.name} from #{dependency.installed_version} to #{data.version}"
            when :skipped
              " - skipped #{dependency.name} (#{data.reason})"
            end
          yield summary
        end
      end
    end
  end
end
