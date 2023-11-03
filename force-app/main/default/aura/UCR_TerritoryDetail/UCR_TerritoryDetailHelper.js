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
	}
})