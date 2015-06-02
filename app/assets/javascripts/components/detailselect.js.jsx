var DetailSelect = React.createClass({
	// props: cardstring
	render: function(){
		return(
			<div className="row">
				<h2>Deck Details</h2>
				<div className="col-md-6">
					<div className="row">
						<div className="col-md-6">
							<label for="deckName">Name</label><br/>
							<input type="text" id="deckName" size="30" />
						</div>
						<div className="col-md-6">
							<label for="deckArchtype">Archtype</label><br/>
							<input type="text" id="deckArchtype" size="30" />
						</div>
					</div>
					<div className="row"><label for="deckNotes">Notes</label><br/>
					<textarea rows="10" cols="70" id="deckNotes"> </textarea></div>
				</div>
			</div>
		);
	}
});