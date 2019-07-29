module Lapidarist
  class Attempt
    attr_reader :status, :reason, :version

    def initialize(status:, reason:, version:)
      @status = status
      @reason = reason
      @version = version
    end

    def updated?
      status == :updated
    end

    def ==(other_attempt)
      return false unless other_attempt

      version == other_attempt.version
    end
  end
end
