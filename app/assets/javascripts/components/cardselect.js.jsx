var CardSelect = React.createClass({
	// props: allCards, cards, deck, type, cardstring
	// return: cardstring
	getInitialState: function(){
		return {
			cards: this.sortCards(this.props.cards),
			deck: this.props.deck, 
			cardQuant: 0,
			decklist: [],
			deckArray: [],
			selectedMana: -1,
			selectedCardType: -1,
			// filterParams: array
			// [0]: Search
			// [1]: Mana
			// 		-1: All
			//		10: 10+ 
			// [2]: Class/Neutral/All
			//		-1: All
			//		 0: Class
			//		 1: Neutral
			filterParams: ["", -1, -1],
			textImport: false
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
		var allcards = this.state.cards
			.filter(function(card) {
				// only show cards that are neutral/class cards
				return (card.type_name !== "Hero");
			})
			.map(function(card) {
				var cName = "";
				if((this.state.decklist[card.id]==1 && card.rarity_id == 5) || 
						this.state.decklist[card.id]==2){
					cName= "maxed"
				}
				return (
					<Card card={card} key={card.id} click={this._addCard(card)} cName={cName}/>
				);
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

		if(this.state.textImport){
			var selection = 
				<div id="selection" className="row">
					<textarea className="deck-text col-sm-8" 
                    ref="decktext" 
                    name="deck_text" 
                    onChange={this._text2cardstring()}
                    placeholder="Import your deck" />
					<div id="deck-text-explanation" className="col-sm-3">
						The format of the deck list is the same as Cockatrice list, you can see an example below:
						<pre><p className="hidden">"</p>1 Big Game Hunter<br/>
                  2 Perdition's Blade<br/>
                  2 Deadly Poison<br/>
                  1 Sprint<br/>
                  2 Blade Flurry<br/>
                  2 Azure Drake<br/>
                  2 SI:7 Agent<br/>
                  2 Sen'jin Shieldmasta<br/>
                  2 Eviscerate<br/>
                  1 Sap<br/>
                  2 Loot Hoarder<br/>
                  1 Assassin's Blade<br/>
                  2 Backstab<br/>
                  1 Bloodmage Thalnos<br/>
                  2 Shadowstep<br/>
                  2 Abusive Sergeant<br/>
                  2 Bloodsail Raider<br/>
                  1 Leeroy Jenkins<p className="hidden">"</p></pre>
						To import a list like above, simply paste the list in and create the deck. This will override the deck list created by the deck builder.
					</div>
				</div>;
		}
		else if(!this.state.textImport){
			var selection = <div id="selection">
			 	<div id="filter"><div className="deckbuilderFilter filterParam">
		 			<input 
		 				type="text" 
		 				id="search" 
		 				name="search" 
		 				placeholder=" Search" 
		 				onChange={this.filterSearch} />
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
	 		</div>;
		}
		return(
			<div className="row">
			 	<div className="col-sm-8 cardSelect">
			 		<h2> Choose your cards! </h2>
			 		{selection}
			 		<button className="btn grey textImportToggle" onClick={this.importToggle}>Toggle Text Import</button>
			  	<button className="btn green nextButton" onClick={this.handleClick}> Next </button>
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
	},
	handleBack: function(){
		this.props.submitBack();
	},
	handleClick: function(){
		this.props.submitClick(this._makeCardstring());
	},
  _text2cardstring: function(){
    return function(event){
      decktext = this.refs.decktext.getDOMNode().value;
      if(decktext.length===0){
        this._clearCards();
        return null;
      }
      text_array = decktext.split("\n");
      var card_array = [];
      var err = [];
      function findCardID(card_name, cards){
        for(var i=0; i<cards.length; ++i){
          if(cards[i].name === card_name){
            return cards[i].id;
          }
        }
        return null;
      }
      text_array.forEach(function(line){
        qty = line.substring(0,1);
        cardname = line.substring(2);
        card_id = findCardID(cardname, this.props.cards);
        if(qty !== "2" && qty !== "1"){
          toastr.error("There is a problem with the quantity "+qty+" on the line '"+line+"'. Quantity must be 1 or 2");
          return null;
        }
        if(card_id == null){ 
          toastr.error("Card with name '"+ cardname + "' was not found. Check if the spelling and class are correct.");
          return null;
        } else{
          card_array.push(card_id + "_" + qty);
        }
      }.bind(this));
      cardstring = card_array.join();
      this.buildDeckArray(cardstring);
      return(cardstring);
    }.bind(this);
  },
	// build deck array if this is an edit so we can load previous cards
	buildDeckArray: function(cardstring){
		if(cardstring==null || cardstring.length == 0) return; 
		deckCards = cardstring.split(","); 
		var newDecklistArray = [];
		var newDeckArray = [];
		var newQuant = 0;
		function findCard(id, cards){
			for(var i=0; i<cards.length; ++i){
				if(cards[i].id == id){
					return cards[i];
				}
			}
		}
		deckCards.forEach(function(card){
			id = parseInt(card.split("_")[0]);
			quantity = parseInt(card.split("_")[1]);
			newDecklistArray[id] = quantity;
			newDeckArray.push(findCard(id, this.state.cards));
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
	sortCards: function(cards){
		return cards.sort(function(cardA, cardB){ 
			if(cardA.mana != cardB.mana){ return cardA.mana - cardB.mana; }
			else{ 
				if(cardA.name < cardB.name){ return -1; }
				if(cardB.name < cardA.name){ return 1; }
				else{ return 0; }
			}
		});
	},
	filterMana: function(btn){
		var mana = parseInt(btn.target.value); 
		var newFilterParams = this.state.filterParams.slice();
		newFilterParams[1] = mana;
		this.setState({
			selectedMana: mana,
			filterParams: newFilterParams,
			cards: this.filterCards(this.props.cards, newFilterParams)
		});
	},
	filterKlass: function(btn){
		var klassID = parseInt(btn.target.value);
		var newFilterParams = this.state.filterParams.slice();
		newFilterParams[2] = klassID;
		this.setState({
			selectedCardType: klassID,
			filterParams: newFilterParams,
			cards: this.filterCards(this.props.cards, newFilterParams)
		});
	},
	filterSearch: function(event){
		var search = event.target.value.toLowerCase();
		var newFilterParams = this.state.filterParams.slice();
		newFilterParams[0] = search;
		var cards = this.filterCards(this.props.cards, newFilterParams);
		this.setState({
			filterParams: newFilterParams,
			cards: cards
		});
 	},
	filterCards: function(cards, filterParams){
		this.updateButtons();
		var rarityArray= ["Basic Free", "Common", "Rare", "Epic", "Legendary" ];
		var search = filterParams[0]; 
		var mana = filterParams[1];
		var klass = filterParams[2];
		if(filterParams[0] == "" && filterParams[1] == -1 && filterParams[2] == -1){
			return this.sortCards(this.props.cards);
		}
		newCards = cards.filter(function(card){
			return(
				// check if card name/description/rarity matches search
				(card.name.toLowerCase().search(search) !== -1 || 
				(card.description !== null && card.description.toLowerCase().search(search) !== -1) || 
				card.type_name.toLowerCase().search(search) !== -1 || 
				rarityArray[card.rarity_id-1].toLowerCase().search(search) !== -1) &&
				// check if card mana matches search
				(((mana != -1 && mana != 10) && card.mana==mana) || (mana == 10 && card.mana > 9) || mana == -1) &&
				// check if card class matches search
				((klass==0 && card.klass_id == this.props.klass) || (klass==1 && (card.klass_id == null || card.klass_id == 0)) || 
					(klass==-1 && (card.klass_id == this.props.klass || card.klass_id == null || card.klass_id == 0)))
			)
		}.bind(this));
		return this.sortCards(newCards);
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
		if(_cs.length === 0) { return null; }
		return this.state.deckArray
			.filter(function(card) {
				if(card === undefined) { return false; }
				if(this.state.decklist[card.id] !== undefined){ 
					return true
				} else {
					return false
				}
			}.bind(this))
			.map(function(card){
				var quant = this.state.decklist[card.id];
				return(<DeckCard key={card.id} card={card} qty={quant} type="edit" click={this._removeCard(card)} />); 
			}.bind(this));
	},
	importToggle: function(){
		this.setState({
			textImport: !this.state.textImport
		});
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
			if(this.state.cardQuant >= 30){ 
				toastr.error("There are already 30 cards in the deck!");
				return; 
			}
			// create new decklist to mutate
			var newDecklist = this.state.decklist.slice();
			// if there is one card already in the deck
			if(newDecklist[card.id] == 1){
				// can only have one legendary
				if(card.rarity_id == 5){ 
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
			else if(newDecklist[card.id] === undefined){ 
				// set the deck to have 1 of the card
				newDecklist[card.id] = 1;
				// copy the deckarray
				newDeckArray = this.state.deckArray.slice();
				// we only push a new card to the deckarray if there isn't already a card (cardstring takes care
				//   of the quantity of cards)
				newDeckArray.push(card);
				// sort the deckArray
				newDeckArray = this.sortCards(newDeckArray);
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
	_removeCard: function(card){ 
		return function(event) {
			var newDecklist = this.state.decklist.slice(); 
			if(newDecklist[card.id]==1){
				this.state.deckArray.splice(this.state.deckArray.indexOf(card), 1);
				newDecklist[card.id] = undefined;
				this.setState({
					cardQuant: this.state.cardQuant -1,
					decklist: newDecklist
				});
			}
			else if(newDecklist[card.id] == 2){ 
				newDecklist[card.id] = 1; 
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