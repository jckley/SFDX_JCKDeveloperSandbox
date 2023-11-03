({
	initializeComponent : function(objComponent, objEvent, objHelper) {
        var strCitizenId = null;
        
        strCitizenId = objComponent.get('v.recordId');
		objHelper.retrieveCitizenInfo(objComponent, strCitizenId);
        objHelper.retrieveUserPermissions(objComponent);
        //objHelper.retrieveBaseUrl(objComponent);
	},
})