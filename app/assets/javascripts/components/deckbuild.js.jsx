var DeckBuild = React.createClass({
	// props: all_cards, cards, klasses, archtypes, deck
	getInitialState: function(){
		return{
			cardstring: "",
			chosenKlass: this.props.klass,
			deck: this.props.deck,
			klassSelected: this.props.deck != null && this.props.deck.klass_id != null,
			moveOn: false,
			editBack: false
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
					<CardSelect editBack={this.state.editBack} cardstring={this.state.cardstring} klass={this.state.chosenKlass} cards={this.props.cards} submitClick={this.handleCardsSelect} deck={this.props.deck} type={this.props.type} />
				</div>
  		);
  	} else{ 
			return(
				<DetailSelect type={this.props.type} currentVersion={this.props.currentVersion} deck={this.props.deck} klass={this.state.chosenKlass} backButton={this.handleCardResubmit} cards={this.props.cards} archtype={this.props.archtypes} cardstring={this.state.cardstring} /> );
		}
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
			moveOn: false,
			editBack: true
		});
	}
});