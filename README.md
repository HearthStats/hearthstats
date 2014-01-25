HearthStats
===========

Detailed Hearthstone match statistics and tracking.


Sample API call:
----------------

The HearthStats API

### Arena

*Last Arena Run*
<pre>
http://localhost:3000/api/v1/arena_runs/show?userkey=secret
</pre>

*Start Arena Run*
<pre>
curl -X POST -H "Content-Type: application/json" -d '{ "userclass":"Rogue" }' localhost:3000/api/v1/arena_runs/new?userkey=secret
</pre>

*End Arena Run*
<pre>
curl localhost:3000/api/v1/arena_runs/end?userkey=secret
</pre>

*Arena Entry*
<pre>
curl -X POST -H "Content-Type: application/json" -d '{"oppclass":"Shaman","win":"false","gofirst":"true"}' localhost:3000/api/v1/arenas/new?userkey=secret
</pre>

### Constructed

*Constructed Entry*
<pre>
curl -X POST -H "Content-Type: application/json" -d '{"deckslot":1,"oppclass":"Shaman","win":"false","gofirst":"true", "notes":"supernotes hoho"}' localhost:3000/api/v1/constructeds/new?userkey=secret
</pre>

