module DecksHelper

  def sort_for_select
    sort_array = %w(created_at
                    num_losses
                    num_matches
                    num_minions
                    name
                    num_spells
                    num_users
                    num_weapons
                    user_winrate
                    num_wins)

    sort_array.map { |s| [t(".#{s}"), s] }
  end

  def deck_export(card_array)
    text_out = []
    card_array.each do |card|
      text_out << [card[1].to_s + " " + card[0].name]
    end
    text_out.join("\n")
  end
end
