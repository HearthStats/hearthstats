require 'spec_helper'

describe "Arena" do
  describe "Arena Stats" do
    it "should redirect to the login page when user is not logged in" do
      get stats_arenas_path
      response.status.should == 302
    end
  end
end
