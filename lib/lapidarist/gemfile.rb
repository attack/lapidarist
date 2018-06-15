module Lapidarist
  class Gemfile
    def initialize(directory)
      @directory = directory
    end

    def dependency?(gem)
      gemfile_lines.any? { |line| line =~ /^\s*gem\s*["']#{gem.name}["']/ }
    end

    private

    def gemfile_lines
      @gemfile_lines ||= File.readlines(directory.join('Gemfile'))
    end

    attr_reader :directory
  end
end
