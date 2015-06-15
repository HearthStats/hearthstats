var CardSelect = React.createClass({
	// props: allCards, cards, deck, type, cardstring
	// return: cardstring
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
			cards: this.filterCards(this.props.cards,this.props.deck, ["", -1, -1]),
			deck: this.props.deck, 
			cardQuant: 0,
			decklist: [],
			deckArray: [],
			selectedMana: -1,
			selectedCardType: -1,
			textImport: false,
			// filterParams: array
			// [0]: Search
			// [1]: Mana
			// 		-1: All
			//		10: 10+ 
			// [2]: Class/Neutral/All
			//		-1: All
			//		 0: Class
			//		 1: Neutral
			filterParams: ["", -1, -1]
		}
	},
	// check if this is a create new or edit (so we can load previous cards)
	componentWillMount: function(){
		if(this.props.type == "edit" && this.props.editBack != true){
			this.buildDeckArray(this.props.deck.cardstring);
		} else if(this.props.cardstring != ""){ 
			this.buildDeckArray(this.props.cardstring);
		}
	},
	render: function(){
		// deck classs
		var allcards = this.state.cards.map(function(card){
			var cName = "";
			if((this.state.decklist[card.id]==1 && card.rarity_id == 5) || 
					this.state.decklist[card.id]==2){
				cName= "maxed"
			}
			// only show cards that are neutral/class cards
			if(card.type_name != "Hero"){
				return (
					// render the card
					<Card card={card} key={card.id} click={this._addCard(card)} cName={cName}/>
				);
			}
		}.bind(this));
		var btns = [];
		for(var i=-1; i<11; i++){
			bClassName = "btn grey"
			var a = i;
			if(a==-1){ a = "All"; }
			if(a==10){ a = "10+"; }
			if(this.state.selectedMana == i){ bClassName = "btn grey selected"} 
			btns.push(<button className={bClassName} name={i} value={i} onClick={this.filterMana}>{a}</button>);
		}
		var cardTypes= ["All", "Class", "Neutral"]
		var klassBtn = [];
		for(var i=-1; i<2; i++){
			bClassName = "btn blue"
			if(this.state.selectedCardType == i){ bClassName += " kSelected" }
			klassBtn.push(<button className={bClassName} name={i} value={i} onClick={this.filterKlass}>{cardTypes[i+1]}</button>);
		}
		var navBtns = [];
		navBtns.push(<button className="btn green nextButton" onClick={this.handleClick}> Next </button>);
		if(this.props.type=="new"){navBtns.push(<button className="btn grey nextButton" onClick={this.handleBack}> Back </button>);}
		if(!this.state.textImport){
			return(
				<div className="row">
				 	<div className="col-sm-8 cardSelect">
				 		<h2> Choose your cards! </h2>
				 		<div id="filter"><div className="deckbuilderFilter filterParam">
				 			<input type="text" id="search" name="search" placeholder=" Search" onChange={this.filterSearch} />
				 		</div>
				 		<div className="manaFilters filterParam">
				 			{btns}
				 		</div>
				 		<div className="klassFilters filterParam">
				 			{klassBtn}
				 		</div></div>
				 		<div className="deckbuilderCards">
				 			{allcards}
				 		</div>
				  	{navBtns}
				 	</div>
				 	<div className="dCards col-sm-3"> 
				 		<h2> Your Deck </h2>
				 		<div className="deckbuilderWrapperWrapper">
					 		<div className="deckbuilderWrapper deckbuilderCardsWrapper"> 
					 			{this._drawCards()}
					 		</div>
					 	</div>
				 		<p>{this.state.cardQuant} of 30</p>
				 		<button className="btn grey cardClear" onClick={this._clearCards}>Clear Cards!</button>
				 	</div>
				</div>
			);
		} else if(this.state.textImport){
			return(
				<div className="row">
				 	<div className="col-sm-8">
				 		<h2> Text Import! </h2>
				 		<textarea rows="30" cols="70" className="notes" placeholder="Import your deck..."></textarea>
					 	<button className="btn green nextButton" onClick={this.handleClick}> Next </button>
					 	<button className="btn grey nextButton" onClick={this.handleBack}> Back </button>
					</div>
				 	<div className="dCards col-sm-3"> 
				 		<h2> Your Deck </h2>
				 		<div className="deckbuilderWrapperWrapper">
					 		<div className="deckbuilderWrapper deckbuilderCardsWrapper"> 
					 			{this._drawCards()}
					 		</div>
					 	</div>
				 		<p>{this.state.cardQuant} of 30</p>
				 		<button className="btn grey cardClear" onClick={this._clearCards}>Clear Cards!</button>
				 	</div>
				</div>
			);
		}
	},
	textImport: function(){
		return function(event){this.setState({
			textImport: !this.state.textImport
		})
		}.bind(this);
	},
	handleBack: function(){
		this.props.submitBack();
	},
	handleClick: function(){
		this.props.submitClick(this._makeCardstring());
	},
	// build deck array if this is an edit so we can load previous cards
	buildDeckArray: function(cardstring){
		if(cardstring.length == 0) return; 
		deckCards = cardstring.split(","); 
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
			selectedMana: mana,
			filterParams: newFilterParams,
			cards: this.filterCards(this.props.cards, this.state.deck, newFilterParams)
		});
	},
	filterKlass: function(btn){
		var klassID = parseInt(btn.target.value);
		var newFilterParams = this.state.filterParams.slice();
		newFilterParams[2] = klassID;
		this.setState({
			selectedCardType: klassID,
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
		this.updateButtons();
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
				((klass==0 && card.klass_id == this.props.klass) || (klass==1 && card.klass_id == null) || 
					(klass==-1 && (card.klass_id == this.props.klass || card.klass_id == null)))
			)
		}.bind(this));
	},
	updateButtons: function(){
		return function(event){
			if(this.state.selectedMana != "") {this.state.selectedMana.target.className += "selected"; }
			if(this.state.selectedCardType != "") {this.state.selectedCardType.target.className += "selected";}
		}.bind(this);
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
			if(printCard == true){ return(<DeckCard card={card} qty={quant} type="edit" click={this._removeCard(card.id)} />); }
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
				}				// set the deck to have 2 of the cards
				newDecklist[card.id] = 2;
				var newDeckArray = this.state.deckArray.slice();
				// set state to the new decklist
				this.setState({
					cardQuant: this.state.cardQuant + 1,
					decklist: newDecklist,
					deckArray: newDeckArray
				});
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
				});
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
				});
			}
			else if(newDecklist[card_id] == 2){ 
				newDecklist[card_id] = 1; 
				var newDeckArray = this.state.deckArray.slice();
				this.setState({
					cardQuant: this.state.cardQuant - 1,
					decklist: newDecklist
				});
			}
			else{ 
				toastr.error("No more cards!");
			}
		}.bind(this);
	}
});