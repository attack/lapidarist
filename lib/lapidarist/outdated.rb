module Lapidarist
  class Outdated
    def initialize(directory)
      @bundle = BundleCommand.new(directory)
      @gemfile = Gemfile.new(directory)
    end

    def run
      bundle.outdated.each_with_object([]) do |gem, results|
        if gemfile.dependency?(gem)
          results.push gem
        end
      end
    end

    private

    attr_reader :bundle, :gemfile
  end
end
