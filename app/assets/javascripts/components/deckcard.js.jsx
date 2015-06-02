var DeckCard = React.createClass({
	render: function(){ 
		cn = this.props.card.name.trim().replace(/[^a-zA-Z0-9-\s-\']/g, '').replace(/[^a-zA-Z0-9-]/g, '-').replace(/--/g, '-').toLowerCase();
		cardClass = "card cardWrapper "
		wrapperClass = "normal"; 
		if(this.props.qty == 2){ wrapperClass = "two"; }
		else if(this.props.card.rarity_id == 5){ wrapperClass = "legendary"; }
		cardClass = cardClass + wrapperClass;
		return (
			<div onClick={this.handleClick} alt={cn} className={cardClass}>
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
		);
	},
	handleClick: function(event) {
		this.props.click(event);
	}
});