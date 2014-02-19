# <a href="http://hearthstats.net/"><img src="http://www.hearthstats.net/assets/hearthstatslogo.png" width="100px"/></a> HearthStats

HearthStats makes it simple to keep track of your wins and losses. Take control of your game and learn about your strengths and weaknesses with a full suite of statistics with our completely free webapp.

You can access the live site at: (HearthStats)[http://hearthstats.net]

The beta is located at: (HearthStats Beta)[http://beta.hearthstats.net]

## Contributing

If you are interested in helping out with HearthStats.net, simply for this repo and make what ever changes and then submit a pull request.

Please follow some [**naming conventions**](itsignals.cascadia.com.au/?p=7) and also some [**best practices**](http://www.sitepoint.com/10-ruby-on-rails-best-practices/).

Make sure you fill the database with some sample data before starting development or else the app will break. We are working on providing some seed data.

## Sample API call:

The HearthStats API

*Response*
```json
  {"status":"success","data":{"complete":false,"created_at":"2014-01-25T19:15:53Z","dust":0,"gold":0,"id":1833,"notes":null,"patch":"current","updated_at":"2014-01-25T19:15:53Z","user_id":1,"userclass":"Rogue"}}
```

### Matches

*Match Entry*
```
curl -X POST -H "Content-Type: application/json" -d '{"slot":1,"klass_id": 5, "oppclass_id": 3,"result_id": 1 ,"coin":"false", "rank_id":1, "mode_id":3, "oppname":"MubaMu22ba"}' localhost:3000/api/v1/matches/new?userkey=7d58fa431951c92ceb9b9cb44d481108
```

*Parameters*

* **userkey** - required
* **mode** - Accepts `Arena`, `Casual`, and `Ranked` 
* **class** - The player's class (e.g. "Mage", "Hunter", etc.)
* **oppclass** - The opponent's class (e.g. "Mage", "Hunter", etc.)
* **result** - The result of the match - accepts `Win`, `Loss`, `Draw`
* **coin** - Whether or not the user had the coin - accepts `true`, `false`
* **numturns** - The number of turns the user had in the match
* **duration** - The duration of the match in seconds
* **notes** - Any notes to add to the match
* **slot** - The deck slot number from 1 to 9 - required when `mode` is `Casual` or `Ranked`
* **ranklvl** - If mode is `Ranked` this will set the exact rank level - accepts `1` to `25`


### Arena

*Last Arena Run*
<pre>
http://localhost:3000/api/v1/arena_runs/show?userkey=secret
</pre>

*Start Arena Run*
<pre>
curl -X POST -H "Content-Type: application/json" -d '{ "klass_id": 2 }' localhost:3000/api/v1/arena_runs/new?userkey=0e7f8484496dd312c589ef21a507c393
</pre>

*End Arena Run*
<pre>
curl localhost:3000/api/v1/arena_runs/end?userkey=0e7f8484496dd312c589ef21a507c393
</pre>

*Arena Entry*
```
curl -X POST -H "Content-Type: application/json" -d '{"klass_id": 1, "oppclass_id": 3,"result_id": 3 ,"coin":"false", "mode_id":1, "oppname":"MubaMu22ba", "notes":"Schooling"}' localhost:3000/api/v1/matches/new?userkey=7d58fa431951c92ceb9b9cb44d481108
```

### Constructed

*Constructed Entry*
```
curl -X POST -H "Content-Type: application/json" -d '{"slot":1,"klass_id": 5, "oppclass_id": 3,"result_id": 1 ,"coin":"false", "rank_id":1, "mode_id":3, "oppname":"MubaMu22ba"}' localhost:3000/api/v1/matches/new?userkey=7d58fa431951c92ceb9b9cb44d481108
```

### Deck

*Activate/Deactivate Deck*
```
curl -X POST -H "Content-Type: application/json" -d '{"deck_id": 1652}' http://localhost:3000/api/v1/decks/activate?userkey=7d58fa431951c92ceb9b9cb44d481108
```
Note that the deck id must belong to the user or an error will occur

*Show All Decks*
```
http://localhost:3000/api/v1/decks/show?userkey=7d58fa431951c92ceb9b9cb44d481108
```

Contact
-------

Email: jeff@hearthstats.net

Twitter: https://twitter.com/HearthStats

Facebook: https://www.facebook.com/HearthStats.net

G+: https://plus.google.com/+HearthstatsNet/
