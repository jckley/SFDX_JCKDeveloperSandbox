({
    navigateToRecord : function(component, event, helper) {
        var eventFired = null;
        var recordId = null;
        recordId = component.get("v.linkToRecordId");
        if(recordId != '#') {
            if(recordId.indexOf('/') >= 0) {
                eventFired = $A.get("e.force:navigateToURL");
                eventFired.setParams({
                    "url": recordId
                });
            } else {
                eventFired = $A.get("e.force:navigateToSObject");
                eventFired.setParams({
                    "recordId": recordId
                });
            }
            eventFired.fire();        
            eventFired.stopPropagation();
        }
    },
    
    fireHierarchyEvent : function(component, event, helper) {
        var eventFired = null;
        var recordId = null;
        var adminLevel = null;
        recordId = component.get("v.territoryWrapper.territory.Id");
        adminLevel = component.get("v.territoryWrapper.territory.Nivel_Administrativo__c");
        
        eventFired = component.getEvent("mainHeaderClickEvent");
        eventFired.setParams({
            "recordId" : recordId,
            "adminLevel" : adminLevel
        });
		eventFired.fire();

    }
})