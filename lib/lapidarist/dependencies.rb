module Lapidarist
  class Dependencies
    include Enumerable

    def initialize(dependencies)
      @dependencies = dependencies
    end

    def each(&block)
      dependencies.sort_by(&:position).each(&block)
    end

    def outdated
      entries.select do |dependency|
        if (Lapidarist.config.all || dependency.dependency?) && dependency.outdated?(recursive: Lapidarist.config.recursive)
          dependency
        end
      end
    end

    def updated
      entries.select(&:updated?)
    end

    def skipped
      entries.select(&:skip?)
    end

    def failed
      entries.select(&:failed?)
    end

    def merge(other_dependencies)
      Dependencies.new(
        Array(other_dependencies) + entries.select { |dependency| !Array(other_dependencies).map(&:name).include?(dependency.name) }
      )
    end

    def attempts
      entries.map(&:latest_attempt_number).compact.max
    end

    private

    attr_reader :dependencies
  end
end
