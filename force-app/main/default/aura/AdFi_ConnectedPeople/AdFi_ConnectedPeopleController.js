({
	initializeComponent : function(objComponent, objEvent, objHelper) {
		objHelper.retrieveConnectedPeople(objComponent);
	},
    
    navigateToList : function(objComponent, objEvent, objHelper) {
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewId": '00B0n000000u4jGEAQ',
            "listViewName": 'ContactsConnected',
            "scope": "Contact"
        });
        navEvent.fire();
    },
    
    navigateToContact : function (objComponent, objEvent, objHelper) {
        var strContactId = objEvent.currentTarget.dataset.contactid;
        var objEventFired = $A.get("e.force:navigateToSObject");

        objEventFired.setParams({
            "recordId": strContactId,
            "slideDevName": "related"
        });
        
        objEventFired.fire();        
        objEvent.stopPropagation();
    }
})