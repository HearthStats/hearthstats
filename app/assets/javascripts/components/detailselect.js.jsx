var DetailSelect = React.createClass({
	getInitialState: function(){
		return{
			klass: this.props.klass,
			archtypes: this.props.archtype,
			archtypeNotHere: false,
			decklist: [],
			deckArray: [],
			version: ""
		};
	},
	componentWillMount: function(){
		this.buildDeckArray();
		if(this.props.type == "edit"){ 
			this.setState({
				klass: this.props.deck.klass_id
			})
		}
	},
	render: function(){
		if(this.props.type=="edit"){ 
			var action = "Update Deck"
		} 
		else if(this.props.type=="new"){
			var action= "Create Deck"
		}
		return(
			<div>
				<div className="row">
					<h2 className="centered">Deck Details</h2>
					<div className="row deckDetails">
						<div className="col-md-8">
							<form id="deckForm" ref="form" onSubmit={this.handleSubmit}>
								<input type="hidden" name="deck[cardstring]" type="hidden" value={this.props.cardstring} />
								<input type="hidden" name="deck[klass_id]" type="hidden" value={this.state.klass} />
								{this.deckDetailLoad()}
								<input type="checkbox" name="deck[is_public]" value="false" type="hidden" />
								<input type="checkbox" className="marg" name="deck[is_public]" value="true">Make this deck public</input>
								<div className="submitButtons">
									<input className = "btn submitButton green" type="submit" value={action} />
									{this.versionControl()}
								</div>
							</form>
							<button className="btn nextButton" onClick={this.props.backButton}>Back</button>
						</div>
						<div className="col-md-4">
							<div className="deckbuilderWrapperWrapper">
							 		<div className="deckbuilderWrapper deckbuilderCardsWrapper"> 
							 			{this._drawCards()}
							 		</div>
							 	</div>
						</div>
					</div>
				</div>
			</div>

		);
	},
	deckDetailLoad: function(){
		if(this.props.type == "edit"){
			return(
				<div>
					<div className="row">
						<div className="col-md-6 col-xs-6">
							<div><label for="deckName">Name:</label></div>
							<input type="text" id="deckName" ref="deckname" name="deck[name]" defaultValue={this.props.deck.name} size="30"/>
						</div>
						{this.displayArchtypes()}
					</div>
					<div className="row">
						<div><label className="notes">Notes:</label></div>
						<textarea rows="10" name="deck[notes]" className="notes" id="deckNotes" placeholder="Write about your deck...">{this.props.deck.notes}</textarea><br/>
					</div>
				</div>
			);
		} else{
			return(
				<div>
					<div className="row">
						<div className="col-md-6 col-xs-6">
							<div><label for="deckName">Name:</label></div>
							<input type="text" id="deckName" ref="deckname" name="deck[name]" placeholder="Your deck name..." size="30"/>
						</div>
						{this.displayArchtypes()}
					</div>
					<br/>
					<div className="row">
						<div><label className="notes">Notes:</label></div>
						<textarea rows="10" name="deck[notes]" className="notes" id="deckNotes" placeholder="Write about your deck..."></textarea><br/>
					</div>
				</div>
			);
		}
	},
	versionControl: function(){
		if(this.props.type == "edit"){
			var current_version = parseFloat(this.props.currentVersion.version);
			return(
				<div>
					<input className="btn vButton yellow" onClick={this.setVersion("minor_version")} name="minor_version" value={"Save as v" + (current_version+0.1).toFixed(1)} type="submit" />
					<input className="btn vButton green" onClick={this.setVersion("major_version")} name="major_version" value={"Save as v"+ (Math.floor(current_version)+1.0) } type="submit"/>
				</div>
			)
		}
	},
	setVersion: function(version_type){
		return function(event){
			this.setState({
				version: version_type
			});
		}.bind(this);
	},
	displayArchtypes: function(){
		if(!this.state.archtypeNotHere){
			var archtypes = this.props.archtype.map(function(archtype){
				if(archtype.klass_id == this.props.klass){
					return(
						<option value={archtype.id} name="unique_deck_type_id">{archtype.name}</option>
					);
				}
			}.bind(this));
			return(
				<div className="col-md-6 col-xs-6">
					<div><label>Archetype:</label></div>
					<select ref="archtypes">
						<option value="" name="unique_deck_type_id"> </option>
						{archtypes}
					</select>
					<a className="noArchtype" onClick={this.setNoArchtype}>Archetype Not Here</a>
				</div>
			);
		}
		else{
			return(
				<div>
					<div><label>Archtype:</label></div>
					<input type="text" ref="archtypes" name="new_archtype" size="30" placeholder="Your deck's archtype...">Archtype</input>
				</div>
			);
		}
	},
	setNoArchtype: function(){
		this.setState({
			archtypeNotHere: true
		});
	},
	handleSubmit: function(version){
		var formData = $(this.refs.form.getDOMNode()).serialize();
		if(this.props.type=="new"){
			event.preventDefault();
			$.ajax({
	      data: formData,
	      url: '/decks',
	      type: "POST",
	      dataType: "json",
	      success: function ( data ) {
	      	window.location.href = data.slug
	      }
	    })
		} else{
			event.preventDefault();
			if(this.state.version != ""){ 
				formData += "&";
				formData += this.state.version;
				formData += "= "
			}
			$.ajax({
	      data: formData,
	      url: '/decks/'+this.props.deck.id,
	      type: "PUT",
	      dataType: "json",
	      success: function ( data ) {
	      	window.location.href = '../' + data.slug
	      }
	    })			
		}
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