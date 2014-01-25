HearthStats
===========

Detailed Hearthstone match statistics and tracking.


Sample API call:
----------------

The HearthStats API

*Response*
```json
	{"status":"success","data":{"complete":false,"created_at":"2014-01-25T19:15:53Z","dust":0,"gold":0,"id":1833,"notes":null,"patch":"current","updated_at":"2014-01-25T19:15:53Z","user_id":1,"userclass":"Rogue"}}%
```
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
curl localhost:3000/api/v1/arena_runs/end?userkey=0e7f8484496dd312c589ef21a507c393
</pre>

*Arena Entry*
<pre>
curl -X POST -H "Content-Type: application/json" -d '{"oppclass":"Shaman","win":"false","gofirst":"true"}' localhost:3000/api/v1/arenas/new?userkey=0e7f8484496dd312c589ef21a507c393
</pre>

### Constructed

*Constructed Entry*
<pre>
curl -X POST -H "Content-Type: application/json" -d '{"deckslot":1,"oppclass":"Shaman","win":"false","gofirst":"true", "notes":"supernotes hoho"}' localhost:3000/api/v1/constructeds/new?userkey=secret
</pre>

