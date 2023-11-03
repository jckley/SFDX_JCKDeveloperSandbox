({
	retrieveCitizenInfo : function(objComponent, strRecordId) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
       
        if(strRecordId !== undefined && strRecordId !== null && (strRecordId.length === 15 || strRecordId.length === 18)) {
            objControllerAction = objComponent.get("c.retrieveFromCitizenId"); 
            objControllerAction.setParams( {
                'objCitizenId': strRecordId
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {
                    objCitizenWrapper = objResponse.getReturnValue();
                    
                    objComponent.set('v.citizenWrapper', objCitizenWrapper);
                    console.log('Citizen : ' + objCitizenWrapper);
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
        }
	},
    retrieveUserPermissions : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objUserPermissions = null;
       
        objControllerAction = objComponent.get("c.retrieveLoggedUserPermissions"); 
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                objUserPermissions = objResponse.getReturnValue();
                
                objComponent.set('v.permissions', objUserPermissions);
                
                console.log('User permissions : ' + objUserPermissions);
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
	},
    /*retrieveBaseUrl : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var strSalesforceBaseUrl = null;
       
        objControllerAction = objComponent.get("c.retrieveSalesforceBaseUrl"); 
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                strSalesforceBaseUrl = objResponse.getReturnValue();
                
                objComponent.set('v.baseUrl', strSalesforceBaseUrl);
                console.log('baseUrl : ' + strSalesforceBaseUrl);
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
        
	}*/
})