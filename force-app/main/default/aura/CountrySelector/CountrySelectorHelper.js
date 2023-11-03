({
    retrieveTerritories : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var arrTerritories = null;
       
        objControllerAction = objComponent.get("c.retrieveTerritories"); 

        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                arrTerritories = objResponse.getReturnValue();
                
                objComponent.set('v.territories', arrTerritories);
                console.log('Citizen : ' + arrTerritories);
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
    },
    updateUserRoleInSF : function(objComponent, strTerritory) {
        var objControllerAction = null;
        var strState = null;
        var objToastEvent = null;      

        if(strTerritory !== undefined && strTerritory !== null && strTerritory.length > 0) {
            objControllerAction = objComponent.get("c.changeTerritory"); 
            objControllerAction.setParams({
                'strTerritory' : strTerritory
            })
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {
                    objToastEvent = $A.get("e.force:showToast");
                    objToastEvent.setParams({
                        "type" : "success",
                        "title": "Información",
                        "message": "El país ha sido actualizado : <b>" + strTerritory +  "</b>."
                    });
                    objToastEvent.fire();
                } else {
                    objToastEvent = $A.get("e.force:showToast");
                    objToastEvent.setParams({
                        "type" : "error",
                        "title": "Error",
                        "message": "El país no pudo ser actualizadosss"
                    });
                    objToastEvent.fire();
                }
            });
            
            $A.enqueueAction(objControllerAction); 
        }
	}
})