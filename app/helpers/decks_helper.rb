module DecksHelper
  def copy_deck_path(deck)
    return "/decks/" + deck.slug + "/copy"
  end
  
  def sort_for_select
    sort_array = %w(created_at
                    num_losses
                    num_matches
                    num_minions
                    name
                    num_spells
                    num_users
                    num_weapons
                    winrate 
                    num_wins)
    
    sort_array.map { |s| [t(".#{s}"), s] }
  end
end
