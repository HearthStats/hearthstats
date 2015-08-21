require 'spec_helper'

describe Api::V3::MatchesController do
  let(:user) { create(:user) }
  before(:each) do
    sign_in user
  end

  describe '#multi_create' do
    let(:deck) { create(:deck, name: 'Handlock', klass_id: 8, user_id: user.id) }

    context 'method logic' do

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

      before(:each) do
        @request.env['RAW_POST_DATA'] = json_request
        post :multi_create
      end

      it '(eventually) adds new matches to the database' do
        first_match, second_match = Match.last(2)
        expect(first_match.mode_id).to eq(3)
        expect(first_match.oppname).to eq('StrifeCro')

        expect(second_match.result_id).to eq(1)
        expect(second_match.coin).to be(false)
      end

      it 'creates a match_deck association object for each new match' do
        first_match, second_match = Match.last(2)
        first_match_deck, second_match_deck = MatchDeck.last(2)

        expect(first_match.match_deck).to eq(first_match_deck)
        expect(second_match.match_deck).to eq(second_match_deck)

        expect(first_match_deck.deck).to eq(deck)
      end

      it 'only creates match_rank assoications for Ranked mode matches' do
        first_match, second_match = Match.last(2)
        expect(MatchRank.count).to eq(1)
        expect(MatchRank.last.match).to eq(first_match)
      end
    end

#    context 'performance' do
#      let(:json_request) do
#        matches = []
#        200.times do
#          matches << {
#            mode: Match::MODES_LIST.values.sample,
#            ranklvl: rand(25) + 1,
#            oppclass: Klass::LIST.values.sample,
#            result: Match::RESULTS_LIST.values.sample,
#            coin: ["true", "false"].sample,
#          }
#        end

#        matches.map! do |match|
#          <<-JSON
#{
#  "mode": "#{match[:mode]}",
#  "ranklvl": "#{match[:ranklvl]}",
#  "oppclass": "#{match[:oppclass]}",
#  "result": "#{match[:result]}",
#  "coin": "#{match[:coin]}"
#}
#          JSON
#        end

#        <<-JSON
#{
#  "deck_id": "#{deck.id}",
#  "matches": [#{matches.join(",")}]
#}
#        JSON
#      end

#      it 'is fast!' do
#        Benchmark.bmbm do |bm|
#          bm.report("api") do
#            100.times do
#              @request.env['RAW_POST_DATA'] = json_request
#              post :multi_create
#            end
#          end
#        end

#        puts "Matches: #{Match.count}"
#        puts "MatchDecks: #{MatchDeck.count}"
#        puts "MatchRanks: #{MatchRank.count}"
#      end

#    end
  end
end
