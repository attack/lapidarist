module Lapidarist
  class FailedGem < Gem
    attr_reader :reason

    def initialize(name:, newest_version:, installed_version:, groups: [], attempt:)
      @reason = :failed
      super(name: name, newest_version: newest_version, installed_version: installed_version, groups: groups, attempt: attempt)
    end

    def self.from(gem, attempt:)
      new(
        name: gem.name,
        newest_version: gem.newest_version,
        installed_version: gem.installed_version,
        groups: gem.groups,
        attempt: attempt
      )
    end

    def failed?
      true
    end
  end
end
