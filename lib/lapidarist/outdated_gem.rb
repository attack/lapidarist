module Lapidarist
  class OutdatedGem
    attr_reader :name, :current_version, :newest_version, :target_version

    def initialize(name:, current_version:, newest_version:, groups: [])
      @name = name
      @current_version = current_version
      @newest_version = newest_version
      @groups = groups
    end

    def target_version=(version)
      @target_version = version
    end

    def what_changed
      if updated?
        "#{name} from #{current_version} to #{target_version}"
      else
        "#{name} dependencies"
      end
    end

    def ==(other_gem)
      name == other_gem.name &&
        current_version == other_gem.current_version &&
        newest_version == other_gem.newest_version &&
        groups == other_gem.groups
    end

    def log_s
      parts = [
        "outdated gem: #{name}",
        "current: #{current_version}",
        "newest: #{newest_version}"
      ]

      if target_version
        parts << "newest: #{target_version}"
      end

      parts.join(', ')
    end

    def groups
      @groups.sort
    end

    def dependency?
      groups.any?
    end

    private

    def updated?
      current_version != target_version
    end
  end
end
