var DeckBuild = React.createClass({
	// props: all_cards, cards, klasses, archtypes, deck
	getInitialState: function(){
		return{
			cardstring: "",
			chosenKlass: 0,
			deck: this.props.deck,
			klassSelected: this.props.deck != null && this.props.deck.klass_id != null,
			moveOn: false 
		};
	},
	componentWillMount: function(){
		if(this.props.type == "edit"){
			this.setState({
				chosenKlass: this.props.deck.klass_id
			});
		}
	},
  render: function(){
  	// if class is already selected, move onto choosing cards 
  	// 		ie: already chosen class or deck is already created and just editing
  	if(this.state.klassSelected && !this.state.moveOn){ 
  		return(
				<div>
					<CardSelect submitBack={this.goBackKlass} cardstring={this.state.cardstring} allCards={this.props.allCards} klass={this.state.chosenKlass} cards={this.props.cards} submitClick={this.handleCardsSelect} deck={this.props.deck} type={this.props.type} />
				</div>
  		);
  	}
		else if(!this.state.klassSelected){
			var klassArray = ["Druid,1","Hunter,2","Mage,3","Paladin,4","Priest,5","Rogue,6","Shaman,7","Warlock,8","Warrior,9"]
			var x = klassArray.map(function(klass){
				klass_ident = klass.split(",");
				klass_id = klass_ident[1];
				klass_name = klass_ident[0];
				return(
					<img src={"/assets/Icons/Classes/full/" + klass_name + "_full.png"} id={klass_id} className={"splash-class"} onClick={this.handleKlassSelect(klass_id)} />
				);
			}.bind(this));
			return(
				<div className="klassSelect">
					{x}
				</div>
			);
		} else{ 
			return(
				<DetailSelect type={this.props.type} currentVersion={this.props.currentVersion} deck={this.props.deck} klass={this.state.chosenKlass} backButton={this.handleCardResubmit} archtype={this.props.archtypes} allCards={this.props.allCards} cardstring={this.state.cardstring} /> );
		}
	},
	goBackKlass: function(){
		this.setState({
			klassSelected: false
		});
	},
	handleKlassSelect: function(klass_id){
		return function(event){
			this.setState({
				chosenKlass: klass_id,
				klassSelected: true
			})
		}.bind(this);
	},
	handleCardsSelect: function(new_cardstring){
		this.setState({
			cardstring: new_cardstring, 
			moveOn: true
		});
	},
	handleCardResubmit: function(){
		this.setState({
			moveOn: false
		});
	}
});