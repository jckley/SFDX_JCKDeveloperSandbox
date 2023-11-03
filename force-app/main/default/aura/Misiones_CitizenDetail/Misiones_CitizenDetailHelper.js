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
                    console.log('celular: ' + objCitizenWrapper.misiones.MobilePhone);
                    console.log('email: ' + objCitizenWrapper.misiones.Email);

                    objComponent.set('v.citizenWrapper', objCitizenWrapper );

                    objComponent.set('v.mobile', objCitizenWrapper.misiones.MobilePhone );
                    objComponent.set('v.email', objCitizenWrapper.misiones.Email );
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
    },
    hideModals : function(objComponent) {
        this.hideModal(objComponent, 'divModalEdit');
    },
    hideModal : function(objComponent, strModalId) {
        var divModal = null;
        var divBackground = null;
                
        divModal = objComponent.find(strModalId);
        divBackground = objComponent.find('divBackground');
        
        if(divModal !== undefined && divModal !== null && divBackground !== undefined && divBackground !== null) {
            if($A.util.hasClass(divModal, 'slds-fade-in-open')) {
                $A.util.removeClass(divModal, 'slds-fade-in-open');
            }
            
            if($A.util.hasClass(divBackground, 'slds-backdrop_open')) {
                $A.util.removeClass(divBackground, 'slds-backdrop_open');
            }
            
            if(!$A.util.hasClass(divModal, 'slds-hide')) {
                $A.util.addClass(divModal, 'slds-hide');
            }
        }
    },
    showModal : function(objComponent, strModalId) {
        var divModal = null;
        var divBackground = null;
                
        divModal = objComponent.find(strModalId);
        divBackground = objComponent.find('divBackground');
        
        if(divModal !== undefined && divModal !== null && divBackground !== undefined && divBackground !== null) {
            if(!$A.util.hasClass(divModal, 'slds-fade-in-open')) {
                $A.util.addClass(divModal, 'slds-fade-in-open');
            }
            
            if(!$A.util.hasClass(divBackground, 'slds-backdrop_open')) {
                $A.util.addClass(divBackground, 'slds-backdrop_open');
            }
            
            if($A.util.hasClass(divModal, 'slds-hide')) {
                $A.util.removeClass(divModal, 'slds-hide');
            }
        }
    },
    saveCitizenSF : function(objComponent) {
        var objCitizenWrapper = null;
        var objWindows = null;

        var objControllerAction = null; 
        var strState = null;
        var strEmail = null;
        var strMobile = null;
        var strFijo = null;
        var objEvent = null;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');
        if(objCitizenWrapper.citizen.Id !== undefined && objCitizenWrapper.citizen.Id !== null && (objCitizenWrapper.citizen.Id.length === 15 || objCitizenWrapper.citizen.Id.length === 18)) {
            strEmail = objComponent.get('v.email');
            strMobile = objComponent.get('v.mobile');
            strFijo = "";

            objControllerAction = objComponent.get("c.saveCitizenInSalesforce");
            objControllerAction.setParams( { 
                'strCitizenId': objCitizenWrapper.citizen.Id,
                'strEmail' : strEmail,
                'strMobile' : strMobile,
                'strFijo' : strFijo
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {    
                    objCitizenWrapper.pilar360.phone = 'fsadfsa';
                    /*       
                    objEvent = $A.get("e.c:PRM_Cuidarnos_Edit_Completed");
                    objFiredEvent.setParams({
                        "email": strEmail,
                        "mobile": strMobile
                    });
                    objEvent.fire();                    
                    */
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    }
})