({
	navigateToTerritory : function(component, event, helper) {
        var recordId = event.currentTarget.id;
        
        var eventFired = $A.get("e.force:navigateToSObject");
        eventFired.setParams({
            "recordId": recordId,
        });
        
        eventFired.fire();
	}
})