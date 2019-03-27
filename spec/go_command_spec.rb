require 'spec_helper'

RSpec.describe Lapidarist::GoCommand do
  describe '#outdated' do
    it 'calls go list' do
      shell = stub_shell

      Lapidarist::GoCommand.new.outdated.to_a

      expect(shell).to have_received(:run_out_only).with('go list -u -m -json all')
    end

    it 'parses each line from the output and returns outdated module objects' do
      std_out = double(:STD_OUT)
      allow(std_out).to receive(:gets).and_return(
        '{',
        '  "Path": "gopkg.in/yaml.v2",',
        '  "Version": "v2.2.2",',
        '  "Indirect": "true"',
        '}',
        '{',
        '  "Path": "gopkg.in/warnings.v0",',
        '  "Version": "v0.1.2",',
        '  "Update": {',
        '    "Version": "v0.1.3"',
        '  }',
        '}',
        '{',
        '  "Path": "gopkg.in/src-d/go-git.v4",',
        '  "Version": "v4.8.1",',
        '  "Update": {',
        '    "Version": "v4.10.0"',
        '  }',
        '}',
        nil
      )
      stub_shell { std_out }

      outdated_modules = Lapidarist::GoCommand.new.outdated.to_a

      expect(outdated_modules.length).to eq 3
      expect(outdated_modules[0]).to eq Lapidarist::Mod.new(name: 'gopkg.in/yaml.v2', newest_version: Lapidarist::ModuleVersion.new(version: nil), installed_version: Lapidarist::ModuleVersion.new(version: 'v2.2.2'), indirect: true)
      expect(outdated_modules[1]).to eq Lapidarist::Mod.new(name: 'gopkg.in/warnings.v0', newest_version: Lapidarist::ModuleVersion.new(version: 'v0.1.3'), installed_version: Lapidarist::ModuleVersion.new(version: 'v0.1.2'), indirect: false)
      expect(outdated_modules[2]).to eq Lapidarist::Mod.new(name: 'gopkg.in/src-d/go-git.v4', newest_version: Lapidarist::ModuleVersion.new(version: 'v4.10.0'), installed_version: Lapidarist::ModuleVersion.new(version: 'v4.8.1'), indirect: false)
    end
  end

  describe '#update' do
    it 'calls go get -u' do
      shell = stub_shell

      mod = stub_module(name: 'gopkg.in/yaml.v2', newest_version: 'v2.2.3')
      Lapidarist::GoCommand.new.update(mod)

      expect(shell).to have_received(:run).with('go get -u gopkg.in/yaml.v2@v2.2.3')
    end

    it 'calls go mod tidy' do
      shell = stub_shell

      mod = stub_module(name: 'gopkg.in/yaml.v2', newest_version: 'v2.2.3')
      Lapidarist::GoCommand.new.update(mod)

      expect(shell).to have_received(:run).with('go mod tidy')
    end

    context 'when the version is patch' do
      it 'calls go get -u restricted to patch' do
        shell = stub_shell

        mod = stub_module(name: 'gopkg.in/yaml.v2', newest_version: 'v2.2.3')
        Lapidarist::GoCommand.new.update(mod, level: Lapidarist::PATCH)

        expect(shell).to have_received(:run).with('go get -u=patch gopkg.in/yaml.v2@v2.2.3')
      end
    end
  end

  describe '#version' do
    it 'calls bundle list + grep' do
      shell = stub_shell('')

      mod = stub_module(name: 'gopkg.in/yaml.v2', newest_version: 'v2.2.3')
      Lapidarist::GoCommand.new.version(mod)

      expect(shell).to have_received(:run_out_only).with("go list -u -m -json gopkg.in/yaml.v2")
    end

    context 'when the requested module is in use' do
      it 'returns the version' do
        stub_shell(<<~OUTPUT)
          {
            "Path": "gopkg.in/yaml.v2",
            "Version": "v2.2.3"
          }
        OUTPUT

        go = Lapidarist::GoCommand.new
        mod = stub_module(name: 'gopkg.in/yaml.v2', newest_version: 'v2.2.3')

        expect(go.version(mod)).to eq Lapidarist::ModuleVersion.new(version: 'v2.2.3')
      end
    end

    context 'when the requested module is not in use' do
      it 'returns nil' do
        stub_shell('')

        go = Lapidarist::GoCommand.new
        mod = stub_module(name: 'gopkg.in/yaml.v2', newest_version: 'v2.2.3')

        expect(go.version(mod)).to be_nil
      end
    end
  end
end
