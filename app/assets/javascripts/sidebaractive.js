$(document).ready(function(){
	if ($('.active').attr("data-activeimg") === "arena"){
		$('.active').find('.sidebaricon').attr('src', "/assets/swords.png");
	}else{
		$('.active').find('.sidebaricon').attr('src', "/assets/hammerwrench.png");
	}
});