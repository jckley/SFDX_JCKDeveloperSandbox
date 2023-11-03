({
    retrieveCitizenInfo : function(objComponent, strRecordId) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var objCitizenWrapperAux = null;
       
        if(strRecordId !== undefined && strRecordId !== null && (strRecordId.length === 15 || strRecordId.length === 18)) {
            objControllerAction = objComponent.get("c.retrieveInfoFromCitizenId"); 
            objControllerAction.setParams( {
                'strCitizenId': strRecordId
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {
                    objCitizenWrapper = objResponse.getReturnValue();
                    
                    objCitizenWrapperAux = objComponent.get('v.citizenWrapper');
                    objCitizenWrapperAux.cuidarnos.Triage = objCitizenWrapper.cuidarnos.Triage;
                    objCitizenWrapperAux.cuidarnos.Telemedico = objCitizenWrapper.cuidarnos.Telemedico;
                    objCitizenWrapperAux.cuidarnos.Muestra = objCitizenWrapper.cuidarnos.Muestra;
                    objCitizenWrapperAux.cuidarnos.Resultado = objCitizenWrapper.cuidarnos.Resultado;
                    objCitizenWrapperAux.cuidarnos.Notificacion = objCitizenWrapper.cuidarnos.Notificacion;
                    objCitizenWrapperAux.cuidarnos.Archivado = objCitizenWrapper.cuidarnos.Archivado;
                    objCitizenWrapperAux.cuidarnos.confirmdate = objCitizenWrapper.cuidarnos.confirmdate;
                    objCitizenWrapperAux.cuidarnos.covid.Cuidarnos_Muestra_Result__c = objCitizenWrapper.cuidarnos.covid.Cuidarnos_Muestra_Result__c;

                    objComponent.set('v.citizenWrapper', objCitizenWrapperAux);
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    },
    showModal : function(objComponent, strModalId) {
        var divModal = null;
        var divBackground = null;
                
        divModal = objComponent.find(strModalId);
        divBackground = objComponent.find('divHistorialBackground');
        
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
        this.hideModal(objComponent, 'divModalHistorial');
    },
    hideModal : function(objComponent, strModalId) {
        var divModal = null;
        var divBackground = null;
                
        divModal = objComponent.find(strModalId);
        divBackground = objComponent.find('divHistorialBackground');
        
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
    }
})