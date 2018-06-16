module Lapidarist
  class Gemfile
    def initialize(options)
      @options = options
    end

    def dependency?(gem)
      gemfile_lines.any? { |line| line =~ /^\s*gem\s*["']#{gem.name}["']/ }
    end

    private

    def gemfile_lines
      @gemfile_lines ||= File.readlines(options.directory.join('Gemfile'))
    end

    attr_reader :options
  end
end
