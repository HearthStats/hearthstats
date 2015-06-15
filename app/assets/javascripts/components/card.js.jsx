var Card = React.createClass({
	componentDidMount: function(){
		function init() {
		var imgDefer = document.getElementsByTagName('img');
		for (var i=0; i<imgDefer.length; i++) {
			if(imgDefer[i].getAttribute('data-src')) {
			imgDefer[i].setAttribute('src',imgDefer[i].getAttribute('data-src'));
		} } }
		init();
	},
	render: function(){ 
		cn = this.props.card.name.trim().replace(/[^a-zA-Z0-9-\s-\']/g, '').replace(/[^a-zA-Z0-9-]/g, '-').replace(/--/g, '-').toLowerCase();
		if(cn=="si7-agent"){ 
			cn = "si-7-agent";
		}
		return (
			<img src={"/assets/blind_draft/card-back.png"} data-src={"/assets/cards/" + cn +".png"} className={"deckbuilder-img " + this.props.cName} onClick={this.handleClick}/>
		);
	},
	handleClick: function(event) {
		this.props.click(event);
	}
});