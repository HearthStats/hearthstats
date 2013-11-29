require 'spec_helper'

describe "Arena" do
  describe "Arena Stats" do
    it "should exist" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get stats_arenas_path
      response.status.should be(200)
    end
  end
end
