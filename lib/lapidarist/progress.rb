module Lapidarist
  class Progress
    attr_reader :attempts

    def initialize
      @attempts = []
    end

    def attempt!
      attempt = Attempt.new
      @attempts << attempt
      attempt
    end

    def failed_gems
      attempts.map { |a| a.failed }.compact
    end

    def updated_gems
      attempts.map { |a| a.updated }.flatten(1).compact
    end

    def exit_status
      success? ? 0 : 1
    end

    private

    def success?
      updated_gems.any? || attempts.one?
    end
  end
end
