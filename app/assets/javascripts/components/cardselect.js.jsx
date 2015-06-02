var CardSelect = React.createClass({
	// props: allCards, cards, deck, type
	// return: cardstring, deckarray
	getInitialState: function(){
		var sortedCards = this.props.cards.sort(function(cardA, cardB){ 
			if(cardA.mana != cardB.mana){ return cardA.mana - cardB.mana; }
			else{ 
				if(cardA.name < cardB.name){ return -1; }
				if(cardB.name < cardA.name){ return 1; }
				else{ return 0; }
			}
		});
		return {
			cards: this.filterCards(this.props.cards,this.props.deck, ["", -1, 0]),
			deck: this.props.deck, 
			cardQuant: 0,
			decklist: [],
			deckArray: [],

			// filterParams: array
			// [0]: Search
			// [1]: Mana
			// 		-1: All
			//		10: 10+ 
			// [2]: Class/Neutral/All
			//		 0: All
			//		-1: Class
			//		 1: Neutral
			filterParams: ["", -1, 0]
		}
	},
	// check if this is a create new or edit (so we can load previous cards)
	componentWillMount: function(){
		if(this.props.type == "edit"){
			this.buildDeckArray();
		}
	},
	render: function(){
		// deck classs
		var allcards = this.state.cards.map(function(card){
			// only show cards that are neutral/class cards
			if(card.type_name != "Hero"){
				return (
					// render the card
					<Card card={card} key={card.id} click={this._addCard(card)} />
				);
			}
		}.bind(this));
		return(
			<div id="cardSelect" className="row">
				 	<div className="col-md-8 col-sm-12">
				 		<h2> Choose your cards! </h2>
				 		<div className="deckbuilderFilter">
				 			<input type="text" id="search" name="search" placeholder=" Search" size="50" onChange={this.filterSearch} />
				 		</div>
				 		<div className="manaFilters">
				 			<button className="btn grey" name="-1" value="-1" onClick={this.filterMana}>All</button>
				 			<button className="btn grey" name="0" value="0" onClick={this.filterMana}>0</button>
				 			<button className="btn grey" name="1" value="1" onClick={this.filterMana}>1</button>
						 	<button className="btn grey" name="2" value="2" onClick={this.filterMana}>2</button>
						 	<button className="btn grey" name="3" value="3" onClick={this.filterMana}>3</button>
						 	<button className="btn grey" name="4" value="4" onClick={this.filterMana}>4</button>
						 	<button className="btn grey" name="5" value="5" onClick={this.filterMana}>5</button>
						 	<button className="btn grey" name="6" value="6" onClick={this.filterMana}>6</button>
						 	<button className="btn grey" name="7" value="7" onClick={this.filterMana}>7</button>
						 	<button className="btn grey" name="8" value="8" onClick={this.filterMana}>8</button>
						 	<button className="btn grey" name="9" value="9" onClick={this.filterMana}>9</button>
						 	<button className="btn grey" name="10" value="10" onClick={this.filterMana}>10+</button>
				 		</div>
				 		<div className="klassFilters">
				 			<button className="btn blue" value="-1" onClick={this.filterKlass}>Class</button>
				 			<button className="btn blue" value="1" onClick={this.filterKlass}>Neutral</button>
				 			<button className="btn blue" value="0" onClick={this.filterKlass} autofocus>All</button>
				 		</div>
				 		<div className="deckbuilderCards">
				 			{allcards}
				 		</div>
				 	</div>
				 	<div className="dCards col-md-4 col-sm-12"> 
				 		<h2> YOUR DECK </h2>
				 		<p>{this.state.cardQuant} of 30</p>
				 		<div className="deckbuilderWrapperWrapper">
					 		<div className="deckbuilderWrapper deckBuilderCardsWrapper"> 
					 			{this._drawCards()}
					 		</div>
					 	</div>
				 		<button className="btn" onClick={this._clearCards}>Clear Cards!</button>
				 	</div>
				</div>
		);
	},
	// build deck array if this is an edit so we can load previous cards
	buildDeckArray: function(){
		console.log("building deck");
		if(this.props.deck.cardstring.length == 0) return; 
		deckCards = this.props.deck.cardstring.split(","); 
		var newDecklistArray = [];
		var newDeckArray = [];
		var newQuant = 0;
		deckCards.forEach(function(card){
			id = parseInt(card.split("_")[0]);
			quantity = parseInt(card.split("_")[1]);
			newDecklistArray[id] = quantity;
			newDeckArray.push(this.props.allCards[id-1]);
			newQuant = newQuant + quantity;
		}.bind(this));
		newDeckArray.sort(function(cardA, cardB){ 
			if(cardA.mana != cardB.mana){ return cardA.mana - cardB.mana; }
			else{ 
				if(cardA.name < cardB.name){ return -1; }
				if(cardB.name < cardA.name){ return 1; }
			else{ return 0; }
			}
		});
		this.setState({
			deckArray: newDeckArray,
			decklist: newDecklistArray,
			cardQuant: newQuant
		});
	},
	filterMana: function(btn){
		var mana = parseInt(btn.target.value); 
		var newFilterParams = this.state.filterParams.slice();
		newFilterParams[1] = mana;
		this.setState({
			filterParams: newFilterParams,
			cards: this.filterCards(this.props.cards, this.state.deck, newFilterParams)
		});
	},
	filterKlass: function(btn){
		var klassID = parseInt(btn.target.value);
		var newFilterParams = this.state.filterParams.slice();
		newFilterParams[2] = klassID;
		this.setState({
			filterParams: newFilterParams,
			cards: this.filterCards(this.props.cards, this.state.deck, newFilterParams)
		});
	},
	filterSearch: function(event){
		var search = event.target.value.toLowerCase();
		var newFilterParams = this.state.filterParams.slice();
		newFilterParams[0] = search;
		this.setState({
			filterParams: newFilterParams,
			cards: this.filterCards(this.props.cards, this.state.deck, newFilterParams)
		});
 		},
	filterCards: function(cards, deck, filterParams){
		var rarityArray= ["Basic Free", "Common", "Rare", "Epic", "Legendary" ];
		var search = filterParams[0]; 
		var mana = filterParams[1];
		var klass = filterParams[2];
		return cards.filter(function(card){
			return(
				// check if card name/description/rarity matches search
				(card.name.toLowerCase().search(search) !== -1 || 
				(card.description !== null && card.description.toLowerCase().search(search) !== -1) || 
				card.type_name.toLowerCase().search(search) !== -1 || 
				rarityArray[card.rarity_id-1].toLowerCase().search(search) !== -1) &&
				// check if card mana matches search
				(((mana != -1 && mana != 10) && card.mana==mana) || (mana == 10 && card.mana > 9) || mana == -1) &&
				// check if card class matches search
				((klass==-1 && card.klass_id == this.props.klass) || (klass==1 && card.klass_id == null) || 
					(klass==0 && (card.klass_id == this.props.klass || card.klass_id == null)))
			)
		}.bind(this));
	},
	_clearCards:function(){
		return(
			this.setState({
				cardQuant: 0,
				decklist: [],
				deckArray: []
			})
		);
	},

	_drawCards:function(){
		var _cs = this._makeCardstring();
		if(_cs.length === 0) { return; }
		return(this.state.deckArray.map(function(card){
			if(card == undefined){ return; }
			printCard = false;
			if(this.state.decklist[card.id]!=undefined){ 
				quant = this.state.decklist[card.id];
				printCard = true;
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
				toastr.error("There are already 30 cards in the deck!");
				return; 
			}
			// create new decklist to mutate
			var newDecklist = this.state.decklist.slice();
			// if there is one card already in the deck
			if(newDecklist[card.id] == 1){
				// can only have one legendary
				if(this.props.allCards[card.id-1].rarity_id == 5){ 
					toastr.error("You can only have one legendary!"); 
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
				newDeckArray.sort(function(cardA, cardB){ 
					if(cardA.mana != cardB.mana){ return cardA.mana - cardB.mana; }
					else{ 
						if(cardA.name < cardB.name){ return -1; }
						if(cardB.name < cardA.name){ return 1; }
						else{ return 0; }
					}
				});
				// set new state
				this.setState({ 
					decklist:newDecklist,
					cardQuant: this.state.cardQuant + 1,
					deckArray: newDeckArray
				})
				this._makeCardstring();
			}
			else{
				toastr.error("Already 2 cards!");
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
				toastr.error("No more cards!");
			}
		}.bind(this);
	}
});