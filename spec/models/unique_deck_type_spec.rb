require 'spec_helper'

describe UniqueDeckType do
  subject(:unique_deck_type) { create(:unique_deck_type, name: "Test Warrior", klass_id: 1) }
  let(:unique_deck) { create(:unique_deck_with_unique_deck_type, unique_deck_type: unique_deck_type) }

  describe "class methods" do
    describe "::find_type" do
      it "returns id of a deck type if cards are matched" do
        type_id = UniqueDeckType.find_type(unique_deck.klass_id, unique_deck.cardstring)
        type_id.should == 1
      end
    end

    describe "::match_type" do
      it "returns 'true' if matched" do
        matched = UniqueDeckType.match_type(unique_deck.cardstring, unique_deck_type)
        matched.should == true
      end
    end

    describe "::get_type_popularity" do
      subject(:type_popularity) { UniqueDeckType.get_type_popularity(2) }
      let(:deck) { create(:deck_with_unique_deck, unique_deck: unique_deck) }

      before(:each) do
        UniqueDeckType.transaction do
          10.times { create(:match, klass_id: 1, deck: deck) }
        end
      end

      it "reports the percentage of valid matches played with decks from each deck type" do
        expect(type_popularity).to eq("Test Warrior" => 100.0)
      end

      context "with infrequently played deck types" do
        let(:unpopular_deck_type) { create(:unique_deck_type, name: "Wisp Priest", klass_id: 2) }
        let(:unpopular_unique_deck) { create(:unique_deck_with_unique_deck_type, unique_deck_type: unpopular_deck_type) }
        let(:unpopular_deck) { create(:deck_with_unique_deck, unique_deck: unpopular_unique_deck) }

        before(:each) do
          UniqueDeckType.transaction do
            5.times { create(:match, klass_id: 2, deck: unpopular_deck) }
          end
        end

        it "excludes deck types that have been played less than 10 times" do
          expect(type_popularity.keys).not_to include("Wisp Priest")
          expect(type_popularity["Test Warrior"]).to eq(100.0)
        end
      end

      context "with unnamed deck types" do
        let(:noname_deck_type) { create(:unique_deck_type, name: nil, klass_id: 2) }
        let(:noname_unique_deck) { create(:unique_deck_with_unique_deck_type, unique_deck_type: noname_deck_type) }
        let(:noname_deck) { create(:deck_with_unique_deck, unique_deck: noname_unique_deck) }

        before(:each) do
          UniqueDeckType.transaction do
            10.times { create(:match, klass_id: 2, deck: noname_deck) }
          end
        end

        it "excludes deck types without names" do
          expect(type_popularity.keys.count).to eq(1)
        end
      end

      context "with old match data" do
        let(:old_deck_type) { create(:unique_deck_type, name: "Miracle Rogue", klass_id: 3) }
        let(:old_unique_deck) { create(:unique_deck_with_unique_deck_type, unique_deck_type: old_deck_type) }
        let(:old_deck) { create(:deck_with_unique_deck, unique_deck: old_unique_deck) }

        before(:each) do
          UniqueDeckType.transaction do
            10.times { create(:match_deck, deck: old_deck, created_at: 3.hours.ago) }
          end
        end

        it "only counts matches from the given time period" do
          expect(type_popularity.keys).to include("Test Warrior")
          expect(type_popularity.keys).not_to include("Miracle Rogue")
        end
      end
    end

    # describe "#find_from_log" do
    #   it "returns correct type from logs" do
    #     log = File.read(Rails.root.join('spec','models','sample_log.json'))
    #     args = {
    #       :klass_id => 4,
    #       :user => "BitFlipper",
    #       :log => log
    #     }
    #     type = UniqueDeckType.find_from_log(args)
    #     type.should == 4
    #   end
    # end
  end
end
