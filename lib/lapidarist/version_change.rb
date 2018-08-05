module Lapidarist
  class VersionChange
    def initialize(installed:, updated:)
      @installed = installed
      @updated = updated
    end

    def next_level
      if level
        LEVELS.detect { |l| l < level }
      else
        Lapidarist::MAJOR
      end
    end

    private

    attr_reader :installed, :updated

    def installed_segments
      @installed_segments ||= installed.split('.')
    end

    def updated_segments
      @updated_segments ||= updated&.split('.')
    end

    def level
      @level ||=
        if updated_segments && updated_segments[0] > installed_segments[0]
          Lapidarist::MAJOR
        elsif updated_segments && updated_segments[0] == installed_segments[0] && updated_segments[1] > installed_segments[1]
          Lapidarist::MINOR
        elsif updated_segments && updated_segments[0] == installed_segments[0] && updated_segments[1] == installed_segments[1] && updated_segments[2] > installed_segments[2]
          Lapidarist::PATCH
        end
    end
  end
end
