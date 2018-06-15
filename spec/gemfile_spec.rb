require 'spec_helper'

RSpec.describe Lapidarist::Gemfile do
  describe '#dependency?' do
    it 'calls File#readlines' do
      allow(File).to receive(:readlines) { [] }

      gem = Lapidarist::OutdatedGem.new(name: 'rack', newest_version: nil, current_version: nil)
      Lapidarist::Gemfile.new(Pathname.new('/foo')).dependency?(gem)

      expect(File).to have_received(:readlines).with(Pathname.new('/foo/Gemfile'))
    end

    it 'returns true if the gem is listed in the gemfile' do
      contents = [
        'gem "foo"',
        'group :development, :test do',
        '  gem "bar"',
        'end'
      ]
      allow(File).to receive(:readlines) { contents }

      gem = Lapidarist::OutdatedGem.new(name: 'bar', newest_version: nil, current_version: nil)
      gemfile = Lapidarist::Gemfile.new(Pathname.new('/foo'))

      expect(gemfile.dependency?(gem)).to eq true
    end

    it 'returns false if the gem is not listed in the gemfile' do
      allow(File).to receive(:readlines) { [] }

      gem = Lapidarist::OutdatedGem.new(name: 'bar', newest_version: nil, current_version: nil)
      gemfile = Lapidarist::Gemfile.new(Pathname.new('/foo'))

      expect(gemfile.dependency?(gem)).to eq false
    end
  end
end
