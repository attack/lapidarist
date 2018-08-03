module Lapidarist
  class Gem
    attr_reader :name, :position, :newest_version, :installed_version, :attempts

    def initialize(name:, position: nil, newest_version:, installed_version:, groups: [], attempts: {})
      @name = name
      @position = position
      @newest_version = newest_version
      @installed_version = installed_version
      @groups = groups
      @attempts = attempts
    end

    def self.from(gem, position: nil, attempt: 0, status: nil, reason: nil, updated_version: nil, level: nil)
      attempts = gem.attempts

      if status
        attempts = attempts.merge(
          attempt => {
            status: status,
            reason: reason,
            version: updated_version,
            level: level
          }
        )
      end

      new(
        name: gem.name,
        position: position || gem.position,
        newest_version: gem.newest_version,
        installed_version: gem.installed_version,
        groups: gem.groups,
        attempts: attempts
      )
    end

    def ==(other_gem)
      current_status == other_gem.current_status &&
        name == other_gem.name &&
        installed_version == other_gem.installed_version &&
        newest_version == other_gem.newest_version &&
        groups == other_gem.groups
    end

    def groups
      @groups.sort
    end

    def dependency?
      groups.any?
    end

    def current_status
      latest_attempt&.fetch(:status, nil)
    end

    def current_level
      latest_attempt&.fetch(:level, nil)
    end

    def outdated?(recursive: false)
      current_status.nil? || (recursive && available_update_levels?)
    end

    def failed?
      current_status == :failed
    end

    def skip?
      current_status == :skipped
    end

    def updated?
      current_status == :updated
    end

    def updated_version
      updated_attempt&.fetch(:version, nil)
    end

    def what_changed
      if version_changed?
        "#{name} from #{installed_version} to #{updated_version}"
      else
        "#{name} dependencies"
      end
    end

    def available_update_levels?
      failed? && current_level > PATCH
    end

    def next_semver_level
      if current_level
        LEVELS.detect { |level| level < current_level }
      else
        MAJOR
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

    def to_h
      {
        name: name,
        newest_version: newest_version,
        installed_version: installed_version,
        groups: groups,
        attempts: attempts.to_h
      }
    end

    def latest_attempt_number
      @latest_attempt_number ||= attempts.keys.last
    end

    def latest_attempt
      @latest_attempt ||= attempts[latest_attempt_number] || {}
    end

    private

    def version_changed?
      updated_version && installed_version != updated_version
    end

    def updated_attempt
      @updated_attempt ||= attempts.values.detect { |a| a[:status] == :updated }
    end
  end
end
