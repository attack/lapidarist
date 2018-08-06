module Lapidarist
  class Level
    include Comparable

    attr_reader :name, :index

    def initialize(name:, index:)
      @name = name
      @index = index
    end

    def self.from(name)
      return unless name
      Lapidarist::LEVELS.detect { |l| l.name == name.to_sym }
    end

    def to_s
      name.to_s
    end

    def <=>(other)
      return 1 if index < other.index
      return 0 if index == other.index
      return -1 if index > other.index
    end
  end

  MAJOR = Level.new(name: :major, index: 1)
  MINOR = Level.new(name: :minor, index: 2)
  PATCH = Level.new(name: :patch, index: 3)

  LEVELS = [MAJOR, MINOR, PATCH].freeze
end
