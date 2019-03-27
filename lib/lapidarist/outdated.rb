module Lapidarist
  class Outdated
    def initialize(command_class, dependency_class)
      @command = command_class.new
      @dependency_class = dependency_class
    end

    def run
      Lapidarist.logger.header('Detecting outdated dependencies')

      dependencies = outdated_dependencies.each_with_object([]) do |dependency, results|
        reason = reason_to_skip(dependency)
        if reason.nil?
          Lapidarist.logger.info(" + #{dependency.log_s}")
          results.push dependency_class.from(dependency, position: results.length)
        else
          Lapidarist.logger.info(" - (#{reason}) #{dependency.log_s}")
          results.push dependency_class.from(dependency, position: results.length, status: :skipped, reason: reason)
        end
      end

      Lapidarist.logger.debug(dependencies.map(&:name), :order)

      Dependencies.new(dependencies)
    end

    private

    attr_reader :command, :dependency_class

    def all_outdated_dependencies
      @all_outdated_dependencies ||= command.outdated.to_a.
        select { |dependency| Lapidarist.config.only.empty? || Lapidarist.config.only.include?(dependency.name) }.
        reject { |dependency| Lapidarist.config.except.any? && Lapidarist.config.except.include?(dependency.name) }
    end

    def promoted_dependencies
      (Lapidarist.config.promoted - Lapidarist.config.demoted).each_with_object([]) do |dependency_name, results|
        promoted_dependency = all_outdated_dependencies.detect { |g| g.name == dependency_name }
        results.push(promoted_dependency) if promoted_dependency
      end
    end

    def demoted_dependencies
      Lapidarist.config.demoted.each_with_object([]) do |dependency_name, results|
        demoted_dependency = all_outdated_dependencies.detect { |g| g.name == dependency_name }
        results.push(demoted_dependency) if demoted_dependency
      end
    end

    def remaining_outdated_dependencies
      all_outdated_dependencies.reject do |dependency|
        Lapidarist.config.promoted.include?(dependency.name) ||
          Lapidarist.config.demoted.include?(dependency.name)
      end
    end

    def outdated_dependencies
      sorted_remaining_outdated_dependencies =
        if Lapidarist.config.random
          remaining_outdated_dependencies.shuffle(random: random)
        else
          remaining_outdated_dependencies
        end

      promoted_dependencies + sorted_remaining_outdated_dependencies + demoted_dependencies
    end

    def random
      Random.new(seed)
    end

    def seed
      seed = Lapidarist.config.seed || rand(100_000)
      Lapidarist.logger.info("seed: #{seed}", 1)
      seed
    end

    def reason_to_skip(dependency)
      if !Lapidarist.config.all && !dependency.dependency?
        :sub_dependency
      elsif Lapidarist.config.groups.any? && (Lapidarist.config.groups.map(&:name) & dependency.groups).none?
        :unmatched_group
      end
    end
  end
end
