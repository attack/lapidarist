module Lapidarist
  class Outdated
    def initialize
      @bundle = BundleCommand.new
      @logger = Logger.new
    end

    def run
      logger.header('Detecting outdated gems')

      gems = bundle.outdated.each_with_object([]) do |gem, results|
        reason = reason_to_skip(gem)
        if reason.nil?
          logger.info(" + #{gem.log_s}")
          results.push Gem.from(gem)
        else
          logger.info(" - (#{reason}) #{gem.log_s}")
          results.push Gem.from(gem, status: :skipped, reason: reason)
        end
      end

      Gems.new(gems)
    end

    private

    attr_reader :bundle, :logger

    def reason_to_skip(gem)
      if !Lapidarist.config.all && !gem.dependency?
        :sub_dependency
      elsif Lapidarist.config.groups.any? && (Lapidarist.config.groups & gem.groups).none?
        :unmatched_group
      end
    end
  end
end
