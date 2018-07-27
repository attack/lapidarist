module Lapidarist
  class UpdatedGem < Gem
    attr_reader :updated_version

    def initialize(name:, newest_version:, installed_version:, groups: [], updated_version:, attempt:)
      @updated_version = updated_version
      super(name: name, newest_version: newest_version, installed_version: installed_version, groups: groups, attempt: attempt)
    end

    def self.from(gem, updated_version:, attempt:)
      new(
        name: gem.name,
        newest_version: gem.newest_version,
        installed_version: gem.installed_version,
        groups: gem.groups,
        updated_version: updated_version,
        attempt: attempt
      )
    end

    def what_changed
      if version_changed?
        "#{name} from #{installed_version} to #{updated_version}"
      else
        "#{name} dependencies"
      end
    end

    def log_s
      [
        "outdated gem: #{name}",
        "installed: #{installed_version}",
        "newest: #{newest_version}",
        "updated: #{updated_version}"
      ].join(', ')
    end

    def updated?
      true
    end

    private

    def version_changed?
      installed_version != updated_version
    end
  end
end
