module Lapidarist
  class Outdated
    def initialize(options)
      @options = options
      @bundle = BundleCommand.new(options)
      @gemfile = Gemfile.new(options)
      @logger = Logger.new(options)
    end

    def run(failed_gems: [], updated_count: 0)
      logger.header('Detecting outdated gems')

      gems = bundle.outdated.each_with_object([]) do |gem, results|
        reason = reason_to_skip(gem, failed_gems)
        if reason.nil?
          logger.info(" + #{gem.log_s}")
          results.push gem
        else
          logger.info(" - (#{reason}) #{gem.log_s}")
        end
      end

      if options.update_limit
        remaining_gems = [options.update_limit - updated_count, 0].max
        gems = gems.take(remaining_gems)
      end

      gems
    end

    private

    attr_reader :bundle, :gemfile, :options, :logger

    def reason_to_skip(gem, failed_gems)
      if failed_gems.include?(gem)
        :failed
      elsif !options.all && !gemfile.dependency?(gem)
        :sub_dependency
      elsif options.groups.any? && (options.groups & gem.groups).none?
        :unmatched_group
      end
    end
  end
end
