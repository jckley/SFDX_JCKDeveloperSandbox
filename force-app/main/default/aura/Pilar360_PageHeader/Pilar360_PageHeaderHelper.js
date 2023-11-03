({
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
        var objFiredEvent = null;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');
        if(objCitizenWrapper.citizen.Id !== undefined && objCitizenWrapper.citizen.Id !== null && (objCitizenWrapper.citizen.Id.length === 15 || objCitizenWrapper.citizen.Id.length === 18)) {
            strEmail = objComponent.get('v.email');
            strMobile = objComponent.get('v.mobile');
            strFijo = objComponent.get('v.fijo');

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
                    
                    objFiredEvent = $A.get("e.c:PRM_Cuidarnos_Edit_Completed");
                    objFiredEvent.setParams({
                        "email": strEmail,
                        "mobile": strMobile,
                        "fijo": strFijo,
                    });
                    objFiredEvent.fire();                    
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    }
})