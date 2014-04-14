ActiveAdmin.register Deck do
	actions :all, :except => [:new]
  remove_filter :constructeds
  remove_filter :unique_deck
  remove_filter :user
  remove_filter :matches
  remove_filter :match_deck
  remove_filter :deck_versions
  remove_filter :impressions
  remove_filter :comments



  index do
  	column :name
    column "Num Matches", :user_num_matches
    column "Wins", :user_num_wins
    column "Losses", :user_num_losses
    column :draws do |deck|
      deck.matches.where(result_id: 3).count
    end
    column "Win Rate", :user_winrate do |wr|
    	if wr.user_winrate
    		wr.user_winrate.round(2)
    	end
    end
    column :created_at
    default_actions
  end
end
