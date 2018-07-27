module Lapidarist
  class OutdatedGem < Gem
    def self.from(gem)
      new(
        name: gem.name,
        newest_version: gem.newest_version,
        installed_version: gem.installed_version,
        groups: gem.groups
      )
    end
  end
end
