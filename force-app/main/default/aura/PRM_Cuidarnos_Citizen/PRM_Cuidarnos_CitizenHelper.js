({
    subscribeToEvents : function(objComponent) {
        objComponent.set('v.subscription', null);
        objComponent.set('v.notifications', []);

        const objPlatformEvent = objComponent.find('empApi');
        const errorHandler = function (objError) {
          console.error('Received error ', JSON.stringify(objError));
        };

        objPlatformEvent.onError($A.getCallback(errorHandler));
        this.subscribe(objComponent);
    },
    subscribe: function (objComponent) {
        const objPlatformEvent = objComponent.find('empApi');
        const strChannel = objComponent.get('v.channel');
        const intReplayId = -1;
        
        const receivedResponse = function (objMessage) {
            console.log('Event Received : ' + JSON.stringify(objMessage));
            
            this.onReceiveNotification(objComponent, objMessage);
        };
        objPlatformEvent.subscribe(strChannel, intReplayId, $A.getCallback(receivedResponse)).then(
            $A.getCallback(function (objSubscription) {
                console.log('Subscribed to channel ' + strChannel);
                component.set('v.subscription', objSubscription);
            })
        );
    },
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
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
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