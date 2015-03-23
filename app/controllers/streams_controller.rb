class StreamsController < ApplicationController
  def index
    twitch_response = HTTParty.get('https://api.twitch.tv/kraken/search/streams?limit=50&q=hearthstone&client_id=5p5btpott5bcxwgk46azv8tkq49ccrv')
    @streams = twitch_response['streams'].paginate(page: params[:page], per_page: 12)
    @featured_streams = Stream.get_featured_streamers
  end
end
