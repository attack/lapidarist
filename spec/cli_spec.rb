require 'spec_helper'

RSpec.describe Lapidarist::CLI do
  describe '#run' do
    context 'when there are is only one outdated gem' do
      context 'and it fails the test' do
        it 'does no run git bisect' do
          stub_outdated([stub_gem], [])
          stub_update
          stub_test_command(success: false)
          git = stub_git

          Lapidarist::CLI.new(['-q']).run

          expect(git).not_to have_received(:bisect)
        end

        it 'skips the gem on the next interation' do
          outdated = stub_outdated([stub_gem(name: 'foo gem')], [])
          stub_update
          stub_test_command(success: false)
          stub_git

          Lapidarist::CLI.new(['-q']).run

          expect(outdated).to have_received(:run).with(hash_including(failed_gem_names: ['foo gem'])).at_least(:once)
        end

        it 'removes the single commit added by update' do
          stub_outdated([stub_gem], [])
          stub_update
          stub_test_command(success: false)
          git = stub_git

          Lapidarist::CLI.new(['-q']).run

          expect(git).to have_received(:reset_hard).with('HEAD^')
        end
      end
    end

    context 'when there are multiple outdated gem' do
      context 'and they fail the test' do
        it 'runs git bisect' do
          stub_outdated([stub_gem, stub_gem], [])
          stub_update
          stub_test_command(success: false)
          git = stub_git

          Lapidarist::CLI.new(['-q']).run

          expect(git).to have_received(:bisect)
        end
      end
    end
  end
end
