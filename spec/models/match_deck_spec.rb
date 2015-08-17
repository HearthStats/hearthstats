require 'spec_helper'

describe MatchDeck do
  describe '::generate_mass_insert_sql' do
    let(:matches_params) { [{id: 1}, {id: 2}] }

    let(:deck_id) { 5 }
    let!(:time_now) { Time.now }
    let(:db_time) { time_now.to_s(:db) }

    before(:each) do
      Time.stub(:now).and_return(time_now)
    end

    it 'generates a mass insert sql string' do
      insert_sql = MatchDeck.generate_mass_insert_sql(matches_params, deck_id)
      expect(insert_sql).to eq(<<-SQL)
INSERT INTO match_decks (`match_id`, `deck_id`, `created_at`, `updated_at`)
VALUES (1,5,'#{db_time}','#{db_time}'),(2,5,'#{db_time}','#{db_time}')
      SQL
    end
  end
end
