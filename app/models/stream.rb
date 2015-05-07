class Stream
  FEATURED = ['reynad27', 'StrifeCro', 'Day9tv']
  ### CLASS METHODS:

  def self.get_featured_streamers
    featured_streams = Array.new
    FEATURED.each do |streamer|
    
        featured_streams << get_streamer_with_status(streamer)
      
    end
    featured_streams
  end

  StreamInfo = Struct.new(:status, :details)
  def self.get_streamer_with_status(streamer)
    stream = HTTParty.get("https://api.twitch.tv/kraken/streams/#{streamer}")
    online = !stream['stream'].nil?
    status = online ? "Online" : "Offline"

    StreamInfo.new(status, stream)
  end
end
