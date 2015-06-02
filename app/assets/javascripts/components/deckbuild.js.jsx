var DeckBuild = React.createClass({
	getInitialState: function(){
		return{
			cardstring: "",
			chosenKlass: 0,
			deck: this.props.deck,
			klassSelected: this.props.deck != null && this.props.deck.klass_id != null,
			moveOn: false 
		};
	},
  render: function(){
  	// if class is already selected, move onto choosing cards 
  	// 		ie: already chosen class or deck is already created and just editing
  	if(this.state.klassSelected && !this.state.moveOn){ 
  		return(
				<div>
					<CardSelect allCards={this.props.allCards} klass={this.state.chosenKlass} cards={this.props.cards} deck={this.props.deck} type={this.props.type} />
					<button className="btn" onClick={this.handleCardsSelect}>Next</button>
				</div>
  		);
  	}
		else if(!this.state.klassSelected){
			var klassArray = ["Druid,1","Hunter,2","Mage,3","Paladin,4","Priest,5","Rogue,6","Shaman,7","Warlock,8","Warrior,9"]
			var x = klassArray.map(function(klass){
				klass_ident = klass.split(",");
				klass_name = klass_ident[0];
				klass_id = klass_ident[1];
				return(
					<img src={"/assets/Icons/Classes/full/" + klass_name + "_full.png"} className={"splash-class"} onClick={this.handleKlassSelect(klass_id)} />
				);
			}.bind(this));
			return(
				<div>
					{x}
					<button className="btn" onClick={this.handleKlassSubmit}>Next</button>
				</div>
			);
		} else{ 
			return(
				<DetailSelect /> );
		}
	},
	handleKlassSelect: function(klass_id){
		return function(event){
			this.setState({
				chosenKlass: klass_id
			})
		}.bind(this);
	},
	handleKlassSubmit: function(){
		this.setState({
				klassSelected: true
		});
	},
	handleCardsSelect: function(new_cardstring){
		this.setState({
			cardstring: new_cardstring, 
			moveOn: true
		});
	}
});