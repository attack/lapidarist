module Lapidarist
  class Mod
    attr_reader :name, :position, :newest_version, :installed_version, :indirect, :attempts

    def initialize(name:, position: nil, newest_version:, installed_version:, indirect: false, attempts: {})
      @name = name
      @position = position
      @newest_version = newest_version
      @installed_version = installed_version
      @attempts = attempts
      @indirect = indirect
    end

    def self.from(mod, position: nil, attempt: 0, status: nil, reason: nil, updated_version: nil)
      attempts = mod.attempts

      if status
        attempts = attempts.merge(
          attempt => Attempt.new(
            status: status,
            reason: reason,
            version: updated_version
          )
        )
      end

      new(
        name: mod.name,
        position: position || mod.position,
        newest_version: mod.newest_version,
        installed_version: mod.installed_version,
        indirect: mod.indirect,
        attempts: attempts
      )
    end

    def ==(other_gem)
      current_status == other_gem.current_status &&
        name == other_gem.name &&
        installed_version == other_gem.installed_version &&
        newest_version == other_gem.newest_version &&
        indirect == other_gem.indirect
    end

    def groups
      []
    end

    def dependency?
      indirect != true
    end

    def current_status
      latest_attempt&.status
    end

    def outdated?(recursive: false)
      !newest_version.nil? && (current_status.nil? || (recursive && available_update_levels?))
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
      updated_attempt&.version
    end

    def what_changed
      if version_changed?
        "#{name} from #{clean_installed_version} to #{clean_updated_version}"
      else
        "#{name} dependencies"
      end
    end

    def available_update_levels?
      failed? && !version_change.next_level.nil?
    end

    def next_semver_level
      version_change.next_level
    end

    def log_s
      [
        "outdated mod: #{name}",
        "installed: #{clean_installed_version}",
        "newest: #{clean_newest_version}",
        "updated: #{clean_updated_version}",
        "indirect: #{indirect}"
      ].join(', ')
    end

    def latest_attempt_number
      @latest_attempt_number ||= attempts.keys.last
    end

    def latest_attempt
      @latest_attempt ||= attempts[latest_attempt_number] || NullAttempt.new
    end

    def clean_installed_version
      installed_version.to_s&.gsub(/\+incompatible/, '')
    end

    def clean_updated_version
      updated_version.to_s&.gsub(/\+incompatible/, '')
    end

    def clean_newest_version
      newest_version.to_s&.gsub(/\+incompatible/, '')
    end

    private

    def version_changed?
      updated_version && installed_version != updated_version
    end

    def updated_attempt
      @updated_attempt ||= attempts.values.detect(&:updated?)
    end

    def version_change
      @version_change ||= Lapidarist::VersionChange.new(
        installed: installed_version,
        updated: latest_attempt&.version
      )
    end
  end
end
