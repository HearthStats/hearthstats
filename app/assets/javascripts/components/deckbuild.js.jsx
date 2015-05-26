var DeckBuild = React.createClass({
  getInitialState: function(){ 
		return {
			deck: this.props.deck, 
			decklist: [],
			cardQuantity: 0
		}
	},
	render: function(){ 
		// deck classs
		var klass = this.state.deck.klass_id;
		var allcards = this.props.cards.map(function(c){ 
			// only show cards that are neutral/class cards
			if(klass != c.klass_id && c.klass_id != null){ return; }
			// parameterize the card name
			return (
				<Card card={c} key={c.id} click={this._addCard(c)} />
			);
		}.bind(this));
		var decklistCards = this.state.decklist.map(function(card){ 
			if(card !== null) return(
				<Card card={card} click={this._removeCard(card)} />
			)
		}.bind(this));
		return( 
			<div className="row">
			 	<div className="deckbuilderCards col-md-8 col-sm-6">
			 		{allcards}
			 	</div>
			 	<div className="dCards col-md-4 col-sm-6"> 
			 		<h2> DECKLIST CARDS </h2>
			 		{decklistCards}
			 	</div>
			</div>
		);
	},
	_addCard: function(card) {
		return function(event) { 
			var newDecklist = this.state.decklist.slice();
			newDecklist.push(card);
			this.setState({
				decklist: newDecklist
			})
		}.bind(this);
	},
	_removeCard: function(card){ 
		return function(event) { 
			var newDecklist = this.state.decklist.slice();
			newDecklist.push(card);
			this.setState({
				decklist: newDecklist
			})
		}.bind(this);
	}

});