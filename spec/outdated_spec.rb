require 'spec_helper'

RSpec.describe Lapidarist::Outdated do
  describe '#run' do
    it 'returns a result for each outdated gem' do
      bundle = double(Lapidarist::BundleCommand)
      allow(Lapidarist::BundleCommand).to receive(:new) { bundle }
      gemfile = double(Lapidarist::Gemfile)
      allow(Lapidarist::Gemfile).to receive(:new) { gemfile }
      options = double(Lapidarist::Options, directory: '/foo', all: false, verbosity: 0, log_path: nil, quiet: true, update_limit: nil)

      gem_1 = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3')
      gem_2 = Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0')
      allow(bundle).to receive(:outdated) { [gem_1, gem_2] }
      allow(gemfile).to receive(:dependency?) { true }

      outdated_gems = Lapidarist::Outdated.new(options).run

      expect(outdated_gems.length).to eq 2
      expect(outdated_gems).to eq [gem_1, gem_2]
    end

    it 'does not return outdated gems that are not listed in the Gemfile' do
      bundle = double(Lapidarist::BundleCommand)
      allow(Lapidarist::BundleCommand).to receive(:new) { bundle }
      gemfile = double(Lapidarist::Gemfile)
      allow(Lapidarist::Gemfile).to receive(:new) { gemfile }
      options = double(Lapidarist::Options, directory: '/foo', all: false, verbosity: 0, log_path: nil, quiet: true, update_limit: nil)

      gem_1 = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3')
      gem_2 = Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0')
      allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

      allow(gemfile).to receive(:dependency?).with(gem_1) { false }
      allow(gemfile).to receive(:dependency?).with(gem_2) { true }

      outdated_gems = Lapidarist::Outdated.new(options).run

      expect(outdated_gems.length).to eq 1
      expect(outdated_gems).to eq [gem_2]
    end

    context 'when all gems should be updated' do
      it 'does not return outdated gems that are not listed in the Gemfile' do
        bundle = double(Lapidarist::BundleCommand)
        allow(Lapidarist::BundleCommand).to receive(:new) { bundle }
        gemfile = double(Lapidarist::Gemfile)
        allow(Lapidarist::Gemfile).to receive(:new) { gemfile }
        options = double(Lapidarist::Options, directory: '/foo', all: true, verbosity: 0, log_path: nil, quiet: true, update_limit: nil)

        gem_1 = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3')
        gem_2 = Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

        allow(gemfile).to receive(:dependency?).with(gem_1) { false }
        allow(gemfile).to receive(:dependency?).with(gem_2) { true }

        outdated_gems = Lapidarist::Outdated.new(options).run

        expect(outdated_gems.length).to eq 2
        expect(outdated_gems).to eq [gem_1, gem_2]
      end
    end

    context 'when failed gems are provided' do
      it 'does not return outdated gems that match any failed gems' do
        bundle = double(Lapidarist::BundleCommand)
        allow(Lapidarist::BundleCommand).to receive(:new) { bundle }
        gemfile = double(Lapidarist::Gemfile)
        allow(Lapidarist::Gemfile).to receive(:new) { gemfile }
        options = double(Lapidarist::Options, directory: '/foo', all: true, verbosity: 0, log_path: nil, quiet: true, update_limit: nil)

        gem_1 = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3')
        gem_2 = Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

        outdated_gems = Lapidarist::Outdated.new(options).run(%w(rack))

        expect(outdated_gems.length).to eq 1
        expect(outdated_gems).to eq [gem_2]
      end
    end

    context 'when a limit is requested' do
      it 'only returns enough gems to fulfill the limit' do
        bundle = double(Lapidarist::BundleCommand)
        allow(Lapidarist::BundleCommand).to receive(:new) { bundle }
        gemfile = double(Lapidarist::Gemfile)
        allow(Lapidarist::Gemfile).to receive(:new) { gemfile }
        options = double(Lapidarist::Options, directory: '/foo', all: true, verbosity: 0, log_path: nil, quiet: true, update_limit: 1)

        gem_1 = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3')
        gem_2 = Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

        outdated_gems = Lapidarist::Outdated.new(options).run

        expect(outdated_gems.length).to eq 1
        expect(outdated_gems).to eq [gem_1]
      end
    end
  end
end
