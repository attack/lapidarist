require 'spec_helper'

RSpec.describe Lapidarist::CLI do
  describe '#run' do
    context 'when there are is only one outdated gem' do
      context 'and it fails the test' do
        it 'does no run git bisect' do
          git = double(Lapidarist::GitCommand, bisect: nil, head: nil, reset_hard: nil)
          allow(Lapidarist::GitCommand).to receive(:new) { git }

          outdated = double(Lapidarist::Outdated)
          allow(Lapidarist::Outdated).to receive(:new) { outdated }
          allow(outdated).to receive(:run).and_return([double(Lapidarist::OutdatedGem, name: 'foo gem')], [])

          update = double(Lapidarist::Update, run: nil)
          allow(Lapidarist::Update).to receive(:new) { update }

          test = double(Lapidarist::TestCommand, success?: false)
          allow(Lapidarist::TestCommand).to receive(:new) { test }

          Lapidarist::CLI.new(['-q']).run

          expect(git).not_to have_received(:bisect)
        end

        it 'skips the gem on the next interation' do
          git = double(Lapidarist::GitCommand, bisect: nil, head: nil, reset_hard: nil)
          allow(Lapidarist::GitCommand).to receive(:new) { git }

          outdated = double(Lapidarist::Outdated)
          allow(Lapidarist::Outdated).to receive(:new) { outdated }
          allow(outdated).to receive(:run).and_return([double(Lapidarist::OutdatedGem, name: 'foo gem')], [])

          update = double(Lapidarist::Update, run: nil)
          allow(Lapidarist::Update).to receive(:new) { update }

          test = double(Lapidarist::TestCommand, success?: false)
          allow(Lapidarist::TestCommand).to receive(:new) { test }

          Lapidarist::CLI.new(['-q']).run

          expect(outdated).to have_received(:run).with(['foo gem']).at_least(:once)
        end

        it 'removes the single commit added by update' do
          git = double(Lapidarist::GitCommand, bisect: nil, head: nil, reset_hard: nil)
          allow(Lapidarist::GitCommand).to receive(:new) { git }

          outdated = double(Lapidarist::Outdated)
          allow(Lapidarist::Outdated).to receive(:new) { outdated }
          allow(outdated).to receive(:run).and_return([double(Lapidarist::OutdatedGem, name: 'foo gem')], [])

          update = double(Lapidarist::Update, run: nil)
          allow(Lapidarist::Update).to receive(:new) { update }

          test = double(Lapidarist::TestCommand, success?: false)
          allow(Lapidarist::TestCommand).to receive(:new) { test }

          Lapidarist::CLI.new(['-q']).run

          expect(git).to have_received(:reset_hard).with('HEAD^')
        end
      end
    end

    context 'when there are multiple outdated gem' do
      context 'and they fail the test' do
        it 'runs git bisect' do
          git = double(Lapidarist::GitCommand, bisect: nil, head: nil)
          allow(Lapidarist::GitCommand).to receive(:new) { git }

          outdated = double(Lapidarist::Outdated)
          allow(Lapidarist::Outdated).to receive(:new) { outdated }
          allow(outdated).to receive(:run).and_return([double(Lapidarist::OutdatedGem), double(Lapidarist::OutdatedGem)], [])

          update = double(Lapidarist::Update, run: nil)
          allow(Lapidarist::Update).to receive(:new) { update }

          test = double(Lapidarist::TestCommand, success?: false)
          allow(Lapidarist::TestCommand).to receive(:new) { test }

          Lapidarist::CLI.new(['-q']).run

          expect(git).to have_received(:bisect)
        end
      end
    end
  end
end
