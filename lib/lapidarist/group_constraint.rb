module Lapidarist
  class GroupConstraint
    attr_reader :name

    def initialize(input)
      parts = input.split(':')
      @name = parts[0]
      @level = Lapidarist::Level.from(parts[1])
    end

    def level
      @level || Lapidarist.config.version
    end
  end
end
