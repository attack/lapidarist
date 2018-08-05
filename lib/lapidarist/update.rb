module Lapidarist
  class Update
    def initialize
      @bundle = BundleCommand.new
      @git = GitCommand.new
    end

    def run(gems, attempt)
      before_sha = git.head if Lapidarist.config.debug

      Lapidarist.logger.header('Updating outdated gems')

      limit =
        if Lapidarist.config.update_limit
          [Lapidarist.config.update_limit - gems.updated.length, 0].max
        else
          gems.outdated.length
        end

      updated_gems = gems.outdated.take(limit).map do |outdated_gem|
        update_gem(outdated_gem, attempt)
      end

      git.log(before_sha) if Lapidarist.config.debug

      updated_gems
    end

    private

    attr_reader :outdated_gems, :bundle, :git

    def update_gem(outdated_gem, attempt)
      Lapidarist.logger.smart_header "Updating #{outdated_gem.name} from #{outdated_gem.installed_version}"

      available_semver_levels = [Lapidarist.config.version]
      available_semver_levels << outdated_gem.next_semver_level if Lapidarist.config.recursive
      semver_level_restriction = available_semver_levels.compact.min

      bundle.update(outdated_gem, level: semver_level_restriction)
      updated_version = bundle.version(outdated_gem)

      if git.clean?
        skipped_gem = Gem.from(outdated_gem, attempt: attempt, status: :skipped, reason: :nothing_to_update)
        Lapidarist.logger.footer "nothing to update for #{skipped_gem.name}"

        skipped_gem
      else
        updated_gem = Gem.from(outdated_gem, attempt: attempt, status: :updated, updated_version: updated_version)
        Lapidarist.logger.footer "updated #{updated_gem.name} to #{updated_gem.updated_version}"

        git.add('Gemfile', 'Gemfile.lock')
        git.commit("Update #{updated_gem.what_changed}")

        updated_gem
      end
    end
  end
end
