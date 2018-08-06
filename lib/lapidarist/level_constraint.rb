module Lapidarist
  class LevelConstraint
    def initialize(gem)
      @gem = gem
    end

    def maximum
      available_semver_levels = [Lapidarist.config.version]
      available_semver_levels << gem.next_semver_level if Lapidarist.config.recursive
      available_semver_levels.compact.min
    end

    private

    attr_reader :gem
  end
end
