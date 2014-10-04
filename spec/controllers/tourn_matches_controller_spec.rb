require 'spec_helper'

describe TournMatchesController do
  let(:user) { create :user }
  let(:opp_user) { create :user }
  let(:t_user) { create :tourn_user, tournament_id: tournament.id, user: user }
  let(:tournament) { create :tournament }
  let(:pair) { create :tourn_pair, tournament_id: tournament.id, p1_id: user.id, p2_id: opp_user.id}

  before do
    sign_in user
  end

  describe "GET new" do
    it "returns http success" do
      get :new, t_id: tournament.id, t_pair_id: pair.id, current_user: user
      expect(response).to be_success
    end
  end

end