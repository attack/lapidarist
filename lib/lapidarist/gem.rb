module Lapidarist
  class Gem
    attr_reader :name, :newest_version, :installed_version, :updated_version, :attempt, :status, :reason

    def initialize(name:, newest_version:, installed_version:, groups: [], updated_version: nil, attempt: nil, status: nil, reason: nil)
      @name = name
      @newest_version = newest_version
      @installed_version = installed_version
      @groups = groups
      @attempt = attempt
      @updated_version = updated_version
      @status = status
      @reason = reason
    end

    def self.from(gem, attempt: nil, status: nil, reason: nil, updated_version: nil)
      new(
        name: gem.name,
        newest_version: gem.newest_version,
        installed_version: gem.installed_version,
        groups: gem.groups,
        updated_version: updated_version,
        attempt: attempt,
        status: status,
        reason: reason
      )
    end

    def what_changed
      if version_changed?
        "#{name} from #{installed_version} to #{updated_version}"
      else
        "#{name} dependencies"
      end
    end


    def ==(other_gem)
      status == other_gem.status &&
        name == other_gem.name &&
        installed_version == other_gem.installed_version &&
        newest_version == other_gem.newest_version &&
        groups == other_gem.groups
    end

    def log_s
      [
        "outdated gem: #{name}",
        "installed: #{installed_version}",
        "newest: #{newest_version}",
        "updated: #{updated_version}"
      ].join(', ')
    end

    def groups
      @groups.sort
    end

    def dependency?
      groups.any?
    end

    def to_h
      {
        name: name,
        newest_version: newest_version,
        installed_version: installed_version,
        groups: groups,
        attempt: attempt
      }
    end

    def outdated?
      status.nil?
    end

    def failed?
      status == :failed
    end

    def skip?
      status == :skipped
    end

    def updated?
      status == :updated
    end

    private

    def version_changed?
      updated_version && installed_version != updated_version
    end
  end
end
