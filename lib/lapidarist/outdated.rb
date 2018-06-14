module Lapidarist
  class Outdated
    def initialize(directory)
      @directory = directory
    end

    def run
      results = []
      bundle = BundleCommand.new(directory)

      bundle.outdated do |gem|
        results.push gem
      end

      results
    end

    private

    attr_reader :directory
  end
end
