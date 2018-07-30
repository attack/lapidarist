module Lapidarist
  class Gems
    include Enumerable

    def initialize(gems, options)
      @gems = gems
      @options = options
    end

    def each(&block)
      gems.sort_by(&:name).each(&block)
    end

    def outdated
      entries.select do |gem|
        if (options.all || gem.dependency?) && gem.outdated?
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
        Array(other_gems) + entries.select { |gem| !Array(other_gems).map(&:name).include?(gem.name) },
        options
      )
    end

    def select_by_name(name)
      detect { |gem| name == gem.name }
    end

    def attempts
      entries.map(&:latest_attempt_number).compact.max
    end

    private

    attr_reader :gems, :options
  end
end
