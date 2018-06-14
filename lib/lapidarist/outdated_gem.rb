module Lapidarist
  class OutdatedGem
    attr_reader :name, :current_version, :newest_version, :target_version

    def initialize(name:, current_version:, newest_version:)
      @name = name
      @current_version = current_version
      @newest_version = newest_version
    end

    def target_version=(version)
      @target_version = version
    end
  end
end
