module Lapidarist
  class LevelConstraint
    def initialize(gem)
      @gem = gem
    end

    def maximum
      available_semver_levels.compact.min
    end

    private

    attr_reader :gem

    def available_semver_levels
      available_semver_levels = [default_constraint]
      available_semver_levels << gem.next_semver_level if Lapidarist.config.recursive
      available_semver_levels
    end

    def default_constraint
      if Lapidarist.config.groups.any?
        Lapidarist.config.groups.select { |g| gem.groups.include?(g.name) }.min_by(&:level).level
      else
        Lapidarist.config.version
      end
    end
  end
end
