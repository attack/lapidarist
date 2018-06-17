module Lapidarist
  class CLI
    def initialize(args)
      @options = Options.new(args).parse
      @git = GitCommand.new(options)
      @test = TestCommand.new(options)
    end

    def run
      failing_gem_names = []
      start_sha = git.head
      update = Update.new(options)
      outdated = Outdated.new(options)

      loop do
        outdated_gems = outdated.run
        remaining_outdated_gems = outdated_gems.select { |g| !failing_gem_names.include?(g.name) }
        break if remaining_outdated_gems.empty?

        update.run(remaining_outdated_gems)

        break if test.success?

        failing_gem_names << git.bisect(start_sha, test)
        start_sha = git.head
      end

      return 1
    end

    private

    attr_reader :options, :git, :test
  end
end
