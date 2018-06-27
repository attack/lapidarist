module Lapidarist
  class Update
    def initialize(options)
      @bundle = BundleCommand.new(options)
      @git = GitCommand.new(options)
      @logger = Logger.new(options)
    end

    def run(outdated_gems)
      outdated_gems.each_with_index do |outdated_gem, index|
        update_gem(outdated_gem, index)
      end
    end

    private

    attr_reader :outdated_gems, :bundle, :git, :logger

    def update_gem(outdated_gem, index)
      bundle.update(outdated_gem)

      outdated_gem.target_version = bundle.version(outdated_gem)
      logger.info "update #{outdated_gem.name}: #{outdated_gem.current_version} > #{outdated_gem.target_version}"

      git.add('Gemfile', 'Gemfile.lock')
      git.commit("Update #{outdated_gem.what_changed}")
    end
  end
end
