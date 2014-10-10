require 'spec_helper'

describe UniqueDeckType do
  let(:unique_deck) { build :unique_deck }
  let(:unique_deck_type) { build :unique_deck_type }

  describe "class methods" do
    describe "#find_type" do 
      it "returns id of a deck if cards are matched" do
        type_id = UniqueDeckType.find_type(unique_deck)
        type_id.should == 1
      end
    end
  end
end
