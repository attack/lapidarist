module Lapidarist
  class CLI
    def initialize(args)
      @directory = args.pop
    end

    def run
      outdated_gems = Outdated.new(directory).run
      Update.new(outdated_gems, directory: directory).run

      return 1
    end

    private

    attr_reader :directory
  end
end
