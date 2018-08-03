module Lapidarist
  class Outdated
    def initialize
      @bundle = BundleCommand.new
    end

    def run
      Lapidarist.logger.header('Detecting outdated gems')

      gems = outdated_gems.each_with_object([]) do |gem, results|
        reason = reason_to_skip(gem)
        if reason.nil?
          Lapidarist.logger.info(" + #{gem.log_s}")
          results.push Gem.from(gem, position: results.length)
        else
          Lapidarist.logger.info(" - (#{reason}) #{gem.log_s}")
          results.push Gem.from(gem, position: results.length, status: :skipped, reason: reason)
        end
      end

      Lapidarist.logger.debug(gems.map(&:name), :order)

      Gems.new(gems)
    end

    private

    attr_reader :bundle

    def outdated_gems
      if Lapidarist.config.random
        bundle.outdated.to_a.shuffle(random: random)
      else
        bundle.outdated.to_a
      end
    end

    def random
      Random.new(seed)
    end

    def seed
      seed = Random.new_seed
      Lapidarist.logger.info("seed: #{seed}", 1)
      seed
    end

    def reason_to_skip(gem)
      if !Lapidarist.config.all && !gem.dependency?
        :sub_dependency
      elsif Lapidarist.config.groups.any? && (Lapidarist.config.groups & gem.groups).none?
        :unmatched_group
      end
    end
  end
end
