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

      limit =
        if options.update_limit
          [options.update_limit - gems.updated.length, 0].max
        else
          gems.outdated.length
        end

      updated_gems = gems.outdated.take(limit).map do |outdated_gem|
        update_gem(outdated_gem, attempt)
      end

      git.log(before_sha) if options.debug

      updated_gems
    end

    private

    attr_reader :options, :outdated_gems, :bundle, :git, :logger

    def update_gem(outdated_gem, attempt)
      logger.smart_header "Updating #{outdated_gem.name} from #{outdated_gem.installed_version}"

      bundle.update(outdated_gem)
      updated_version = bundle.version(outdated_gem)

      if git.clean?
        skipped_gem = Gem.from(outdated_gem, attempt: attempt, status: :skipped, reason: :nothing_to_update)
        logger.footer "nothing to update for #{skipped_gem.name}"

        skipped_gem
      else
        updated_gem = Gem.from(outdated_gem, attempt: attempt, status: :updated, updated_version: updated_version)
        logger.footer "updated #{updated_gem.name} to #{updated_gem.updated_version}"

        git.add('Gemfile', 'Gemfile.lock')
        git.commit("Update #{updated_gem.what_changed}")

        updated_gem
      end
    end
  end
end
