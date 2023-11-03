({
	initializeComponent : function(objComponent, objEvent, objHelper) {
        var strCitizenId = null;

		if(window.location.search.length !== undefined && window.location.search.length !== null && window.location.search.split('=').length > 1) {
			strCitizenId = window.location.search.split('=')[1];
			objHelper.retrieveCitizenInfo(objComponent, strCitizenId);	
		}
	}    
})