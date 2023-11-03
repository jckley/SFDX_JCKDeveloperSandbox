({
	viewTerritory : function(component, event, helper) {
        var recordId = event.currentTarget.id;
        console.log(recordId);
        
        var eventFired = $A.get("e.force:navigateToSObject");
        eventFired.setParams({
            "recordId": recordId,
        });
        
        eventFired.fire();
	}
})