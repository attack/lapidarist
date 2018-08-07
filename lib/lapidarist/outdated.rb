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

    def all_outdated_gems
      @all_outdated_gems ||= bundle.outdated.to_a.
        select { |gem| Lapidarist.config.only.empty? || Lapidarist.config.only.include?(gem.name) }.
        reject { |gem| Lapidarist.config.except.any? && Lapidarist.config.except.include?(gem.name) }
    end

    def promoted_gems
      (Lapidarist.config.promoted - Lapidarist.config.demoted).map do |gem_name|
        all_outdated_gems.detect { |g| g.name == gem_name }
      end
    end

    def demoted_gems
      Lapidarist.config.demoted.map do |gem_name|
        all_outdated_gems.detect { |g| g.name == gem_name }
      end
    end

    def remaining_outdated_gems
      all_outdated_gems.reject do |gem|
        Lapidarist.config.promoted.include?(gem.name) ||
          Lapidarist.config.demoted.include?(gem.name)
      end
    end

    def outdated_gems
      sorted_remaining_outdated_gems =
        if Lapidarist.config.random
          remaining_outdated_gems.shuffle(random: random)
        else
          remaining_outdated_gems
        end

      promoted_gems + sorted_remaining_outdated_gems + demoted_gems
    end

    def random
      Random.new(seed)
    end

    def seed
      seed = Lapidarist.config.seed || rand(100_000)
      Lapidarist.logger.info("seed: #{seed}", 1)
      seed
    end

    def reason_to_skip(gem)
      if !Lapidarist.config.all && !gem.dependency?
        :sub_dependency
      elsif Lapidarist.config.groups.any? && (Lapidarist.config.groups.map(&:name) & gem.groups).none?
        :unmatched_group
      end
    end
  end
end
