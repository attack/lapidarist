require 'spec_helper'

RSpec.describe Lapidarist::Outdated do
  describe '#run' do
    it 'returns an outdated gem for each gem' do
      stub_options
      bundle = stub_bundle_command
      gem_1 = Lapidarist::Gem.new(name: 'rack', newest_version: '2.0.5', installed_version: '2.0.3', groups: ['default'])
      gem_2 = Lapidarist::Gem.new(name: 'rake', newest_version: '12.3.1', installed_version: '10.5.0', groups: ['default'])
      allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

      gems = Lapidarist::Outdated.new.run

      expect(gems.count).to eq 2
      expect(gems.to_a).to eq([
        Lapidarist::Gem.from(gem_1),
        Lapidarist::Gem.from(gem_2)
      ])
    end

    it 'returns a skipped gem for each sub dependency' do
      stub_options
      bundle = stub_bundle_command
      gem_1 = Lapidarist::Gem.new(name: 'rack', newest_version: '2.0.5', installed_version: '2.0.3', groups: ['default'])
      gem_2 = Lapidarist::Gem.new(name: 'rake', newest_version: '12.3.1', installed_version: '10.5.0')
      allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

      gems = Lapidarist::Outdated.new.run

      expect(gems.count).to eq 2
      expect(gems.to_a).to eq([
        Lapidarist::Gem.from(gem_1),
        Lapidarist::Gem.from(gem_2, status: :skipped, reason: :sub_dependency)
      ])
    end

    context 'when all gems should be updated' do
      it 'returns a skipped gem for each sub dependency' do
        stub_options(all: true)
        bundle = stub_bundle_command
        gem_1 = Lapidarist::Gem.new(name: 'rack', newest_version: '2.0.5', installed_version: '2.0.3', groups: ['default'])
        gem_2 = Lapidarist::Gem.new(name: 'rake', newest_version: '12.3.1', installed_version: '10.5.0')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

        gems = Lapidarist::Outdated.new.run

        expect(gems.count).to eq 2
        expect(gems.to_a).to eq([
          Lapidarist::Gem.from(gem_1),
          Lapidarist::Gem.from(gem_2)
        ])
      end
    end

    context 'when updates are restricted to specified groups' do
      it 'returns an outdated gem for each gem in the group' do
        stub_options(groups: ['default'])
        bundle = stub_bundle_command
        gem_1 = Lapidarist::Gem.new(name: 'rack', newest_version: '2.0.5', installed_version: '2.0.3', groups: ['default'])
        gem_2 = Lapidarist::Gem.new(name: 'rake', newest_version: '12.3.1', installed_version: '10.5.0', groups: ['test', 'default'])
        allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

        gems = Lapidarist::Outdated.new.run

        expect(gems.count).to eq 2
        expect(gems.to_a).to eq([
          Lapidarist::Gem.from(gem_1),
          Lapidarist::Gem.from(gem_2)
        ])
      end

      it 'returns a skipped gem for each gem not in the group' do
        stub_options(groups: ['test'])
        bundle = stub_bundle_command
        gem = Lapidarist::Gem.new(name: 'rack', newest_version: '2.0.5', installed_version: '2.0.3', groups: ['default'])
        allow(bundle).to receive(:outdated) { [gem] }

        gems = Lapidarist::Outdated.new.run

        expect(gems.count).to eq 1
        expect(gems.to_a).to eq([Lapidarist::Gem.from(gem, status: :skipped, reason: :unmatched_group)])
      end
    end

    context 'when the order of gems is to be randomized' do
      it 'returns an outdated gem for each gem in random order' do
        stub_options(random: true)
        bundle = stub_bundle_command
        gem_1 = Lapidarist::Gem.new(name: 'rack', newest_version: '2.0.5', installed_version: '2.0.3', groups: ['default'])
        gem_2 = Lapidarist::Gem.new(name: 'rake', newest_version: '12.3.1', installed_version: '10.5.0', groups: ['default'])
        allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

        gems_1 = Lapidarist::Outdated.new.run
        gems_2 = Lapidarist::Outdated.new.run
        gems_3 = Lapidarist::Outdated.new.run
        gems_4 = Lapidarist::Outdated.new.run
        gems_5 = Lapidarist::Outdated.new.run

        first_gem_to_be_updated = [gems_1.first, gems_2.first, gems_3.first, gems_4.first, gems_5.first].map(&:name).uniq
        expect(first_gem_to_be_updated.count).to eq 2
      end
    end
  end
end
