var KlassSelect = React.createClass({
	// props: function to handle class selection
	
	getInitialState: function(){
		return{
			klassArray :["Druid,1","Hunter,2","Mage,3","Paladin,4","Priest,5","Rogue,6","Shaman,7","Warlock,8","Warrior,9"]
		}
	},

	render: function(){
		var x = this.state.klassArray.map(function(klass){
			klass_ident = klass.split(",");
			klass_name = klass_ident[0];
			klass_id = klass_ident[1];
			return(
				<img src={"/assets/Icons/Classes/full/" + klass_name + "_full.png"} className="splash-class" onClick={this.props.click(klass_id)} />
			);
		}.bind(this));
		return(
			<div>{x}</div>
		)
	}
});