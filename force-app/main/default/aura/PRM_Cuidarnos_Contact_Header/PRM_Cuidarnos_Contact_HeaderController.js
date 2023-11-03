({
    initializeComponent: function(objComponent, objEvent, objHelper) {      
        var objPhone = null;

        objComponent.set('v.iscontacttracing', (window.location.pathname.indexOf('tracing') > 0 ) );

        objHelper.initializeColumns(objComponent);

        
        objPhone = window.localStorage.getItem('source_phone');
        
        if(objPhone !== undefined && objPhone !== null && objPhone.length > 0) {
            objComponent.set('v.source_phone', objPhone);
        }

    },
    forceRefreshViewHandler : function(objComponent, objEvent, objHelper) {
        $A.get("e.force:refreshView").fire(); 
    },
    showHideAlta : function(objComponent, objEvent, objHelper) {        
        if(document.getElementById('chkAlta').checked === true) {
            objComponent.set('v.alta','show');
        } else {
            objComponent.set('v.alta','hide');        
        }
    },
    proccesAction : function(objComponent, objEvent, objHelper) {      
        var strAction = null;

        if(objEvent !== undefined && objEvent !== null && objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget.dataset !== null && objEvent.currentTarget.dataset.action !== undefined && objEvent.currentTarget.dataset.action !== null && objEvent.currentTarget.dataset.action.length > 0) {
            strAction = objEvent.currentTarget.dataset.action;
            switch(strAction) {
                case 'triage':
                    objHelper.validateAction(objComponent, 'Triage', objHelper.redirectToTriage, [objComponent, objHelper]);
                    break;
                case 'edit':
                    objHelper.showModal(objComponent, 'divModalEdit');
                    break;  
                case 'follow':
                    objHelper.showModal(objComponent, 'divModalFollow');
                    break;    
                case 'suspect':
                    objHelper.showModal(objComponent, 'divModalSuspect');
                    break;    
                case 'discard':
                    objHelper.showModal(objComponent, 'divModalDiscard');
                    break;
                case 'risk':
                    objHelper.showModal(objComponent, 'divModalRisk');
                    break;
                case 'detect':
                    objHelper.retrieveMuestras(objComponent);
                    objHelper.showModal(objComponent, 'divModalDetect');
                    break;
                case 'nodetect':
                    objHelper.retrieveMuestras(objComponent);
                    objHelper.showModal(objComponent, 'divModalNoDetect');
                    break;
                case 'invalid':
                    objHelper.retrieveMuestras(objComponent);
                    objHelper.showModal(objComponent, 'divModalInvalid');
                    break;
                case 'notify':
                    objHelper.showModal(objComponent, 'divModalNotify');
                    break;
                case 'archive':
                    objHelper.showModal(objComponent, 'divModalArchive');
                    break;                    
                case 'mark_discard':
                    objHelper.updateStatus(objComponent, 'Descartado');
                    objHelper.hideModals(objComponent);
                    break;
                case 'mark_suspect':                    
                    objHelper.processSuspect(objComponent);
                    objHelper.hideModals(objComponent);
                    break;
                case 'mark_follow':   
                    objHelper.updateStatus(objComponent, 'Seguimiento COH');
                    //objHelper.processFollow(objComponent);
                    objHelper.hideModals(objComponent);
                    break;
                case 'mark_risk':        
                    var strStep = objEvent.currentTarget.dataset.step;
                    var strRisk = null;
                    var divModalContentStep1 = objComponent.find('divModalRiskContentStep1');
                    var divModalContentStep2 = objComponent.find('divModalRiskContentStep2');

                    if(strStep === '1') {
                        $A.util.addClass(divModalContentStep1, 'slds-hide');
                        $A.util.removeClass(divModalContentStep2, 'slds-hide');
                        //mostrar step 2
                    } else {               
                        strRisk = objComponent.find('cboRisk').get('v.value');

                        objHelper.updateRisk(objComponent, strRisk);
                        objHelper.hideModals(objComponent);
                        //guardar muestra
                    }
                    break;
                case 'mark_detect':        
                    var arrMuestras = objComponent.get('v.arrMuestras');
                    var strStep = objEvent.currentTarget.dataset.step;
                    var strMuestra = null;
                    var strLab = null;

                    if(arrMuestras === undefined || arrMuestras === null || arrMuestras.length <= 1) {
                        strMuestra = (arrMuestras === undefined || arrMuestras === null || arrMuestras.length <= 0)?'':arrMuestras[0] ;
                        strLab = objComponent.find('cbLaboratiorioDetectado').get('v.value');
                        objHelper.updateResultadoMuestra(objComponent, 'Detectable',strLab, strMuestra.Id);
                        objHelper.hideModals(objComponent);
                    } else {
                        var divModalContentStep1 = objComponent.find('divModalDetectContentStep1');
                        var divModalContentStep2 = objComponent.find('divModalDetectContentStep2');

                        if(strStep === '1') {
                            $A.util.addClass(divModalContentStep1, 'slds-hide');
                            $A.util.removeClass(divModalContentStep2, 'slds-hide');
                            //mostrar step 2
                        } else {               
                            strMuestra = objComponent.find('cboEtiquetaDetectado').get('v.value');
                            strLab = objComponent.find('cbLaboratiorioDetectado').get('v.value');

                            objHelper.updateResultadoMuestra(objComponent, 'Detectable',strLab, strMuestra);
                            objHelper.hideModals(objComponent);
                            //guardar muestra
                        }
                    }
                    break;
                case 'mark_nodetect':                   
                    var arrMuestras = objComponent.get('v.arrMuestras');
                    var strStep = objEvent.currentTarget.dataset.step;
                    var strMuestra = null;
                    var strLab = null;

                    if(arrMuestras === undefined || arrMuestras === null || arrMuestras.length <= 1) {
                        strMuestra = (arrMuestras === undefined || arrMuestras === null || arrMuestras.length <= 0)?'':arrMuestras[0] ;
                        strLab = objComponent.find('cbLaboratiorioNoDetectado').get('v.value');
                        objHelper.updateResultadoMuestra(objComponent, 'No Detectable',strLab, strMuestra.Id);
                        objHelper.hideModals(objComponent);
                    } else {
                        var divModalContentStep1 = objComponent.find('divModalNoDetectContentStep1');
                        var divModalContentStep2 = objComponent.find('divModalNoDetectContentStep2');

                        if(strStep === '1') {
                            $A.util.addClass(divModalContentStep1, 'slds-hide');
                            $A.util.removeClass(divModalContentStep2, 'slds-hide');
                            //mostrar step 2
                        } else {
                            strLab = objComponent.find('cbLaboratiorioNoDetectado').get('v.value');
                            strMuestra = objComponent.find('cboEtiquetaNoDetectado').get('v.value');
                            objHelper.updateResultadoMuestra(objComponent, 'No Detectable',strLab, strMuestra);
                            objHelper.hideModals(objComponent);
                            //guardar muestra
                        }
                    }

                    break;
                case 'mark_invalid':                   
                    var arrMuestras = objComponent.get('v.arrMuestras');
                    var strStep = objEvent.currentTarget.dataset.step;
                    var strMuestra = null;
          
                    if(arrMuestras === undefined || arrMuestras === null || arrMuestras.length <= 1) {
                        strMuestra = (arrMuestras === undefined || arrMuestras === null || arrMuestras.length <= 0)?'':arrMuestras[0] ;

                        objHelper.updateResultadoMuestra(objComponent, 'Inválido', strMuestra.Id);
                        objHelper.hideModals(objComponent);
                    } else {
                        var divModalContentStep1 = objComponent.find('divModalInvalidContentStep1');
                        var divModalContentStep2 = objComponent.find('divModalInvalidContentStep2');

                        if(strStep === '1') {
                            $A.util.addClass(divModalContentStep1, 'slds-hide');
                            $A.util.removeClass(divModalContentStep2, 'slds-hide');
                            //mostrar step 2
                        } else {            
                            strMuestra = objComponent.find('cboEtiquetaNoDetectado').get('v.value');
                            objHelper.updateResultadoMuestra(objComponent, 'Inválido', null, strMuestra);
                            objHelper.hideModals(objComponent);
                            //guardar muestra
                        }
                    } 
                    break;
                case 'mark_notify':                    
                    //objHelper.updateStatus(objComponent, 'Notificado');
                    objHelper.hideModals(objComponent);
                    objHelper.notify(objComponent);                    
                    break;
                case 'mark_archive':                    
                    objHelper.updateStatusArchive(objComponent, 'Archivado' , objComponent.get('v.email') , document.getElementById('chkAlta').checked);
                    objHelper.hideModals(objComponent);                   
                    break;
                case 'tag': 
                    var divLocation = null;
                    if(objEvent !== undefined && objEvent !== null && objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget.dataset !== null && objEvent.currentTarget.dataset.tagaction !== undefined && objEvent.currentTarget.dataset.tagaction !== null && objEvent.currentTarget.dataset.tagaction.length > 0) {
                        objComponent.set('v.tag_mode', objEvent.currentTarget.dataset.tagaction);
                    }

                    if(objEvent.currentTarget.dataset.tagaction == '1' ) {
                        document.getElementById('location_container').style.display = '';
                        document.getElementById('tag_container').style.display = 'none';
            
                        if(objEvent.currentTarget.dataset.location === 'pilar') {
                            if( objEvent.currentTarget.dataset.defaultlab !== undefined && objEvent.currentTarget.dataset.defaultlab !== null && objEvent.currentTarget.dataset.defaultlab.length > 0) {
                                objComponent.find('cboLocation').set('v.value', objEvent.currentTarget.dataset.defaultlab);
                                
                                divLocation = objComponent.find('divLocation');
                                $A.util.addClass(divLocation, 'slds-hide');     
                                objHelper.showModal(objComponent, 'divModalEtiquetaPilar');
                            } else {
                                objHelper.showModal(objComponent, 'divModalEtiquetaPilar');
                            }
                        } else {
                            objComponent.find('cboLocation').set('v.value','no pilar');
                            objHelper.showModal(objComponent, 'divModalEtiqueta');
                        }
                    } else {
                        document.getElementById('tag_container').style.display = '';
                        document.getElementById('location_container').style.display = 'none';
            
                        objHelper.showPrintTagModal(objComponent);
                    }
                           
                    break;
                case 'generate_tag':
                    objHelper.showPrintTagModal(objComponent);
                    break;
                case 'print_tag':               
                    objHelper.printTag(objComponent);
                    objHelper.hideModals(objComponent);
                    break;

                case 'reprint_tag':               
                    objHelper.printTag(objComponent);
                    break;
                case 'save_edit':
                    objHelper.saveCitizenSF(objComponent);
                    objHelper.hideModals(objComponent);
                    break;
                case 'close_modal':
                    objHelper.hideModals(objComponent);
                    break;
                case 'call_ivr':
                    objHelper.hideModals(objComponent);
                    objHelper.makeCall(objComponent);
                    break;
               
            }
        }
    },
    closeModal : function(objComponent, objEvent, objHelper) {
        objHelper.hideModals(objComponent);
    },
    deactivateSuspect : function(objComponent, objEvent, objHelper) {
        document.getElementById('chkMarkSuspect').checked = false;
    },
    deactivatePositive : function(objComponent, objEvent, objHelper) {
        document.getElementById('chkMarkConfirm').checked = false;
    },
    showTelemedicoModal : function(objComponent, objEvent, objHelper) {
        objHelper.showModal(objComponent, 'divModalIVR'); 
    },
    showHistory : function(objComponent, objEvent, objHelper) {
        objHelper.retrieveHistory(objComponent);

        objHelper.showModal(objComponent, 'divModalHistorial');
    },
    goToRelated : function(objComponent, objEvent, objHelper) {
        var strData = null;
        var strUrl = null;

        if(objEvent !== undefined && objEvent !== null && objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget.dataset !== null && objEvent.currentTarget.dataset.search !== undefined && objEvent.currentTarget.dataset.search !== null && objEvent.currentTarget.dataset.search.length > 0) {
            strData = objEvent.currentTarget.dataset.search;

            strUrl = '/global-search/' + encodeURIComponent(strData)

            objEvent = $A.get("e.force:navigateToURL");
            objEvent.setParams({
              "url": strUrl
            });

            objEvent.fire();
        }
    },
    initializeColumns : function(objComponent) {
        var arrColumns = [
            {
                label: 'Estado anterior',
                fieldName: 'OldValue',
                type: 'text'
            },
            {
                label: 'Nuevo estado',
                fieldName: 'NewValue',
                type: 'text'
            },
            {
                label: 'Usuario',
                fieldName: 'Parent.CreatedBy.Name',
                type: 'text'
            },
            {
                label: 'Fecha',
                fieldName: 'CreatedDate',
                type: 'currency'
            }];

        objComponent.set('v.arrColumns', arrColumns);
    }
})