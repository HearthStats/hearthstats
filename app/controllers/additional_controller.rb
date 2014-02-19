class AdditionalController < ApplicationController

  def contactus
  end

  def uploader
  end
  
  def uploader_download_win
    version = HTTParty.get(
      "http://raw.github.com/JeromeDane/HearthStats.net-Uploader/master/src/version"
    )
    redirect_to("https://github.com/JeromeDane/HearthStats.net-Uploader/releases/download/v" + version + "/HearthStats.net.Uploader.v" + version + ".zip")
  end
  
  def uploader_download_osx
    version = HTTParty.get(
      "http://raw.github.com/JeromeDane/HearthStats.net-Uploader/master/src/version-osx"
    )
    redirect_to("https://github.com/JeromeDane/HearthStats.net-Uploader/releases/download/v" + version + "-osx/HearthStats.net.Uploader.v" + version + "-osx.zip")
  end
  
  def aboutus
  end

  def help
  end

  def serverupgrade
  	render :layout=>false
  end

  def news

  	feeds_urls = ["http://us.battle.net/hearthstone/en/feed/news","http://www.liquidhearth.com/rss/news.xml", "http://ihearthu.com/feed/", "http://www.hearthpwn.com/news.rss", "http://www.hearthitup.com/feed/"]

  	feeds = Feedzirra::Feed.fetch_and_parse(feeds_urls)

  	x = 0
    @items = Array.new

    feeds.each do |feed_url, feed|
    	next if feed == 0 || feed == 500
      feed.entries.each do |entry|
        @items[x] = [entry.title, entry.url, entry.summary, entry.published]
        x = x + 1
      end

    end

    @items.sort_by! { |a| a[3] }
    @items.reverse!

  end

end
