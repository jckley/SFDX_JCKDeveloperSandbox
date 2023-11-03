({
    updateStatus : function(objComponent, strStatus) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var strResult = null;
       
        objCitizenWrapper = objComponent.get('v.citizenWrapper');

        if(objCitizenWrapper !== undefined && objCitizenWrapper !== null && strStatus !== undefined && strStatus !== null && strStatus,length > 0) {
            objControllerAction = objComponent.get("c.updateStatusInSalesforce"); 
            objControllerAction.setParams( {
                'strCitizenId': objCitizenWrapper.citizen.Id,
                'strStatus' : strStatus 
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {                    
                    strResult = objResponse.getReturnValue();

                    objComponent.set('v.status' , strStatus); 
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
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
    hideModals : function(objComponent) {
        this.hideModal(objComponent, 'divModalNotify');        
    },
    notify : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var strResult = null;
        var strUrl = null;
       
        objCitizenWrapper = objComponent.get('v.citizenWrapper');

        if(objCitizenWrapper !== undefined && objCitizenWrapper !== null) {
            objControllerAction = objComponent.get("c.notifyUserEmail"); 
            strUrl = objCitizenWrapper.cuidarnos.pdf_url;
            
            if(strUrl !== undefined && strUrl !== null && strUrl.length > 0) {
                objControllerAction.setParams( {
                    'strUrl': strUrl, 
                    'strCitizenId': objCitizenWrapper.citizen.Id
                });
                
                objControllerAction.setCallback(this, function(objResponse) {
                    strState = objResponse.getState();
                    if (objComponent.isValid() && strState === "SUCCESS") {                    
                        this.showSuccess(objComponent, 'La operación se ha realizado exitosamente');
                    } else {
                        this.showError(objComponent, objResponse);
                    }
                });
                
                $A.enqueueAction(objControllerAction); 
            } else {
                this.showError(objComponent, null);
            }
        }
    },   
    showError : function(objComponent, objError) {
        var strMessage = null;

        if(objError !== undefined && objError !== null && objError.getError() !== undefined && objError.getError() !== null && objError.getError().length > 0) {
            strMessage = objError.getError()[0].message
        } else {
            strMessage = 'Ha ocurrido un error. Por favor refrescque la página.'
        }

        objComponent.find('notifLib').showNotice({
            "variant": "error",
            "header": "Advertencia!",
            "message": strMessage,
            closeCallback: function() {
               // $A.get('e.force:refreshView').fire();
            }
        });
        
    },
    showSuccess : function(objComponent, strMessage) {
        objComponent.find('notifLib').showNotice({
            "variant": "sucess",
            "header": "Advertencia!",
            "message": strMessage,
            closeCallback: function() {
               // $A.get('e.force:refreshView').fire();
            }
        });
        
    } 
})