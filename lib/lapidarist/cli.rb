module Lapidarist
  class CLI
    def initialize(args)
      @directory = Pathname.new(args.shift)
      @git = GitCommand.new(@directory)
      @test = TestCommand.new(@directory, args.shift)
    end

    def run
      failing_gem_names = []
      start_sha = git.head

      loop do
        outdated_gems = Outdated.new(directory).run
        remaing_outdated_gems = outdated_gems.select { |g| !failing_gem_names.include?(g.name) }
        break if remaing_outdated_gems.empty?

        Update.new(remaing_outdated_gems, directory: directory).run

        break if test.success?

        failing_gem_names << git.bisect(start_sha, test)
        start_sha = git.head
      end

      return 1
    end

    private

    attr_reader :directory, :git, :test
  end
end
