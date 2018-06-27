module Lapidarist
  class Outdated
    def initialize(options)
      @options = options
      @bundle = BundleCommand.new(options)
      @gemfile = Gemfile.new(options)
      @logger = Logger.new(options)
    end

    def run
      bundle.outdated.each_with_object([]) do |gem, results|
        if options.all || gemfile.dependency?(gem)
          logger.info(gem.log_s)
          results.push gem
        else
          logger.info("(skip) #{gem.log_s}")
        end
      end
    end

    private

    attr_reader :bundle, :gemfile, :options, :logger
  end
end
