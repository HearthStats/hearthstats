module DecksHelper
  
  def sort_for_select
    sort_array = %w(decks.created_at
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
