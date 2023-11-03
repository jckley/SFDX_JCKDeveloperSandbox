({
	doInit : function(component, event, helper) {
        var territoryId = component.get('v.recordId');
        helper.getTerritoryInfo(component, territoryId);
        helper.retrieveBaseUrl(component);
    },
    
     navigateTohierarchyView : function(component, event, helper) {
        var recordId = event.getParam("recordId");
        var adminLevel = event.getParam("adminLevel");
        var eventFired = $A.get("e.force:navigateToURL");
        eventFired.setParams({
            "url": '/territorio-administrativo/Territorio_Administrativo__c/Recent',
        });
        
        eventFired.fire();        
        eventFired.stopPropagation();
    }
})