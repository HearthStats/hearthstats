var DeckCard = React.createClass({
	getInitialState: function(){
		return{
			hover: false
		}
	},
	mouseOver: function(event){
		var deckImageStyle = {
			height: '300px',
			left: event.clientX + 40 + 'px',
			top: (event.screenY-window.scrollY) - 60 + 'px',
			position: 'fixed',
			zIndex: '2000'};
		if(event.screenY + 210 > window.scrollY + window.innerHeight){
			deckImageStyle = {
				height: '300px',
				left: event.clientX + 40 + 'px',
				bottom: '5px',
				position: 'fixed',
				zIndex: '2000'};
		}

		this.setState({hover: true, deckImageStyle: deckImageStyle})
	},
	mouseOut: function(){
		return function(){this.setState({
			hover: false, deckImageStyle: null
		})}.bind(this);
	},
	render: function(){ 
		cn = this.props.card.name.trim().replace(/[^a-zA-Z0-9-\s-\']/g, '').replace(/[^a-zA-Z0-9-]/g, '-').replace(/--/g, '-').toLowerCase();
		cardClass = "card cardWrapper "
		wrapperClass = "normal"; 
		if(this.props.qty == 2){ wrapperClass = "two"; }
		else if(this.props.card.rarity_id == 5){ wrapperClass = "legendary"; }
		cardClass = cardClass + wrapperClass;

		var fullDeckImage = null;
		if(this.state.hover){
			fullDeckImage = <img 
				id="deckBuilderFullCardView" 
				key={this.props.card.id} 
				ref="fullDeckImage" 
				src={"/assets/cards/"+cn+".png"} 
				style={this.state.deckImageStyle} />;
		}

		return (
			<div onMouseOver={this.mouseOver} onMouseOut={this.mouseOut()}>
				<div onClick={this.handleClick} key={cn} alt={cn} className={cardClass}>
					<div className="mana">
						{this.props.card.mana}
					</div>
					<div className="name">
						{this.props.card.name}
					</div>
					<div className="qty">{this.props.qty}
					</div>
					<img src={"/assets/deck_images/" + cn +".png"} className="image"/>
					<div className="bg">
					</div>
				</div>
				{fullDeckImage}
			</div>
		);
	},
	handleClick: function(event) {
		if(this.props.type=="edit"){
			this.props.click(event);
		}
	}
});
