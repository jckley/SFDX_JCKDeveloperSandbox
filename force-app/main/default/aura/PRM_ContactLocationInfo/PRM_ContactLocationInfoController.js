({
	viewTerritory : function(objComponent, objEvent, objHelper) {
        var objEventFired = null;
        var strRecordId = null;

        strRecordId = objEvent.currentTarget.id;        
        objEventFired = $A.get("e.force:navigateToSObject");
        objEventFired.setParams({
            "recordId": strRecordId,
        });
        
        objEventFired.fire();
	}
})