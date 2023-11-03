({
	initializeComponent : function(objComponent, objEvent, objHelper) {
		objHelper.retrieveContactLayout(objComponent);
	},
    handleSaveRecord: function(objComponent, objEvent, objHelper) {
        var objLDS = null;
        var objFiredEvent = null;
        
        objLDS = new objComponent.find("recordEditor");
        
        objLDS.saveRecord($A.getCallback(function(objSaveResult) {
            if (objSaveResult.state === "SUCCESS" || objSaveResult.state === "DRAFT") {
                objFiredEvent = $A.get('e.c:ContactUpdatedEvent');
                objFiredEvent.fire();
                
                objHelper.hideModal(objComponent);
            } else if (objSaveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (objSaveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + JSON.stringify(objSaveResult.error));
            } else {
                console.log('Unknown problem, state: ' + objSaveResult.state + ', error: ' + JSON.stringify(objSaveResult.error));
            }
        }));
    },
    loadModal : function(objComponent, objEvent, objHelper) {
         objHelper.showModal(objComponent);
    }, 
    cancelSave : function(objComponent, objEvent, objHelper) {
        objHelper.hideModal(objComponent);
    }
})