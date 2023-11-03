({
    DEBUG : false,
    retrieveConnectedPeople : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var arrConnectedPeople = null;
        var objThat = this;
    	var intPeopleCount = null;
        
        intPeopleCount = objComponent.get('v.peopleCount'); 
    
        this.DEBUG && console.log('[AdFi_ConnectedPeopleHelper]retrieveConnectedPeople ->');
        
        objControllerAction = objComponent.get("c.retrieveRandomConnectedPeople"); 
        objControllerAction.setParams( {
            'intCitizensToRetrieve': intPeopleCount
        });
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            
            if (objComponent.isValid() && strState === "SUCCESS") {
                arrConnectedPeople = objResponse.getReturnValue();
                objComponent.set('v.connectedPeople', arrConnectedPeople);                
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
        
        this.DEBUG && console.log('[AdFi_ConnectedPeopleHelper]retrieveConnectedPeople <-');
    },
})