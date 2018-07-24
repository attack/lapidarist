require 'spec_helper'

RSpec.describe Lapidarist::Outdated do
  describe '#run' do
    it 'returns a result for each outdated gem' do
      bundle = stub_bundle_command
      stub_gemfile

      gem_1 = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3')
      gem_2 = Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0')
      allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

      outdated_gems = Lapidarist::Outdated.new(build_options).run

      expect(outdated_gems.length).to eq 2
      expect(outdated_gems).to eq [gem_1, gem_2]
    end

    it 'does not return outdated gems that are not listed in the Gemfile' do
      bundle = stub_bundle_command
      gemfile = stub_gemfile
      options = build_options(all: false)

      gem_1 = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3')
      gem_2 = Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0')
      allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

      allow(gemfile).to receive(:dependency?).with(gem_1) { false }
      allow(gemfile).to receive(:dependency?).with(gem_2) { true }

      outdated_gems = Lapidarist::Outdated.new(options).run

      expect(outdated_gems.length).to eq 1
      expect(outdated_gems).to eq [gem_2]
    end

    context 'when updates are restricted to specified groups' do
      it 'only returns outdated gem objects for the specified groups' do
        bundle = stub_bundle_command
        gemfile = stub_gemfile
        options = build_options(groups: ['test'])

        gem_1 = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3', groups: %w(default))
        gem_2 = Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0', groups: %w(development test))
        gem_3 = Lapidarist::OutdatedGem.new(name: 'rubocop', newest_version: '0.58.2', current_version: '0.58.1', groups: %w(test))
        allow(bundle).to receive(:outdated) { [gem_1, gem_2, gem_3] }
        allow(gemfile).to receive(:dependency?) { true }

        outdated_gems = Lapidarist::Outdated.new(options).run

        expect(outdated_gems.length).to eq 2
        expect(outdated_gems).to eq [gem_2, gem_3]
      end
    end

    context 'when all gems should be updated' do
      it 'does not return outdated gems that are not listed in the Gemfile' do
        bundle = stub_bundle_command
        gemfile = stub_gemfile
        options = build_options(all: true)

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
        bundle = stub_bundle_command

        gem_1 = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3')
        gem_2 = Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

        outdated_gems = Lapidarist::Outdated.new(build_options).run(failed_gems: [gem_1])

        expect(outdated_gems.length).to eq 1
        expect(outdated_gems).to eq [gem_2]
      end
    end

    context 'when a limit is requested' do
      it 'only returns enough gems to fulfill the limit' do
        bundle = stub_bundle_command
        options = build_options(update_limit: 1)

        gem_1 = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: '2.0.5', current_version: '2.0.3')
        gem_2 = Lapidarist::OutdatedGem.new(name: 'rake', newest_version: '12.3.1', current_version: '10.5.0')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

        outdated_gems = Lapidarist::Outdated.new(options).run
        expect(outdated_gems.length).to eq 1
        expect(outdated_gems).to eq [gem_1]

        outdated_gems = Lapidarist::Outdated.new(options).run(updated_count: 1)
        expect(outdated_gems.length).to eq 0
        expect(outdated_gems).to be_empty

        outdated_gems = Lapidarist::Outdated.new(options).run(updated_count: 2)
        expect(outdated_gems.length).to eq 0
        expect(outdated_gems).to be_empty
      end
    end
  end
end
