class AdditionalController < ApplicationController
  caches_action :news, :expires_in => 1.day
  
  def contactus
  end

  def aboutus
  end

  def help
  end

  def serverupgrade
  	render :layout=>false
  end

  def news

  	feeds_urls = ["http://us.battle.net/hearthstone/en/feed/news", "http://ihearthu.com/feed/", "http://hearthstone.blizzpro.com/feed/", "http://www.managrind.com/feed/", "http://www.hearthitup.com/feed/"]

  	feeds = Feedzirra::Feed.fetch_and_parse(feeds_urls)

  	x = 0
    @items = Array.new

    feeds.each do |feed_url, feed|

      feed.entries.each do |entry|
        @items[x] = [entry.title, entry.url, entry.summary, entry.published]
        x = x + 1
      end

    end

    @items.sort_by! { |a| a[3] }
    @items.reverse!

  end

end
