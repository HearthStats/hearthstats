require 'spec_helper'

describe TournysController do

  describe "GET 'index.slim'" do
    it "returns http success" do
      get 'index.slim'
      response.should be_success
    end
  end

  describe "GET 'signup.slim'" do
    it "returns http success" do
      get 'signup.slim'
      response.should be_success
    end
  end

  describe "GET 'past.slim'" do
    it "returns http success" do
      get 'past.slim'
      response.should be_success
    end
  end

end
