class AdminMailer < ActionMailer::Base
  default :from => "admin@hearthstats.net"

  def new_archtype(unique_deck)
    @unique_deck = unique_deck
    mail to: "admin@hearthstats.net", subject: "New UniqueDeckType"
  end
end
