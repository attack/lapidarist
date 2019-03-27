module Lapidarist
  class GoVersion
    def initialize(installed:)
      @installed = installed
    end

    def constraint(level = Lapidarist::MAJOR)
      case level
      when Lapidarist::MAJOR
        "latest"
      when Lapidarist::MINOR
        v = [installed_segments[0].to_i + 1, '0', '0'].join('.')
        "'<v#{v}'"
      when Lapidarist::PATCH
        v = [installed_segments[0], installed_segments[1].to_i + 1, '0'].join('.')
        "'<v#{v}'"
      end
    end

    private

    attr_reader :installed

    def installed_segments
      @installed_segments ||= installed.version.gsub(/v/, '').split('.')
    end
  end
end
