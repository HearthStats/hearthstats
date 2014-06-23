class StreamsController < ApplicationController
  def index
    twitch_response = HTTParty.get('https://api.twitch.tv/kraken/search/streams?limit=50&q=hearthstone&client_id=5p5btpott5bcxwgk46azv8tkq49ccrv')
    @streams = twitch_response['streams'].paginate(page: params[:page], per_page: 12)

    # @featured_streams = Array.new
    # @featured_streams << HTTParty.get('https://api.twitch.tv/kraken/streams/trigun0x2')
  end
end
