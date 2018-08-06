module Lapidarist
  class GroupConstraint
    attr_reader :name

    def initialize(input)
      parts = input.split(':')
      @name = parts[0]
    end
  end
end
