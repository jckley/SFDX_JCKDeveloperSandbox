({
    redirectToUrl : function(strUrl) { 
        var objUrlEvent = null;
        
        if(strUrl !== undefined && strUrl !== null && strUrl.length > 0 ) {
            objUrlEvent = $A.get("e.force:navigateToURL");

            objUrlEvent.setParams({
                'url': strUrl
            });
            objUrlEvent.fire();
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
    showPrintTagModal : function(objComponent) {
        var strLocation = null;
        var strTagMode = null;
        var cboLocation = null;
        var strTipoEstudio = null;
        var objCitizenWrapper = null;
        var strUrl = null;
        var strReprintUrl = null;
        var BOOL_SHOW_IN_POPUP = true;
        var strObraSocial = null;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');

        strLocation = objComponent.find('cboLocation').get('v.value');
        strTagMode = objComponent.get('v.tag_mode');
        strTipoEstudio = objComponent.find('cboTipoEstudio').get('v.value');
        strObraSocial = objComponent.find('cboObraSocial').get('v.value');

        if(strLocation !== undefined && strLocation !== null && strLocation.length > 0) {
            this.validateAction(objComponent, 'Muestra', this.showPrintMuestra,  [objComponent, this, objCitizenWrapper, strTagMode, strLocation,strTipoEstudio, strObraSocial ]);
        } else {
            strReprintUrl = objCitizenWrapper.cuidarnos.etiquetaurl;
            strReprintUrl += '&new=0';

            if(BOOL_SHOW_IN_POPUP) {
                this.redirectToUrl(strReprintUrl);
                this.hideModals(objComponent);
            } else {
                document.getElementById('location_container').style.display = 'none';
                document.getElementById('tag_container').style.display = '';
                
                this.showModal(objComponent, 'divModalEtiqueta');
            }
        }
    },
    showPrintMuestra : function(arrParameters) {
        var objComponent = null;   
        var objHelper = null;
        var objCitizenWrapper = null;
        var strTagMode = null;
        var strReprintUrl = null;
        var strLocation = null;
        var strUrl = null;
        var strTipoEstudio = null;
        var strObraSocial = null;  
        
        objComponent = arrParameters[0];
        objHelper = arrParameters[1];
        objCitizenWrapper = arrParameters[2];
        strTagMode = arrParameters[3];
        strLocation = arrParameters[4];
        strTipoEstudio = arrParameters[5];
        strObraSocial =  arrParameters[6];

        strUrl = objCitizenWrapper.cuidarnos.etiquetaurl;
        strReprintUrl = objCitizenWrapper.cuidarnos.etiquetaurl;

        if(strTagMode !== undefined && strTagMode !== null && strTagMode.length > 0) {
            strUrl += '&new=' + strTagMode;
        }

        strReprintUrl += '&new=0';

        if(strLocation !== undefined && strLocation !== null && strLocation.length > 0) {
            strUrl += '&id='+ strLocation
            strReprintUrl += '&id='+ strLocation
        }
        
        if(strTipoEstudio !== undefined && strTipoEstudio !== null && strTipoEstudio.length > 0) {
            strUrl += '&tipo='+ strTipoEstudio
            strReprintUrl += '&tipo='+ strTipoEstudio
        }

        if(strObraSocial !== undefined && strObraSocial !== null && strObraSocial.length > 0) {
            strUrl += '&os='+ strObraSocial
            strReprintUrl += '&os='+ strObraSocial
        } else {
            strUrl += '&os=0'
            strReprintUrl += '&os=0'
        }

        objHelper.redirectToUrl(strUrl);
        objHelper.hideModals(objComponent);
        objHelper.updateStatusMuestra(objComponent, 'Muestra', strLocation, strTipoEstudio);
    },
    retrieveMuestras : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var arrMuestras = null;
       
        objCitizenWrapper = objComponent.get('v.citizenWrapper');

        if(objCitizenWrapper !== undefined && objCitizenWrapper !== null) {
            objControllerAction = objComponent.get("c.retrieveMuestrasFromExternalSystem"); 
            objControllerAction.setParams( {
                'strCitizenId': objCitizenWrapper.citizen.Id
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                arrMuestras = [];
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {                    
                    arrMuestras = objResponse.getReturnValue();
                }
                /*arrMuestras = [];
                arrMuestras.push( { "Id" : 1} );
                arrMuestras.push( { "Id" : 2} );
                */
                objComponent.set('v.arrMuestras' , arrMuestras)
                objComponent.find("cboMuestraDetectables").set("v.options", arrMuestras);
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    },
    hideModals : function(objComponent) {
        var divModalContentStep1 = objComponent.find('divModalDetectContentStep1');
        var divModalContentStep2 = objComponent.find('divModalDetectContentStep2');
        var divModalNoDetectContentStep1 = objComponent.find('divModalNoDetectContentStep1');
        var divModalNoDetectContentStep2 = objComponent.find('divModalNoDetectContentStep2');
        var divModalInvalidContentStep1 = objComponent.find('divModalInvalidContentStep1');
        var divModalInvalidContentStep2 = objComponent.find('divModalInvalidContentStep2');
        var divModalContentStep1 = objComponent.find('divModalRiskContentStep1');
        var divModalContentStep2 = objComponent.find('divModalRiskContentStep2');

        this.hideModal(objComponent, 'divModalSuspect');
        this.hideModal(objComponent, 'divModalConfirm');
        this.hideModal(objComponent, 'divModalDiscard');
        this.hideModal(objComponent, 'divModalEtiqueta');
        this.hideModal(objComponent, 'divModalInvalid');
        this.hideModal(objComponent, 'divModalEdit');
        this.hideModal(objComponent, 'divModalTurnos');
        this.hideModal(objComponent, 'divModalDetect');
        this.hideModal(objComponent, 'divModalNoDetect');
        this.hideModal(objComponent, 'divModalNotify');      
        this.hideModal(objComponent, 'divModalIVR');      
        this.hideModal(objComponent, 'divModalEtiquetaPilar');  
        this.hideModal(objComponent, 'divModalArchive');  
        this.hideModal(objComponent, 'divModalHistorial');  
        this.hideModal(objComponent, 'divModalFollow');  
        this.hideModal(objComponent, 'divModalRisk');  

        $A.util.addClass(divModalContentStep2, 'slds-hide');                
        $A.util.addClass(divModalContentStep2, 'slds-hide');
        $A.util.addClass(divModalNoDetectContentStep2, 'slds-hide');
        $A.util.addClass(divModalInvalidContentStep2, 'slds-hide');

        $A.util.removeClass(divModalContentStep1, 'slds-hide');
        $A.util.removeClass(divModalContentStep1, 'slds-hide');
        $A.util.removeClass(divModalNoDetectContentStep1, 'slds-hide');
        $A.util.removeClass(divModalInvalidContentStep1, 'slds-hide');
    },
    notify : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var strResult = null;
        var strUrl = null;
        var objThat = this;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');

        if(objCitizenWrapper !== undefined && objCitizenWrapper !== null) {
            objControllerAction = objComponent.get("c.notifyUser"); 

            objControllerAction.setParams( {
                'strUrl': '', 
                'strCitizenId': objCitizenWrapper.citizen.Id
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {                    
                    strResult = objResponse.getReturnValue();

                    objComponent.set('v.status' , strResult); 
                    objThat.refreshStatus(objComponent, objHelper, objCitizenWrapper.citizen.Id);
                } else {
                    this.showError(objComponent, objResponse);
                }
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    },    
    retrieveHistory : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var arrData = null;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');

        if(objCitizenWrapper !== undefined && objCitizenWrapper !== null) {
            objControllerAction = objComponent.get("c.retrieveHistoryInSalesforce"); 

            objControllerAction.setParams( {
                'strCitizenId': objCitizenWrapper.citizen.Id
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {                    
                    arrData = objResponse.getReturnValue();
                    
                    objComponent.set('v.arrData' , arrData); 
                } else {
                    this.showError(objComponent, objResponse);
                }
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    },    

    makeCall : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var strResult = null;
        var strSourcePhone = null;
        var strDestinationPhone = null;
        var boolIsMobile = null;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');
        strSourcePhone = objComponent.get('v.source_phone');
        strDestinationPhone = objComponent.get('v.destination_phone');
        strDestinationPhone = objComponent.find('cboDestination').get('v.value');
        
        window.localStorage.setItem('source_phone', strSourcePhone);
        
        if(objCitizenWrapper !== undefined && objCitizenWrapper !== null && strSourcePhone !== undefined && strSourcePhone !== null && strDestinationPhone !== undefined && strDestinationPhone !== null) {            
            boolIsMobile = ('Celular' === strDestinationPhone);
            strDestinationPhone = (boolIsMobile)?objCitizenWrapper.cuidarnos.mobile_phone:objCitizenWrapper.cuidarnos.phone;
             
            objControllerAction = objComponent.get("c.makeCallIVR"); 
            objControllerAction.setParams( {
                'strCitizenId': objCitizenWrapper.citizen.Id,
                'strSourcePhone': strSourcePhone,
                'strDestinationPhone': strDestinationPhone,
                'boolIsMobile': boolIsMobile
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {                    
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
        }
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
    updateStatus : function(objComponent, strStatus) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var strResult = null;
        var objThat = this;

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

                    objComponent.set('v.status' , strResult);
                    objThat.refreshStatus(objComponent, objThat,objCitizenWrapper.citizen.Id);
                } else {
                    this.showError(objComponent, objResponse);
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    },
    updateRisk : function(objComponent, strRisk) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var strResult = null;
        var objThat = this;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');

        if(objCitizenWrapper !== undefined && objCitizenWrapper !== null && strRisk !== undefined && strRisk !== null && strRisk.length > 0) {
            objControllerAction = objComponent.get("c.updateRiskInSalesforce"); 
            objControllerAction.setParams( {
                'strCitizenId': objCitizenWrapper.citizen.Id,
                'strRisk' : strRisk
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {                    
                    //objThat.showMessage(objComponent, 'La operación se ha realizado exitosamente' );

                    objCitizenWrapper.cuidarnos.covid.Riesgo__c = strRisk;
                    objComponent.set('v.citizenWrapper', objCitizenWrapper);
                } else {
                    this.showError(objComponent, objResponse);
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    },
    updateStatusArchive : function(objComponent, strStatus, strEmail, boolDarAlta ) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var strResult = null;
        var objThat = this;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');

        if(objCitizenWrapper !== undefined && objCitizenWrapper !== null && strStatus !== undefined && strStatus !== null && strStatus.length > 0) {
            objControllerAction = objComponent.get("c.updateStatusArchiveInSalesforce"); 
            objControllerAction.setParams( {
                'strCitizenId': objCitizenWrapper.citizen.Id,
                'strStatus' : strStatus,
                'strEmail' : strEmail,
                'boolDarAlta' : boolDarAlta
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {                    
                    strResult = objResponse.getReturnValue();

                    objComponent.set('v.status' , strStatus); 
                    if(boolDarAlta) {
                        objCitizenWrapper.cuidarnos.covid.Estado_Epidemiologico__c = 'Alta';
                        objComponent.set('v.citizenWrapper',objCitizenWrapper);
                    }

                    objThat.refreshStatus(objComponent, objThat, objCitizenWrapper.citizen.Id);
                } else {
                    this.showError(objComponent, objResponse);
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    },
    updateStatusMuestra : function(objComponent, strStatus, strLocation, strTipoEstudio) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var strResult = null;
        var objThat = this;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');

        if(objCitizenWrapper !== undefined && objCitizenWrapper !== null && strStatus !== undefined && strStatus !== null && strStatus.length > 0) {
            objControllerAction = objComponent.get("c.updateStatusMuestraInSalesforce"); 
            objControllerAction.setParams( {
                'strCitizenId': objCitizenWrapper.citizen.Id,
                'strStatus' : strStatus,
                'strLocation' : strLocation,
                'strTipoEstudio' : strTipoEstudio
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {                    
                    strResult = objResponse.getReturnValue();

                    objComponent.set('v.status' , strStatus); 
                    objThat.refreshStatus(objComponent, objThat,objCitizenWrapper.citizen.Id);
                } else {
                    this.showError(objComponent, objResponse);
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    },
    updateResultadoMuestra : function(objComponent, strStatus, strLab, intLabelId) {
        var objControllerAction = null;
        var strState = null;
        var objCitizenWrapper = null;
        var strResult = null;
        var objThat = this;
        var strHashEtiqueta = null;
        var arrLabels = null;
        objCitizenWrapper = objComponent.get('v.citizenWrapper');
 
        if(  (intLabelId !== undefined && intLabelId !== null && intLabelId.toString().length > 0) ) {
            if( strStatus === 'Inválido' || (strLab !== undefined && strLab !== null && strLab.toString().length > 0 ) ) {
                if(objCitizenWrapper !== undefined && objCitizenWrapper !== null && strStatus !== undefined && strStatus !== null && strStatus.length > 0) {
                    arrLabels = objComponent.get('v.arrMuestras');
                    strHashEtiqueta = '';
                    for(var intIndex = 0; intIndex < arrLabels.length; intIndex++) {
                        if(arrLabels[intIndex].Id == intLabelId) {
                            strHashEtiqueta = arrLabels[intIndex].HashEtiqueta;
                            break;
                        }    
                    }
                    
                    objControllerAction = objComponent.get("c.updateResultadoMuestraInSalesforce"); 
                    objControllerAction.setParams( {
                        'strCitizenId': objCitizenWrapper.citizen.Id,
                        'strStatus' : strStatus,
                        'strLab' : strLab,
                        'intLabelId' : intLabelId,
                        'strHashEtiqueta' : strHashEtiqueta
                    });

                    objControllerAction.setCallback(this, function(objResponse) {
                        strState = objResponse.getState();
                        if (objComponent.isValid() && strState === "SUCCESS") {                    
                            strResult = objResponse.getReturnValue();

                            objComponent.set('v.status' , strStatus); 
                            objThat.refreshStatus(objComponent, objThat,objCitizenWrapper.citizen.Id);
                        } else {
                            this.showError(objComponent, objResponse);
                        } 
                    });
                    
                    $A.enqueueAction(objControllerAction); 
                }
            } else {
                objComponent.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Advertencia!",
                    "message": 'Debe seleccionar un laboratorio',
                    closeCallback: function() {
                       // $A.get('e.force:refreshView').fire();
                    }
                });
            }
        } else {
            objComponent.find('notifLib').showNotice({
                "variant": "error",
                "header": "Advertencia!",
                "message": 'Debe seleccionar una muestra',
                closeCallback: function() {
                   // $A.get('e.force:refreshView').fire();
                }
            });
        }
    },
    processSuspect : function(objComponent) {
        var boolDetectOnly = false;
        var boolSuspectOnly = false;
        var objCitizenWrapper = null;
        var objThat = this;
       // boolDetectOnly = document.getElementById('chkMarkConfirm').checked;
        boolSuspectOnly = document.getElementById('chkMarkSuspect').checked;

        if(boolDetectOnly == true) {
            this.updateStatus(objComponent, 'Detectable_Confirmado');
        } else if(boolSuspectOnly == true) {
            this.updateStatus(objComponent, 'Sospechoso');
        } else {
            objCitizenWrapper = objComponent.get('v.citizenWrapper');

            objComponent.set('v.status' , 'Sospechoso');
            
            //this.updateStatus(objComponent, 'Sospechoso');
            this.markCitizen(objComponent,objCitizenWrapper.citizen.Id, 'Sospechoso');
        }

    },
    processFollow : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objThat = this;
        var strCitizenId = null;
        var objCitizenWrapper = null;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');
        strCitizenId = objCitizenWrapper.citizen.Id;

        if(strCitizenId !== undefined && strCitizenId !== null && (strCitizenId.length === 15 || strCitizenId.length === 18)) {
            objControllerAction = objComponent.get("c.processFollowInSalesforce");
            objControllerAction.setParams( {
                'strCitizenId': strCitizenId      
             });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {           
                    console.log('SUCCESS')   
                    objThat.showMessage(objComponent, 'La operación se ha realizado exitosamente' );  
                } else {
                    objThat.showError(objComponent, objResponse);
                }  
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    

    },
    markCitizen : function(objComponent, strCitizenId, strStatus) {
        var objControllerAction = null;
        var strState = null;
        var objThat = this;
        
        if(strCitizenId !== undefined && strCitizenId !== null && (strCitizenId.length === 15 || strCitizenId.length === 18)) {
            objControllerAction = objComponent.get("c.markCitizenInSalesforce");
            objControllerAction.setParams( {
                'strCitizenId': strCitizenId,
                'strStatus' : strStatus           
             });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {           
                    console.log('SUCCESS')     
                    objThat.refreshStatus(objComponent, objThat,strCitizenId);
                } else {
                    objThat.showError(objComponent, objResponse);
                }  
            });
            
            $A.enqueueAction(objControllerAction); 
        }
    },
    printTag : function(objComponent) {
        var strReprintUrl = null;

        strReprintUrl =  objComponent.get('v.reprinturl');

        this.validateAction(objComponent, 'Muestra', this.showPrintTag,  [ strReprintUrl ]);
    },
    showPrintTag : function(arrParameters) {
        window.open(arrParameters[0]);        
    },
    redirectToTriage : function(arrParamters) {
        var strUrl = null;
        var objCitizenWrapper = null;

        objCitizenWrapper = arrParamters[0].get('v.citizenWrapper');
        
        if(objCitizenWrapper.cuidarnos.linkTriage !== undefined && objCitizenWrapper.cuidarnos.linkTriage !== null) {
            strUrl = objCitizenWrapper.cuidarnos.linkTriage;
        } else {
            if(objCitizenWrapper.cuidarnos.usuario_pilar) {
                strUrl = 'https://triage.municipiopilar.app/?guid=';
            } else {
                strUrl = 'https://cuidarnos.app/?g=';
            }

            if(objCitizenWrapper !== undefined && objCitizenWrapper !== null) {
                strUrl += objCitizenWrapper.citizen.guid__c;
            } 
        }

        arrParamters[1].redirectToUrl(strUrl);
    },
    validateAction : function(objComponent, strStatus, fcCallback, arrParamters) {
        var objCitizenWrapper = null;
        var objControllerAction = null;
        var strState = null;
        var objThat = this;

        objCitizenWrapper = objComponent.get('v.citizenWrapper');
        if(objCitizenWrapper.citizen.Id !== undefined && objCitizenWrapper.citizen.Id !== null && (objCitizenWrapper.citizen.Id.length === 15 || objCitizenWrapper.citizen.Id.length === 18)) {
            objControllerAction = objComponent.get("c.validateAction");
            objControllerAction.setParams( {
                'strCitizenId': objCitizenWrapper.citizen.Id,
                'strStatus' : strStatus
            });
            
            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {           
                    fcCallback(arrParamters);
                } else {
                    objThat.hideModals(objComponent);
                    objThat.showError(objComponent, objResponse);
                }
            });
            
            $A.enqueueAction(objControllerAction); 
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
                    objEvent = $A.get("e.c:PRM_Cuidarnos_Edit_Completed");
                    objFiredEvent.setParams({
                        "email": strEmail,
                        "mobile": strMobile
                    });
                    objEvent.fire();                    
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
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
    showMessage : function(objComponent, strMessage) {
        objComponent.find('notifLib').showNotice({
            "variant": "warning",
            "header": "Advertencia!",
            "message": strMessage,
            closeCallback: function() {
               // $A.get('e.force:refreshView').fire();
            }
        });
        
    },
    refreshStatus : function(objComponent, objHelper, strRecordId) {
        var objFiredEvent = null;

        objHelper.retrieveCitizenInfo(objComponent, strRecordId);
        /*
        objFiredEvent = $A.get("e.c:PRM_Cuidarnos_Refresh_Historial");
        objFiredEvent.fire(); 
        */

    } 
    ,
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
    initializeColumns : function(objComponent) {
        var arrColumns = [
            {
                label: 'Usuario',
                fieldName: 'User',
                type: 'text'
            },
            {
                label: 'Fecha',
                fieldName: 'Created',
                type: 'text'
            },
            {
                label: 'Estado anterior',
                fieldName: 'OldStatus',
                type: 'text'
            },
            {
                label: 'Nuevo estado',
                fieldName: 'NewStatus',
                type: 'text'
            }];

        objComponent.set('v.arrColumns', arrColumns);
    }
})