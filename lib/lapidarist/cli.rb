module Lapidarist
  class CLI
    def initialize(args)
      @directory = Pathname.new(args.shift)
      @git = GitCommand.new(@directory)
      @test = TestCommand.new(@directory, args.shift)
    end

    def run
      start_sha = git.head

      outdated_gems = Outdated.new(directory).run
      Update.new(outdated_gems, directory: directory).run

      git.bisect(start_sha, test)

      return 1
    end

    private

    attr_reader :directory, :git, :test
  end
end
