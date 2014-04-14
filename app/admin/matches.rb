ActiveAdmin.register Match do
  actions :all, :except => [:new]
  remove_filter :match_run
  remove_filter :deck
  remove_filter :match_unique_deck
  remove_filter :unique_deck
  remove_filter :match_rank
  remove_filter :match_deck
  remove_filter :user
  remove_filter :arena_run

  index do
    column :deck_name do |match|
      match.deck.nil? ? "-ARENA-" : match.deck.name
    end
    column "Class", :klass
    column "Opponent Class", :oppclass
    column :match_result
    column "Coin?", :coin
    column :created_at
  end
end
