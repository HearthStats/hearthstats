class AddDeckLinkToDeck < ActiveRecord::Migration
  def change
    add_column :decks, :decklink, :string
  end
end
