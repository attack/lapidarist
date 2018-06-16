module Lapidarist
  class TestCommand
    def initialize(directory, command)
      @directory = directory
      @command = command
    end

    def run
      Open3.capture3(to_s, chdir: directory)[2]
    end

    def success?
      run == 0
    end

    def to_s
      "./#{command}"
    end

    private

    attr_reader :directory, :command
  end
end
