module Lapidarist
  class Attempt
    attr_reader :updated, :failed

    def initialize
      @updated = []
    end

    def updated!(gems)
      @updated = gems
    end

    def failed!(gem)
      @failed = gem
    end
  end
end
