require 'spec_helper'

describe Api::V3::MatchesController do
  let(:user) { create(:user) }
  before(:each) do
    sign_in user
  end

  describe '#multi_create' do

    let(:json_request) do
<<-JSON
{
  "deck_id": "#{deck.id}",
  "matches": [
    {
      "mode": "Ranked",
      "ranklvl": 2,
      "oppclass": "Priest",
      "result": "Loss",
      "coin": true,
      "oppname": "StrifeCro",
      "numturns": 26,
      "duration": 85,
      "notes": "CroFist!"
    },
    {
      "mode": "Casual",
      "oppclass": "Shaman",
      "result": "Win",
      "coin": false,
      "oppname": "Trump",
      "numturns": 13
    }
  ]
}
JSON
    end

    let(:deck) { create(:deck, name: 'Handlock', klass_id: 8, user_id: user.id) }

    before(:each) do
      @request.env['RAW_POST_DATA'] = json_request
      post :multi_create
      Delayed::Worker.new.run(Delayed::Job.last)
    end

    it '(eventually) adds new matches to the database' do
      first_match, second_match = Match.last(2)
      expect(first_match.mode_id).to eq(3)
      expect(first_match.oppname).to eq('StrifeCro')

      expect(second_match.result_id).to eq(1)
      expect(second_match.coin).to be(false)
    end
  end
end
