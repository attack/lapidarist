module Lapidarist
  class Update
    def initialize(options)
      @options = options
      @bundle = BundleCommand.new(options)
      @git = GitCommand.new(options)
      @logger = Logger.new(options)
    end

    def run(gems, attempt)
      before_sha = git.head if options.debug

      logger.header('Updating outdated gems')

      take_limit =
        if options.update_limit
          [options.update_limit - gems.updated.length, 0].max
        else
          gems.outdated.length
        end

      changed_gems = gems.outdated.take(take_limit).map do |outdated_gem|
        update_gem(outdated_gem, attempt)
      end

      git.log(before_sha) if options.debug

      changed_gems
    end

    private

    attr_reader :options, :outdated_gems, :bundle, :git, :logger

    def update_gem(outdated_gem, attempt)
      logger.smart_header "Updating #{outdated_gem.name} from #{outdated_gem.installed_version}"

      bundle.update(outdated_gem)
      updated_version = bundle.version(outdated_gem)

      if git.clean?
        skipped_gem = SkippedGem.from(outdated_gem, reason: :nothing_to_update, attempt: attempt)
        logger.footer "nothing to update for #{skipped_gem.name}"

        skipped_gem
      else
        updated_gem = UpdatedGem.from(outdated_gem, updated_version: updated_version, attempt: attempt)
        logger.footer "updated #{updated_gem.name} to #{updated_gem.updated_version}"

        git.add('Gemfile', 'Gemfile.lock')
        git.commit("Update #{updated_gem.what_changed}")

        updated_gem
      end
    end
  end
end
