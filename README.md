HearthStats
===========

Detailed Hearthstone match statistics and tracking.


Sample API call:
----------------

### Arena

*Start Arena Run*
<pre>
curl -X POST -H "Content-Type: application/json" -d '{ "userclass":"Rogue" }' localhost:3000/api/v1/arena_runs/new?key=0e7f8484496dd312c589ef21a507c393
</pre>

*End Arena Run*
<pre>
curl localhost:3000/api/v1/arena_runs/end?key=0e7f8484496dd312c589ef21a507c393
</pre>

*Arena Entry*
<pre>
curl -X POST -H "Content-Type: application/json" -d '{"oppclass":"Shaman","win":"false","gofirst":"true"}' localhost:3000/api/v1/arenas/new?key=0e7f8484496dd312c589ef21a507c393
</pre>

### Constructed

*Constructed Entry*
<pre>
curl -X POST -H "Content-Type: application/json" -d '{"deckslot":1,"oppclass":"Shaman","win":"false","gofirst":"true", "notes":"supernotes hoho"}' localhost:3000/api/v1/constructeds/new?key=0e7f8484496dd312c589ef21a507c393
</pre>

