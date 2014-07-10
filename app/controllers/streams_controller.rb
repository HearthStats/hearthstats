class StreamsController < ApplicationController
  def index
    twitch_response = HTTParty.get('https://api.twitch.tv/kraken/search/streams?limit=50&q=hearthstone&client_id=5p5btpott5bcxwgk46azv8tkq49ccrv')
    @streams = twitch_response['streams'].paginate(page: params[:page], per_page: 12)

    @featured_streams = Array.new
    streamers = ['ceciltv', 'rambunctiousrogue','kisstafer','bradhs','imd2','ihosty']
    streamers.each do |u|
      channel_info = HTTParty.get("https://api.twitch.tv/kraken/channels/#{u}")
      online = !HTTParty.get("https://api.twitch.tv/kraken/streams/#{u}")['stream'].nil?
      status = online ? "Online" : "Offline"
      @featured_streams << [status, channel_info]
    end
  end
end
