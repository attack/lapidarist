module Lapidarist
  class Outdated
    def initialize(directory)
      @bundle = BundleCommand.new(directory)
      @gemfile = Gemfile.new(directory)
    end

    def run
      results = []

      bundle.outdated do |gem|
        if gemfile.dependency?(gem)
          results.push gem
        end
      end

      results
    end

    private

    attr_reader :bundle, :gemfile
  end
end
