module Lapidarist
  class Outdated
    def initialize(options)
      @options = options
      @bundle = BundleCommand.new(options)
      @logger = Logger.new(options)
    end

    def run
      logger.header('Detecting outdated gems')

      gems = bundle.outdated.each_with_object([]) do |gem, results|
        reason = reason_to_skip(gem)
        if reason.nil?
          logger.info(" + #{gem.log_s}")
          results.push OutdatedGem.from(gem)
        else
          logger.info(" - (#{reason}) #{gem.log_s}")
          results.push SkippedGem.from(gem, reason: reason)
        end
      end

      Gems.new(gems, options)
    end

    private

    attr_reader :bundle, :options, :logger

    def reason_to_skip(gem)
      if !options.all && !gem.dependency?
        :sub_dependency
      elsif options.groups.any? && (options.groups & gem.groups).none?
        :unmatched_group
      end
    end
  end
end
