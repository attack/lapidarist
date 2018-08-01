module Lapidarist
  class Gems
    include Enumerable

    def initialize(gems)
      @gems = gems
    end

    def each(&block)
      gems.sort_by(&:name).each(&block)
    end

    def outdated
      entries.select do |gem|
        if (Lapidarist.config.all || gem.dependency?) && gem.outdated?(recursive: Lapidarist.config.recursive)
          gem
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

    def merge(other_gems)
      Gems.new(
        Array(other_gems) + entries.select { |gem| !Array(other_gems).map(&:name).include?(gem.name) }
      )
    end

    def attempts
      entries.map(&:latest_attempt_number).compact.max
    end

    private

    attr_reader :gems
  end
end
