require 'json'
class LogParser
  attr_accessor :args
  def initialize(args)
    @args = args
  end

  def parse!
    json = JSON.parse(args[:txt_file])
    json["turns"].shift
    if json["firstPlayerName"] == args[:username]
      playerid = json["firstPlayer"] 
      oppid = json["secondPlayer"]
    else
      oppid = json["firstPlayer"] 
      playerid = json["secondPlayer"]
    end
    json["turns"].each do |turn|
      turn["actions"].each do |action|
        id = args[:user_id] if action["player"] == playerid
        Action.create(
          time: action["time"],
          action: action["action"],
          card: action["card"],
          card_id: action["cardId"],
          user_id: id,
          match_id: args[:match_id]
        )
      end
    end
  end
end
