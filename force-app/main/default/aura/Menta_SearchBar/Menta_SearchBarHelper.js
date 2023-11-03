({	placeholder : '',
	retrieveResults : function(objComponent, strSearch) {
        var objControllerAction = null;
        var strState = null;
        var arrResults = null;
        var objThat = this;         
        
        objControllerAction = objComponent.get("c.searchForNames"); 
        objControllerAction.setParams( {
            'strSearch': strSearch
        });
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            
            if (objComponent.isValid() && strState === "SUCCESS") {
                arrResults = objResponse.getReturnValue();
                
                objComponent.set('v.results', JSON.parse(arrResults));
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
        
	},
    clearResults : function(objComponent, strSearch) { 
        objComponent.set('v.results', null);
    }
})