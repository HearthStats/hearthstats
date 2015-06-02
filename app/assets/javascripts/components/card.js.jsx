var Card = React.createClass({
	render: function(){ 
		cn = this.props.card.name.trim().replace(/[^a-zA-Z0-9-\s-\']/g, '').replace(/[^a-zA-Z0-9-]/g, '-').replace(/--/g, '-').toLowerCase();
		if(cn=="si7-agent"){ 
			cn = "si-7-agent";
		}
		return (
			<img src={"/assets/cards/" + cn +".png"} className="deckbuilder-img lazy-load" onClick={this.handleClick}/>
		);
	},
	handleClick: function(event) {
		this.props.click(event);
	}
});