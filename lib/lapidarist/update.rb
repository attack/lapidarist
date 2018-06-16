module Lapidarist
  class Update
    def initialize(outdated_gems, options)
      @outdated_gems = outdated_gems
      @options = options
    end

    def run
      outdated_gems.each_with_index do |outdated_gem, index|
        update_gem(outdated_gem, index)
      end
    end

    private

    attr_reader :outdated_gems, :options

    def update_gem(outdated_gem, index)
      bundle = BundleCommand.new(options)
      bundle.update(outdated_gem)

      outdated_gem.target_version = bundle.version(outdated_gem)

      message = "Update #{outdated_gem.name} from #{outdated_gem.current_version} to #{outdated_gem.target_version}"

      git = GitCommand.new(options)
      git.add('Gemfile', 'Gemfile.lock')
      git.commit(message)
    end
  end
end
