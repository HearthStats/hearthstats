module DecksHelper
  def copy_deck_path(deck)
    return "/decks/" + deck.slug + "/copy"
  end
end
