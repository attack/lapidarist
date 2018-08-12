module Lapidarist
  class Status
    def initialize(gems, attempt)
      @gems = gems
      @attempt = attempt
    end

    def to_i
      if gems.updated.any? || attempt == 1
        STATUS_SUCCESS
      else
        STATUS_FAILED
      end
    end

    private

    attr_reader :gems, :attempt
  end
end
