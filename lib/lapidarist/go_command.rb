require 'json'

module Lapidarist
  class GoCommand
    def initialize
      @shell = Shell.new
    end

    def outdated
      Enumerator.new do |y|
        json_line = []
        shell.run_out_only('go list -mod=vendor -u -m -json all') do |std_out|
          while line = std_out.gets
            Lapidarist.logger.std_out_err(line, 'go list')
            json_line << line

            if line == "}\n" || line == "}"
              parsed_line = JSON.load(json_line.join(" "))
              json_line = []

              mod = parse_module_from(parsed_line)
              if mod && mod.outdated?
                y.yield(mod)
              end
            end
          end
        end
      end
    end

    def update(mod, level: MAJOR)
      go_version = Lapidarist::GoVersion.new(installed: mod.installed_version)
      shell.run("go get -u #{mod.name}@#{go_version.constraint(level)}")
      shell.run("go mod tidy")
    end

    def version(mod)
      json, status = shell.run_out_only("go list -mod=vendor -u -m -json #{mod.name}")
      parsed_json = JSON.load(json)
      Lapidarist::ModuleVersion.new(version: parsed_json["Version"]) if parsed_json
    end

    def files
      ['go.mod', 'go.sum']
    end

    private

    attr_reader :shell

    def parse_module_from(json_line)
      update = json_line.fetch("Update", {})

      Mod.new(
        name: json_line["Path"],
        newest_version: update.key?("Version") ? Lapidarist::ModuleVersion.new(version: update["Version"]) : nil,
        installed_version: Lapidarist::ModuleVersion.new(version: json_line["Version"]),
        indirect: json_line.fetch("Indirect", "false") == "true" || json_line.fetch("Indirect", false) == true
      )
    end
  end
end
