module Lapidarist
  class TestCommand
    def initialize
      @shell = Shell.new
    end

    def run
      shell.run(to_s)[1]
    end

    def success?
      run == 0
    end

    def to_s
      Lapidarist.config.test_script
    end

    private

    attr_reader :shell
  end
end
