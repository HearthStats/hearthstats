require 'spec_helper'

describe MatchRank do
  describe '::generate_mass_insert_sql' do
    let(:matches_params) do
      [{
        id: 1,
        ranklvl: "2"
      }]
    end

    let!(:time_now) { Time.now }
    let(:db_time) { time_now.to_s(:db) }

    before(:each) do
      Time.stub(:now).and_return(time_now)
    end

    it 'generates a mass insert sql string' do
      insert_sql = MatchRank.generate_mass_insert_sql(matches_params)
      expect(insert_sql).to eq(<<-SQL)
INSERT INTO match_ranks (`match_id`, `rank_id`, `created_at`, `updated_at`)
VALUES (1,2,'#{db_time}','#{db_time}')
      SQL
    end
  end
end
