module Lapidarist
  class Update
    def initialize(options)
      @options = options
      @bundle = BundleCommand.new(options)
      @git = GitCommand.new(options)
      @logger = Logger.new(options)
    end

    def run(outdated_gems)
      before_sha = git.head if options.debug

      logger.header('Updating outdated gems')
      updated_gems = outdated_gems.select do |outdated_gem|
        update_gem(outdated_gem)
      end

      git.log(before_sha) if options.debug

      updated_gems
    end

    private

    attr_reader :options, :outdated_gems, :bundle, :git, :logger

    def update_gem(outdated_gem)
      logger.smart_header "Updating #{outdated_gem.name} from #{outdated_gem.current_version}"

      bundle.update(outdated_gem)
      outdated_gem.target_version = bundle.version(outdated_gem)

      if git.clean?
        logger.footer "nothing to update for #{outdated_gem.name}"
        false
      else
        git.add('Gemfile', 'Gemfile.lock')
        git.commit("Update #{outdated_gem.what_changed}")

        logger.footer "updated #{outdated_gem.name} to #{outdated_gem.target_version}"
        true
      end
    end
  end
end
