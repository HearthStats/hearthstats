class AdditionalController < ApplicationController

  def contactus
  end

  def ads
    render layout: false
  end

  def uploader

    @urls = Rails.cache.fetch('uploader_url', expires_in: 2.days) do
      urls = Hash.new
      git_response = HTTParty.get('https://api.github.com/repos/HearthStats/HearthStats.net-Uploader/releases?per_page=1', headers: { "User-Agent" => "HearthStats"})
      urls["osx"] = git_response[0]["assets"][0]["browser_download_url"]
      urls["windows"] = git_response[0]["assets"][1]["browser_download_url"]
      urls
    end
  end

  def league

  end
  def aboutus
  end

  def help
  end

  def serverupgrade
    render layout: false
  end

  def contest_video
  end

  def news
    require 'feedjira'
    @items = Rails.cache.fetch("news", expires_in: 2.hours) do
      feeds_urls = ["http://hearthstone.blizzpro.com/feed/","http://us.battle.net/hearthstone/en/feed/news","http://www.liquidhearth.com/rss/news.xml", "http://ihearthu.com/feed/", "http://www.hearthpwn.com/news.rss", "http://www.hearthitup.com/feed/"]

      feeds = Feedjira::Feed.fetch_and_parse(feeds_urls)

      items = Array.new

      feeds.each do |feed_url, feed|
        next if [0, 301, 500].include? feed
        feed.entries.each do |entry|
          sanitized_summary = Sanitize.clean(
            entry.summary,
            elements:   ['a', 'img', 'b'],
            attributes: {
              'a'          => ['href', 'title'],
              'blockquote' => ['cite'],
              'img'        => ['alt', 'src', 'title']
            }
          )

          items << [entry.title, entry.url, sanitized_summary , entry.published]
        end

      end

      items.sort_by! { |a| a[3] }
      items.reverse!
    end

  end

end
