module Lapidarist
  class TestCommand
    def initialize(options)
      @options = options
    end

    def run
      Open3.capture3(to_s, chdir: options.directory)[2]
    end

    def success?
      run == 0
    end

    def to_s
      "./#{options.test_script}"
    end

    private

    attr_reader :options
  end
end
