require 'spec_helper'

RSpec.describe Lapidarist::Mod do
  describe '#what_changed' do
    context 'when the module was updated' do
      it 'returns a message including the version change' do
        mod = Lapidarist::Mod.new(
          name: 'github.com/foo/bar',
          newest_version: '',
          installed_version: Lapidarist::ModuleVersion.new(version: '0.0.1'),
        )
        updated_mod = Lapidarist::Mod.from(mod, updated_version: Lapidarist::ModuleVersion.new(version: '2.0.0'), status: :updated)

        expect(updated_mod.what_changed).to eq 'github.com/foo/bar from 0.0.1 to 2.0.0'
      end
    end

    context 'when the module was not updated' do
      it 'returns a message indicating only dependencies changed' do
        mod = Lapidarist::Mod.new(
          name: 'github.com/foo/bar',
          newest_version: '',
          installed_version: Lapidarist::ModuleVersion.new(version: '0.0.1'),
        )
        updated_mod = Lapidarist::Mod.from(mod, updated_version: Lapidarist::ModuleVersion.new(version: '0.0.1'), status: :updated)

        expect(updated_mod.what_changed).to eq 'github.com/foo/bar dependencies'
      end
    end
  end

  describe '#next_semver_level' do
    it 'returns the next semver level after the current attempted install' do
      mod = Lapidarist::Mod.new(
        name: 'rack',
        newest_version: Lapidarist::ModuleVersion.new(version: '1.0.0'),
        installed_version: Lapidarist::ModuleVersion.new(version: '0.0.1')
      )

      updated_but_failed_mod = Lapidarist::Mod.from(
        mod,
        updated_version: Lapidarist::ModuleVersion.new(version: '1.0.0'),
        status: :failed
      )

      expect(updated_but_failed_mod.next_semver_level).to eq Lapidarist::MINOR
    end

    context 'when the updated version was a lower level than the level' do
      it 'returns the next semver level without duplicating the previous update' do
        mod = Lapidarist::Mod.new(
          name: 'rack',
          newest_version: Lapidarist::ModuleVersion.new(version: '1.0.0'),
          installed_version: Lapidarist::ModuleVersion.new(version: '0.0.1')
        )

        updated_but_failed_mod = Lapidarist::Mod.from(
          mod,
          updated_version: Lapidarist::ModuleVersion.new(version: '0.1.0'),
          status: :failed
        )

        expect(updated_but_failed_mod.next_semver_level).to eq Lapidarist::PATCH
      end
    end
  end
end
