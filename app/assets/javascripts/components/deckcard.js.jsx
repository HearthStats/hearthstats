var DeckCard = React.createClass({
	getInitialState: function(){
		return{
			hover: false
		}
	},
	mouseOver: function(){
		return function(){this.setState({
			hover: true
		});}.bind(this);
	},
	mouseOut: function(){
		return function(){this.setState({
			hover: false
		})}.bind(this);
	},
	render: function(){ 
		cn = this.props.card.name.trim().replace(/[^a-zA-Z0-9-\s-\']/g, '').replace(/[^a-zA-Z0-9-]/g, '-').replace(/--/g, '-').toLowerCase();
		cardClass = "card cardWrapper "
		wrapperClass = "normal"; 
		if(this.props.qty == 2){ wrapperClass = "two"; }
		else if(this.props.card.rarity_id == 5){ wrapperClass = "legendary"; }
		cardClass = cardClass + wrapperClass;
		var fullDeckImage;
		var deckImageStyle = {
			height: '300px',
			left: window.event.pageX + 40 + 'px',
			top: (window.event.pageY-window.scrollY) + 'px',
			position: 'fixed',
			zIndex: '2000'};
		if(window.event.pageY + 300 > window.scrollY + window.innerHeight){
			deckImageStyle = {
				height: '300px',
				left: window.event.pageX + 40 + 'px',
				bottom: '5px',
				position: 'fixed',
				zIndex: '2000'};
		}
		
		if(this.state.hover){
			fullDeckImage = (<img id="deckBuilderFullCardView" key={this.props.card.id} ref="fullDeckImage" src={"/assets/cards/"+cn+".png"} style={deckImageStyle} />);
		}
		return (
			<div onMouseOver={this.mouseOver()} onMouseOut={this.mouseOut()} >
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
