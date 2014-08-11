require 'spec_helper'

describe ArenaRun do
  let(:arena_run) { create :arena_run }

  it 'destroys all matches when destroyed' do
    create :match_run, arena_run: arena_run

    expect { arena_run.destroy }.to change { Match.count }.by(-1)
  end

  describe 'class methods' do
    describe '#total_gold' do
      it 'returns the total gold amount a user won with arena runs' do
        create :arena_run, user_id: 6, gold: 333
        create :arena_run, user_id: 6, gold: 333

        ArenaRun.total_gold(6).should == 666
      end

      it 'returns 0 when no gold is won' do
        ArenaRun.total_gold(6).should == 0
      end
    end

    describe '#total_dust' do
      it 'returns the total dust a user won with arena runs' do
        create :arena_run, user_id: 6, dust: 333
        create :arena_run, user_id: 6, dust: 333

        ArenaRun.total_dust(6).should == 666
      end

      it 'returns 0 when no dust is won' do
        ArenaRun.total_dust(6).should == 0
      end
    end

    describe '#average_wins' do
      let(:win_match)  { create :match, result_id: 1 }
      let(:lost_match) { create :match, result_id: 2 }
      let(:arena_run)  { create :arena_run, user_id: 666, klass_id: 1 }

      it 'returns the average arena win rate for a user with a specific class' do
        arena_run2 = create :arena_run, user_id: 666, klass_id: 1
        create :match_run, arena_run: arena_run, match: win_match
        create :match_run, arena_run: arena_run2, match: win_match
        create :match_run, arena_run: arena_run2, match: win_match

        ArenaRun.average_wins(1, 666).should == 1.5
      end

      it 'returns -1 when no games are found' do
        ArenaRun.average_wins(1, 666).should == -1
      end
    end

  end

  describe 'instance methods' do
    let(:win_match)   { create :match, result_id: 1                                }
    let(:lost_match)  { create :match, result_id: 2                                }
    let!(:match_run1) { create :match_run, arena_run: arena_run, match: win_match  }
    let!(:match_run2) { create :match_run, arena_run: arena_run, match: lost_match }

    describe '#num_wins' do
      it 'returns the amount of won matches in this arena run' do
        arena_run.num_wins.should == 1
      end
    end

    describe '#num_losses' do
      it 'returns the amount of lost matches in this arena run' do
        arena_run.num_wins.should == 1
      end
    end
  end
end
