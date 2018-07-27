module Lapidarist
  class SkippedGem < Gem
    attr_reader :reason

    def initialize(name:, newest_version:, installed_version:, groups: [], reason:, attempt:)
      @reason = reason
      super(name: name, newest_version: newest_version, installed_version: installed_version, groups: groups, attempt: attempt)
    end

    def self.from(gem, reason:, attempt: nil)
      new(
        name: gem.name,
        newest_version: gem.newest_version,
        installed_version: gem.installed_version,
        groups: gem.groups,
        reason: reason,
        attempt: attempt
      )
    end

    def skip?
      true
    end
  end
end
