({
    navigateToRecord : function(objComponent, objEvent, objHelper) {
        var objEventFired = null;
        var strRecordId = null;
        
        strRecordId = objComponent.get("v.linkToRecordId");
        if(strRecordId !== '#') {
            if(strRecordId.indexOf('/') >= 0) {
                objEventFired = $A.get("e.force:navigateToURL");
                objEventFired.setParams({
                    "url": strRecordId
                });
            } else {
                objEventFired = $A.get("e.force:navigateToSObject");
                objEventFired.setParams({
                    "recordId": strRecordId
                });
            }
            objEventFired.fire();        
            objEventFired.stopPropagation();
        }
    },
    
    fireHierarchyEvent : function(objComponent, objEvent, objHelper) {
        var objEventFired = null;
        var strRecordId = null;
        var intAdminLevel = null;
        
        strRecordId = objComponent.get("v.territoryWrapper.territory.Id");
        intAdminLevel = objComponent.get("v.territoryWrapper.territory.Nivel_Administrativo__c");
        
        objEventFired = objComponent.getEvent("mainHeaderClickEvent");
        objEventFired.setParams({
            "recordId" : strRecordId,
            "adminLevel" : intAdminLevel
        });
		objEventFired.fire();
    }
})