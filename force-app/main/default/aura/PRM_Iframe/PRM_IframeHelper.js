({
    retrieveIframe : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var strUrl = null;
       
        objControllerAction = objComponent.get("c.retrieveIframeUrl"); 

        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                strUrl = objResponse.getReturnValue();
                
                objComponent.set('v.iframeurl', strUrl );
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
	}
})