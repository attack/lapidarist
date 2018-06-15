require 'spec_helper'

RSpec.describe Lapidarist::BundleCommand do
  describe '#outdated' do
    it 'calls bundle outdated' do
      allow(Open3).to receive(:popen2)

      Lapidarist::BundleCommand.new('/foo').outdated

      expect(Open3).to have_received(:popen2).with('bundle outdated --strict', chdir: '/foo')
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
      allow(Open3).to receive(:popen2).and_yield('', std_out)

      outdated_gems = []
      Lapidarist::BundleCommand.new('').outdated do |outdated_gem|
        outdated_gems << outdated_gem
      end

      expect(outdated_gems.length).to eq 2
      expect(outdated_gems[0]).to eq Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3')
      expect(outdated_gems[1]).to eq Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0')
    end
  end

  describe '#update' do
    it 'calls bundle update' do
      allow(Open3).to receive(:capture3)

      gem = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: nil, current_version: nil)
      Lapidarist::BundleCommand.new('/foo').update(gem)

      expect(Open3).to have_received(:capture3).with('bundle update rack', chdir: '/foo')
    end
  end

  describe '#version' do
    it 'calls bundle list + grep' do
      allow(Open3).to receive(:pipeline_r)

      gem = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: nil, current_version: nil)
      Lapidarist::BundleCommand.new('/foo').version(gem)

      expect(Open3).to have_received(:pipeline_r).with('bundle list', "grep \" rack \"", chdir: '/foo')
    end

    context 'when the requested gem exists in the output' do
      it 'returns the version' do
        std_out = double(:STD_OUT)
        allow(std_out).to receive(:read).and_return('  * bundler (1.16.1)')
        allow(Open3).to receive(:pipeline_r).and_yield(std_out, [])

        bundle = Lapidarist::BundleCommand.new('')
        gem = Lapidarist::OutdatedGem.new(name: 'bundler', current_version: nil, newest_version: nil)

        expect(bundle.version(gem)).to eq '1.16.1'
      end
    end

    context 'when the requested gem does not exist in the output' do
      it 'returns nil' do
        std_out = double(:STD_OUT)
        allow(std_out).to receive(:read).and_return('')
        allow(Open3).to receive(:pipeline_r).and_yield(std_out, [])

        bundle = Lapidarist::BundleCommand.new('.')
        gem = Lapidarist::OutdatedGem.new(name: 'rake', current_version: nil, newest_version: nil)

        expect(bundle.version(gem)).to be_nil
      end
    end
  end
end
