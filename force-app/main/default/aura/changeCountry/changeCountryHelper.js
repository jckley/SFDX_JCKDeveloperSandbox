({
    retrieveAvailableCountries : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var arrCountries = null;
       
        objControllerAction = objComponent.get("c.retrieveCountries"); 
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                arrCountries = objResponse.getReturnValue();
                
                objComponent.set('v.arrCountries', arrCountries);
                objComponent.set('v.hasCountries', (arrCountries.length > 0));
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
    
    },
    changeCountry : function(objComponent,strGroupName) { 
        var objControllerAction = null;
        var strState = null;
        var objToastEvent = null;

        objControllerAction = objComponent.get("c.changeCountryInSF"); 
        objControllerAction.setParams( {
            'strGroupName': strGroupName
        });
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                objToastEvent = $A.get("e.force:showToast");
                objToastEvent.setParams({
                    "type" : "success",
                    "title": "Información",
                    "message": "El país ha sido actualizado : <b>" + objResponse.getReturnValue() +  "</b>."
                });
                objToastEvent.fire();
            } else {
                objToastEvent = $A.get("e.force:showToast");
                objToastEvent.setParams({
                    "type" : "error",
                    "title": "Información",
                    "message": objResponse.getError()[0].message
                });
                objToastEvent.fire();
            }

            
            $A.get("e.force:closeQuickAction").fire();
        });
        
        $A.enqueueAction(objControllerAction);
    }
})