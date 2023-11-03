({
	getTerritoryInfo : function(component, recordId) {
        var action = null;
        var state = null;
        var territoryWrapper = null;
       
        if(recordId !== undefined && recordId !== null && (recordId.length === 15 || recordId.length === 18)) {
            action = component.get("c.getTerritoryById2");
            action.setParams({
            	"territoryId": component.get("v.recordId")
            });
            
            action.setCallback(this, function(response) {
                state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    territoryWrapper = response.getReturnValue();
                    
                    component.set('v.territoryWrapper', territoryWrapper);
                } 
            });
            
            $A.enqueueAction(action); 
        }
	},
    
    retrieveBaseUrl : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objSFDomains = null;
       
        objControllerAction = objComponent.get("c.retrieveSalesforceDomains"); 
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                objSFDomains = objResponse.getReturnValue();
                
                objComponent.set('v.lexHost', objSFDomains.LEX);
                objComponent.set('v.vfHost', objSFDomains.VF);
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
        
	}
})