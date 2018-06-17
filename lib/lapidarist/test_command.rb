module Lapidarist
  class TestCommand
    def initialize(options)
      @options = options
      @shell = Shell.new(options)
    end

    def run
      shell.run(to_s)[2]
    end

    def success?
      run == 0
    end

    def to_s
      "./#{options.test_script}"
    end

    private

    attr_reader :options, :shell
  end
end
