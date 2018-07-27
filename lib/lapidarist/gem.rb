module Lapidarist
  class Gem
    attr_reader :name, :newest_version, :installed_version, :attempt

    def initialize(name:, newest_version:, installed_version:, groups: [], attempt: nil)
      @name = name
      @newest_version = newest_version
      @installed_version = installed_version
      @groups = groups
      @attempt = attempt
    end

    def what_changed
      "#{name} dependencies"
    end

    def ==(other_gem)
      self.class.name == other_gem.class.name &&
        name == other_gem.name &&
        installed_version == other_gem.installed_version &&
        newest_version == other_gem.newest_version &&
        groups == other_gem.groups
    end

    def log_s
      [
        "outdated gem: #{name}",
        "installed: #{installed_version}",
        "newest: #{newest_version}"
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
        attempt: attempt,
        class: self.class.to_s
      }
    end

    def updated?
      false
    end

    def skip?
      false
    end

    def failed?
      false
    end
  end
end
