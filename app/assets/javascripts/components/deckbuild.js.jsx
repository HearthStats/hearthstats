var DeckBuild = React.createClass({
  getInitialState: function(){ 
		return {
			deck: this.props.deck, 
			cardQuant: 0,
			decklist: [],
			deckArray: []
		}
	},
	render: function(){ 
		// deck classs
		var allcards = this.props.cards.map(function(card){ 
			// only show cards that are neutral/class cards
			if(this.state.deck.klass != card.klass_id && card.klass_id != null){ return; }
			return (
				// render the card
				<Card card={card} key={card.id} click={this._addCard(card)} />
			);
		}.bind(this));
		return( 
			<div className="row">
			 	<div className="deckbuilderCards col-md-8 col-sm-12">
			 		<h2> Choose your cards! </h2>
			 		{allcards}
			 	</div>
			 	<div className="dCards col-md-4 col-sm-12"> 
			 		<h2> YOUR DECK </h2>
			 		<p>{this.state.cardQuant} of 30</p>
			 		<div className="deckbuilderWrapper deckBuilderCardsWrapper"> 
			 			{this._drawCards()}
			 		</div>
			 	</div>
			</div>
		);
	},
	_drawCards:function(){
		var _cs = this._makeCardstring();
		if(_cs.length === 0) { return; }
		dc = _cs.split(",");
		return(this.state.deckArray.map(function(card){
			if(card == undefined){ return; }
			printCard = false;
			for(i = 0; i<dc.length; i++){
				c = dc[i]; 
				id = parseInt(c.split("_")[0]);
				quantity = parseInt(c.split("_")[1]);
				if(card.id == id){ 
					printCard = true;
					quant = quantity;
					break;
				}
			}
			if(printCard == true){ return(<DeckCard card={card} qty={quant} click={this._removeCard(card.id)} />); }
		}.bind(this)));
	},

	_makeCardstring:function(){
		var Cardstring = [];
		for(i = 0; i<this.state.decklist.length; ++i){ 
			if(this.state.decklist[i] != undefined){ 
				Cardstring.push(i+"_"+this.state.decklist[i]);
			}
		}
		Cardstring = Cardstring.join();
		return(Cardstring);
	},
	_addCard:function(card){
		return function(event){
			// if there are already 30 cards
			if(this.state.cardQuant == 30){ 
				alert("There are already 30 cards in the deck!");
				return; 
			}
			// create new decklist to mutate
			var newDecklist = this.state.decklist.slice();
			// if there is one card already in the deck
			if(newDecklist[card.id] == 1){
				// can only have one legendary
				if(this.props.allCards[card.id-1].rarity_id == 5){ 
					alert("You can only have one legendary!"); 
					return; 
				}
				// set the deck to have 2 of the cards
				newDecklist[card.id] = 2;
				var newDeckArray = this.state.deckArray.slice();
				// set state to the new decklist
				this.setState({
					cardQuant: this.state.cardQuant + 1,
					decklist: newDecklist,
					deckArray: newDeckArray
				})
			}

			// if deck does not already have that card
			else if(newDecklist[card.id] == undefined){ 
				// set the deck to have 1 of the card
				newDecklist[card.id] = 1; 
				// copy the deckarray
				newDeckArray = this.state.deckArray.slice();
				// we only push a new card to the deckarray if there isn't already a card (cardstring takes care
				//   of the quantity of cards)
				newDeckArray.push(this.props.allCards[card.id-1]);
				// sort the deckArray
				newDeckArray.sort(function(cardA, cardB){ return cardA.mana - cardB.mana; });
				// set new state
				this.setState({ 
					decklist:newDecklist,
					cardQuant: this.state.cardQuant + 1,
					deckArray: newDeckArray
				})
				this._makeCardstring();
			}
			else{
				alert("Already 2 cards!");
			}
		}.bind(this);
	},
	_removeCard: function(card_id){ 
		return function(event) {
			var newDecklist = this.state.decklist.slice(); 
			if(newDecklist[card_id]==1){
				this.state.deckArray.splice(this.state.deckArray.indexOf(this.props.allCards[card_id-1]), 1);
				newDecklist[card_id] = undefined;
				this.setState({
					cardQuant: this.state.cardQuant -1,
					decklist: newDecklist
				})
			}
			else if(newDecklist[card_id] == 2){ 
				newDecklist[card_id] = 1; 
				var newDeckArray = this.state.deckArray.slice();
				this.setState({
					cardQuant: this.state.cardQuant - 1,
					decklist: newDecklist
				})
			}
			else{ 
				alert("No more cards!");
			}
		}.bind(this);
	}

});