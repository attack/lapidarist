module Lapidarist
  class GitCommand
    def initialize(directory)
      @directory = directory
    end

    def add(*files)
      Open3.capture3("git add #{files.join(' ')}", chdir: directory)
    end

    def commit(message)
      Open3.capture3("git commit -m '#{message}'", chdir: directory)
    end

    private

    attr_reader :directory
  end
end
