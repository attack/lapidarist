module Lapidarist
  class BundleCommand
    def initialize(directory)
      @directory = directory
    end

    def outdated
      Open3.popen2("bundle outdated --strict", chdir: directory) do |std_in, std_out|
        while line = std_out.gets
          gem = parse_gem_from(line)
          yield(gem) if gem
        end
      end
    end

    def update(gem)
      Open3.capture3("bundle update #{gem.name}", chdir: directory)
    end

    def version(gem)
      stdout = ''
      Open3.pipeline_r("bundle list", "grep \" #{gem.name} \"", chdir: directory) { |out, ts|
        stdout = out.read
      }

      result = stdout.match(/\((?<version>[0-9\.]+)\)/)
      result[:version] if result
    end

    private

    attr_reader :directory

    def parse_gem_from(line)
      regex = / \* (.*) \(newest (\d[\d\.]*\d)[,\s] installed (\d[\d\.]*\d)[\),\s]/.match line

      unless regex.nil?
        OutdatedGem.new(name: regex[1], newest_version: regex[2], current_version: regex[3])
      end
    end
  end
end
