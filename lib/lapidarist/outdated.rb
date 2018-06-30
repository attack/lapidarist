module Lapidarist
  class Outdated
    def initialize(options)
      @options = options
      @bundle = BundleCommand.new(options)
      @gemfile = Gemfile.new(options)
      @logger = Logger.new(options)
    end

    def run(failed_gem_names = [])
      logger.header('Detecting outdated gems')

      gems = bundle.outdated.each_with_object([]) do |gem, results|
        reason = reason_to_skip(gem, failed_gem_names)
        if reason.nil?
          logger.info(" + #{gem.log_s}")
          results.push gem
        else
          logger.info(" - (#{reason}) #{gem.log_s}")
        end
      end

      if options.update_limit
        gems = gems.take(options.update_limit)
      end

      gems
    end

    private

    attr_reader :bundle, :gemfile, :options, :logger

    def reason_to_skip(gem, failed_gem_names)
      if failed_gem_names.include?(gem.name)
        :failed
      elsif !options.all && !gemfile.dependency?(gem)
        :sub_dependency
      end
    end
  end
end
