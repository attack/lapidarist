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
      outdated_gems.each_with_index do |outdated_gem, index|
        update_gem(outdated_gem, index)
      end

      git.log(before_sha) if options.debug
    end

    private

    attr_reader :options, :outdated_gems, :bundle, :git, :logger

    def update_gem(outdated_gem, index)
      logger.smart_header "Updating #{outdated_gem.name} from #{outdated_gem.current_version}"

      bundle.update(outdated_gem)
      outdated_gem.target_version = bundle.version(outdated_gem)

      git.add('Gemfile', 'Gemfile.lock')
      git.commit("Update #{outdated_gem.what_changed}")

      logger.footer "updated #{outdated_gem.name} to #{outdated_gem.target_version}"
    end
  end
end
