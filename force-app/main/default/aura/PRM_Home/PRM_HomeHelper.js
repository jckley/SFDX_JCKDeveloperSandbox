({
    getTerritoryInfo : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objTerritoryWrapper = null;
        
        objControllerAction = objComponent.get("c.getRootTerritory");
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                objTerritoryWrapper = objResponse.getReturnValue();
                
                objComponent.set('v.territoryWrapper', objTerritoryWrapper);
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
    }
})