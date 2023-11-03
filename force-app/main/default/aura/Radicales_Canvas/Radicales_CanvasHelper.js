({
    retrieveCitizenInfo : function(objComponent, strRecordId) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
       
        if(strRecordId !== undefined && strRecordId !== null && (strRecordId.length === 15 || strRecordId.length === 18)) {
            objControllerAction = objComponent.get("c.retrieveInfoFromCitizenId"); 
            objControllerAction.setParams( {
                'strCitizenId': strRecordId
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {
                    objCitizenWrapper = objResponse.getReturnValue();
                    
                    console.log(objCitizenWrapper)
                    objComponent.set('v.citizenWrapper', objCitizenWrapper );
                    objComponent.set('v.rendered', true );
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
        }
	}
})