require 'spec_helper'

RSpec.describe Lapidarist::BundleCommand do
  describe '#outdated' do
    it 'calls bundle outdated' do
      shell = stub_shell

      Lapidarist::BundleCommand.new(build_options).outdated.to_a

      expect(shell).to have_received(:run).with('bundle outdated --strict')
    end

    it 'parses each line from the output and returns outdated gem objects' do
      std_out = double(:STD_OUT)
      allow(std_out).to receive(:gets).and_return(
        'Fetching gem metadata from https://rubygems.org/........',
        'Fetching gem metadata from https://rubygems.org/.',
        'Resolving dependencies...',
        '',
        'Outdated gems included in the bundle:',
        '  * rack (newest 2.0.5, installed 2.0.3, requested = 2.0.3) in groups "default"',
        '  * rake (newest 12.3.1, installed 10.5.0, requested ~> 10.0) in groups "development"',
        nil
      )
      stub_shell { std_out }

      outdated_gems = Lapidarist::BundleCommand.new(build_options).outdated.to_a

      expect(outdated_gems.length).to eq 2
      expect(outdated_gems[0]).to eq Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3')
      expect(outdated_gems[1]).to eq Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0')
    end
  end

  describe '#update' do
    it 'calls bundle update' do
      shell = stub_shell

      gem = stub_gem(name: 'rack')
      Lapidarist::BundleCommand.new(build_options).update(gem)

      expect(shell).to have_received(:run).with('bundle update rack')
    end
  end

  describe '#version' do
    it 'calls bundle list + grep' do
      shell = stub_shell('')

      gem = stub_gem(name: 'rack')
      Lapidarist::BundleCommand.new(build_options).version(gem)

      expect(shell).to have_received(:run).with('bundle list', "grep \" rack \"")
    end

    context 'when the requested gem exists in the output' do
      it 'returns the version' do
        stub_shell('  * bundler (1.16.1)')

        bundle = Lapidarist::BundleCommand.new(build_options)
        gem = stub_gem(name: 'bundler')

        expect(bundle.version(gem)).to eq '1.16.1'
      end
    end

    context 'when the requested gem does not exist in the output' do
      it 'returns nil' do
        stub_shell('')

        bundle = Lapidarist::BundleCommand.new(build_options)
        gem = stub_gem(name: 'rake')

        expect(bundle.version(gem)).to be_nil
      end
    end
  end
end
