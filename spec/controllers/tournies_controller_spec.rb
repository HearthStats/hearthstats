require 'spec_helper'

describe TourniesController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'signup'" do
    it "returns http success" do
      get 'signup'
      response.should be_success
    end
  end

  describe "GET 'past'" do
    it "returns http success" do
      get 'past'
      response.should be_success
    end
  end

end
