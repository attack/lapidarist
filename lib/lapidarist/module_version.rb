module Lapidarist
  class ModuleVersion
    attr_reader :version

    def initialize(version:, sha: nil)
      @version = version
    end

    def ==(other_version)
      version == other_version.version
    end

    def to_s
      version
    end
  end
end
