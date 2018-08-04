require 'spec_helper'

RSpec.describe Lapidarist::Gem do
  describe '#what_changed' do
    context 'when the gem was updated' do
      it 'returns a message including the version change' do
        gem = Lapidarist::Gem.new(
          name: 'rack',
          newest_version: '',
          installed_version: '0.0.1',
        )
        updated_gem = Lapidarist::Gem.from(gem, updated_version: '2.0.0', status: :updated)

        expect(updated_gem.what_changed).to eq 'rack from 0.0.1 to 2.0.0'
      end
    end

    context 'when the gem was not updated' do
      it 'returns a message indicating only dependencies changed' do
        gem = Lapidarist::Gem.new(
          name: 'rack',
          newest_version: '',
          installed_version: '0.0.1',
        )
        updated_gem = Lapidarist::Gem.from(gem, updated_version: '0.0.1', status: :updated)

        expect(updated_gem.what_changed).to eq 'rack dependencies'
      end
    end
  end
end