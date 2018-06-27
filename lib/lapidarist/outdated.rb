module Lapidarist
  class Outdated
    def initialize(options)
      @options = options
      @bundle = BundleCommand.new(options)
      @gemfile = Gemfile.new(options)
      @logger = Logger.new(options)
    end

    def run
      logger.header('Detecting outdated gems')

      bundle.outdated.each_with_object([]) do |gem, results|
        if options.all || gemfile.dependency?(gem)
          # adjust logging
          logger.info(" + #{gem.log_s}")
          results.push gem
        else
          # adjust logging
          logger.info(" - (skip) #{gem.log_s}")
        end
      end
    end

    private

    attr_reader :bundle, :gemfile, :options, :logger
  end
end
