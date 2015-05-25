var DeckBuild = React.createClass({

	getInitialState: function(){ 
		return {
			cards: this.props.cards, 
			deck: this.props.deck
		}
	},

	render: function(){ 
		// deck classs
		klass = this.state.deck.klass_id;
		var allcards = this.state.cards.map(function(c){ 
			// only show cards that are neutral/class cards
			if(klass != c.klass_id && c.klass_id != null){ return; }
			// parameterize the card name
			cn = c.name.trim().replace(/[^a-zA-Z0-9-\s-\']/g, '').replace(/[^a-zA-Z0-9-]/g, '-').replace(/--/g, '-').toLowerCase()
			return( 
				<img src={"/assets/cards/" + cn +".png"} className="deckbuilder-img" />
			);
		});

		return( 
			<div className="row">
			 	<div className="deckbuilderCards">
			 		{allcards}
			 	</div>
			</div>
		);
	}

});