module Lapidarist
  class Outdated
    def initialize(options)
      @options = options
      @bundle = BundleCommand.new(options)
      @gemfile = Gemfile.new(options)
    end

    def run
      bundle.outdated.each_with_object([]) do |gem, results|
        if options.all || gemfile.dependency?(gem)
          results.push gem
        end
      end
    end

    private

    attr_reader :bundle, :gemfile, :options
  end
end
