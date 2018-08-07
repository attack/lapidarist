module Lapidarist
  class GemVersion
    attr_reader :version, :sha

    def initialize(version:, sha: nil)
      @version = version
      @sha = sha
    end

    def ==(other_version)
      version == other_version.version &&
        sha == other_version.sha
    end

    def to_s
      [version, sha].compact.join(' ')
    end
  end
end
