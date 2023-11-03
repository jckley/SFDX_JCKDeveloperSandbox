({
    saveUserObservations : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var strObservations = null;
        var objCitizenWrapper = null;
        var objToastEvent = null;
        var strCitizenId = null;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');
        if(objCitizenWrapper !== undefined && objCitizenWrapper !== null && objCitizenWrapper.citizen !== undefined && objCitizenWrapper.citizen !== null ) {
            strCitizenId = objCitizenWrapper.citizen.Id;

            if(strCitizenId !== undefined && strCitizenId !== null && (strCitizenId.length === 15 || strCitizenId.length === 18)) {
                strObservations = objComponent.get('v.observations');
                objComponent.set('v.observations', '');
                if(strObservations !== undefined && strObservations !== null && strObservations.length > 0) {
                    objControllerAction = objComponent.get("c.saveUserObservationsInSalesforce"); 
                    objControllerAction.setParams( {
                        'strCitizenId': strCitizenId,
                        'strObservations': strObservations
                    });
                    
                    objControllerAction.setCallback(this, function(objResponse) {
                        strState = objResponse.getState();
                        objToastEvent = $A.get("e.force:showToast");

                        if (objComponent.isValid() && strState === "SUCCESS") {                    
                            objToastEvent.setParams({
                                "title": "Información",
                                "message": "Las observaciones se han guardado exitosamente."
                            });
                            objComponent.set('v.arrObservation', objResponse.getReturnValue());
                        } else {
                            objToastEvent.setParams({
                                "title": "Error",
                                "message": "Ha ocurrido un error al intentar guardar sus observaciones."
                            });
                        }
                        objToastEvent.fire();
                    });
                    
                    $A.enqueueAction(objControllerAction); 
                }
            }
        } 
	},
})