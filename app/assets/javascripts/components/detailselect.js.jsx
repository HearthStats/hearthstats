var DetailSelect = React.createClass({
	getInitialState: function(){
		return{
			archtypes: this.props.archtype,
			archtypeNotHere: true,
			decklist: [],
			deckArray: []
		};
	},
	componentWillMount: function(){
		this.buildDeckArray();
	},
	render: function(){
		return(
			<div className="row">
				<div className="col-md-6">
					<h2>Deck Details</h2>
					<form id="deckForm" ref="form" onSubmit={this.handleSubmit}>
						<p><input type="hidden" name="cardstring" type="hidden" value={this.props.cardstring} /></p>
						<p><input type="hidden" name="deck_klass_id" type="hidden" value={this.props.klass} /></p>
						<p><label for="deckName">Name</label>
							 <input type="text" id="deckName" name="deckName" size="30" /></p>
						<p><label for="deckArchtype">Archtype</label>
							 <input type="text" name="deckArchtype" id="deckArchtype" size="30" /></p>
						<p><label for="deckNotes">Notes</label><textarea rows="10" cols="70" name="deckNotes" id="deckNotes"></textarea></p>
						<p><button type="submit">Submit Deck</button></p>
					</form>
				</div>
				<div className="col-md-6">
					<div className="deckbuilderWrapperWrapper">
					 		<div className="deckbuilderWrapper deckBuilderCardsWrapper"> 
					 			{this._drawCards()}
					 		</div>
					 	</div>
				</div>
			</div>

		);
	},
	handleSubmit: function(event){
		event.preventDefault();
		var formData = $( this.refs.form.getDOMNode() ).serialize();
		$.ajax({
      data: formData,
      url: '/api/v2/decks/new',
      type: "POST",
      dataType: "json",
      success: function ( data ) {
        console.log(data);
      }
    });
	},
	buildDeckArray: function(){
		if(this.props.cardstring.length == 0) return; 
		deckCards = this.props.cardstring.split(","); 
		var newDecklistArray = [];
		var newDeckArray = [];
		deckCards.forEach(function(card){
			id = parseInt(card.split("_")[0]);
			quantity = parseInt(card.split("_")[1]);
			newDecklistArray[id] = quantity;
			newDeckArray.push(this.props.allCards[id-1]);
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
			decklist: newDecklistArray
		});
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
			if(printCard == true){ return(<DeckCard card={card} qty={quant} type="show"/>); }
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
	}
});