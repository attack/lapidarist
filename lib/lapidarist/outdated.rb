module Lapidarist
  class Outdated
    def initialize(options)
      @bundle = BundleCommand.new(options)
      @gemfile = Gemfile.new(options)
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
