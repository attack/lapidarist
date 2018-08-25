require 'spec_helper'

RSpec.describe Lapidarist::VersionChange do
  describe '#next_level' do
    it 'returns MINOR when the update changed the major version' do
      version_change = Lapidarist::VersionChange.new(
        installed: Lapidarist::GemVersion.new(version: '0.0.1'),
        updated: Lapidarist::GemVersion.new(version: '1.0.0')
      )
      expect(version_change.next_level).to eq Lapidarist::MINOR
    end

    it 'returns PATCH when the update changed the minor version' do
      version_change = Lapidarist::VersionChange.new(
        installed: Lapidarist::GemVersion.new(version: '0.0.1'),
        updated: Lapidarist::GemVersion.new(version: '0.1.0')
      )
      expect(version_change.next_level).to eq Lapidarist::PATCH
    end

    it 'returns nil when the update changed the patch version' do
      version_change = Lapidarist::VersionChange.new(
        installed: Lapidarist::GemVersion.new(version: '0.0.1'),
        updated: Lapidarist::GemVersion.new(version: '0.0.2')
      )
      expect(version_change.next_level).to be_nil
    end

    it 'returns nil when the update did not change the version' do
      version_change = Lapidarist::VersionChange.new(
        installed: Lapidarist::GemVersion.new(version: '0.0.1'),
        updated: Lapidarist::GemVersion.new(version: '0.0.1')
      )
      expect(version_change.next_level).to be_nil
    end

    it 'returns nil when the update resulted in a downgraded patch version' do
      version_change = Lapidarist::VersionChange.new(
        installed: Lapidarist::GemVersion.new(version: '0.0.2'),
        updated: Lapidarist::GemVersion.new(version: '0.0.1')
      )
      expect(version_change.next_level).to be_nil
    end

    it 'returns nil when the update resulted in a downgraded minor version' do
      version_change = Lapidarist::VersionChange.new(
        installed: Lapidarist::GemVersion.new(version: '0.1.0'),
        updated: Lapidarist::GemVersion.new(version: '0.0.1')
      )
      expect(version_change.next_level).to be_nil
    end

    it 'returns nil when the update resulted in a downgraded major version' do
      version_change = Lapidarist::VersionChange.new(
        installed: Lapidarist::GemVersion.new(version: '1.0.0'),
        updated: Lapidarist::GemVersion.new(version: '0.0.1')
      )
      expect(version_change.next_level).to be_nil
    end

    it 'returns MAJOR when there is no updated version' do
      version_change = Lapidarist::VersionChange.new(
        installed: Lapidarist::GemVersion.new(version: '0.0.1'),
        updated: nil
      )
      expect(version_change.next_level).to eq Lapidarist::MAJOR
    end
  end
end
