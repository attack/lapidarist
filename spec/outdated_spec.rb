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
        gem_1 = build_gem(name: 'addressable')
        gem_2 = build_gem(name: 'bcrypt')
        gem_3 = build_gem(name: 'rack')
        gem_4 = build_gem(name: 'rake')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2, gem_3, gem_4] }

        gems_1 = Lapidarist::Outdated.new.run
        gems_2 = Lapidarist::Outdated.new.run
        gems_3 = Lapidarist::Outdated.new.run
        gems_4 = Lapidarist::Outdated.new.run
        gems_5 = Lapidarist::Outdated.new.run
        gems_6 = Lapidarist::Outdated.new.run
        gems_7 = Lapidarist::Outdated.new.run
        gems_8 = Lapidarist::Outdated.new.run

        first_gem_to_be_updated = [gems_1.first, gems_2.first, gems_3.first, gems_4.first, gems_5.first, gems_6.first, gems_7.first, gems_8.first].map(&:name).uniq
        expect(first_gem_to_be_updated.count).not_to eq 1
      end

      it 'returns an outdated gem for each gem in random order using the provided seed' do
        bundle = stub_bundle_command
        gem_1 = Lapidarist::Gem.new(name: 'rack', newest_version: '2.0.5', installed_version: '2.0.3', groups: ['default'])
        gem_2 = Lapidarist::Gem.new(name: 'rake', newest_version: '12.3.1', installed_version: '10.5.0', groups: ['default'])
        allow(bundle).to receive(:outdated) { [gem_1, gem_2] }

        stub_options(random: true, seed: 1)
        gems_1 = Lapidarist::Outdated.new.run

        stub_options(random: true, seed: 2)
        gems_2 = Lapidarist::Outdated.new.run

        expect(gems_1.map(&:name)).not_to eq gems_2.map(&:name)
      end
    end

    context 'when certain gems are promoted or demoted' do
      it 'returns the promoted gems in order before the remaining gems' do
        stub_options(promoted: %w(rack bcrypt foo), random: false)
        bundle = stub_bundle_command
        gem_1 = build_gem(name: 'addressable')
        gem_2 = build_gem(name: 'bcrypt')
        gem_3 = build_gem(name: 'rack')
        gem_4 = build_gem(name: 'rake')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2, gem_3, gem_4] }

        gems = Lapidarist::Outdated.new.run

        expect(gems.count).to eq 4
        expect(gems.map(&:name)).to eq %w(rack bcrypt addressable rake)
      end

      it 'returns the demoted gems in order after the remaining gems' do
        stub_options(demoted: %w(bcrypt rack foo), random: false)
        bundle = stub_bundle_command
        gem_1 = build_gem(name: 'addressable')
        gem_2 = build_gem(name: 'bcrypt')
        gem_3 = build_gem(name: 'rack')
        gem_4 = build_gem(name: 'rake')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2, gem_3, gem_4] }

        gems = Lapidarist::Outdated.new.run

        expect(gems.count).to eq 4
        expect(gems.map(&:name)).to eq %w(addressable rake bcrypt rack)
      end

      it 'returns the promoted gems and demoted gems in order, preffering a gem as demoted' do
        stub_options(promoted: %w(rack bcrypt), demoted: %w(addressable rack), random: false)
        bundle = stub_bundle_command
        gem_1 = build_gem(name: 'addressable')
        gem_2 = build_gem(name: 'bcrypt')
        gem_3 = build_gem(name: 'capybara')
        gem_4 = build_gem(name: 'rack')
        gem_5 = build_gem(name: 'rake')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2, gem_3, gem_4, gem_5] }

        gems = Lapidarist::Outdated.new.run

        expect(gems.count).to eq 5
        expect(gems.map(&:name)).to eq %w(bcrypt capybara rake addressable rack)
      end

      it 'returns the promoted gems and demoted gems in order without randomizing' do
        stub_options(promoted: %w(rack bcrypt), demoted: %w(addressable rack), random: true)
        bundle = stub_bundle_command
        gem_1 = build_gem(name: 'addressable')
        gem_2 = build_gem(name: 'bcrypt')
        gem_3 = build_gem(name: 'capybara')
        gem_4 = build_gem(name: 'faraday')
        gem_5 = build_gem(name: 'rack')
        gem_6 = build_gem(name: 'rake')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2, gem_3, gem_4, gem_5, gem_6] }

        gems_1 = Lapidarist::Outdated.new.run
        gems_2 = Lapidarist::Outdated.new.run
        gems_3 = Lapidarist::Outdated.new.run
        gems_4 = Lapidarist::Outdated.new.run
        gems_5 = Lapidarist::Outdated.new.run

        first_of_promoted_gems = [gems_1.to_a[0], gems_2.to_a[0], gems_3.to_a[0], gems_4.to_a[0], gems_5.to_a[0]].map(&:name).uniq
        expect(first_of_promoted_gems).to eq %w(bcrypt)

        first_of_remaining_gems = [gems_1.to_a[1], gems_2.to_a[1], gems_3.to_a[1], gems_4.to_a[1], gems_5.to_a[1]].map(&:name).uniq
        expect(first_of_remaining_gems.count).not_to eq 1

        first_of_demoted_gems = [gems_1.to_a[4], gems_2.to_a[4], gems_3.to_a[4], gems_4.to_a[4], gems_5.to_a[4]].map(&:name).uniq
        expect(first_of_demoted_gems).to eq %w(addressable)
      end
    end

    context 'when certain gems are explicitly included or excluded' do
      it 'returns only the included gems' do
        stub_options(only: %w(rack bcrypt foo), random: false)
        bundle = stub_bundle_command
        gem_1 = build_gem(name: 'addressable')
        gem_2 = build_gem(name: 'bcrypt')
        gem_3 = build_gem(name: 'rack')
        gem_4 = build_gem(name: 'rake')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2, gem_3, gem_4] }

        gems = Lapidarist::Outdated.new.run

        expect(gems.count).to eq 2
        expect(gems.map(&:name)).to eq %w(bcrypt rack)
      end

      it 'returns everything but the excluded gems' do
        stub_options(except: %w(rack bcrypt foo), random: false)
        bundle = stub_bundle_command
        gem_1 = build_gem(name: 'addressable')
        gem_2 = build_gem(name: 'bcrypt')
        gem_3 = build_gem(name: 'rack')
        gem_4 = build_gem(name: 'rake')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2, gem_3, gem_4] }

        gems = Lapidarist::Outdated.new.run

        expect(gems.count).to eq 2
        expect(gems.map(&:name)).to eq %w(addressable rake)
      end

      it 'returns only the included gems that were not also excluded' do
        stub_options(only: %w(rack bcrypt), except: %w(rake bcrypt), random: false)
        bundle = stub_bundle_command
        gem_1 = build_gem(name: 'addressable')
        gem_2 = build_gem(name: 'bcrypt')
        gem_3 = build_gem(name: 'rack')
        gem_4 = build_gem(name: 'rake')
        allow(bundle).to receive(:outdated) { [gem_1, gem_2, gem_3, gem_4] }

        gems = Lapidarist::Outdated.new.run

        expect(gems.count).to eq 1
        expect(gems.map(&:name)).to eq %w(rack)
      end
    end

    def build_gem(name:)
      Lapidarist::Gem.new(name: name, newest_version: '2.0.0', installed_version: '1.0.0', groups: ['default'])
    end
  end
end
