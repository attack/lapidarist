module Lapidarist
  class Status
    def initialize(gems, attempt)
      @gems = gems
      @attempt = attempt
    end

    def to_i
      gems.updated.any? || attempt == 1
    end

    private

    attr_reader :gems, :attempt
  end
end
