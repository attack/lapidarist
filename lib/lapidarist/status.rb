module Lapidarist
  class Status
    def initialize(dependencies, attempt)
      @dependencies = dependencies
      @attempt = attempt
    end

    def to_i
      if dependencies.updated.any? || attempt == 1
        STATUS_SUCCESS
      else
        STATUS_FAILED
      end
    end

    private

    attr_reader :dependencies, :attempt
  end
end
