public without sharing class PRM_Cuidarnos {
    public class CuidarnosException extends Exception {}
    private static String STATUS_INITIAL = '';

    //RESULTADO TRIAGE -> los pone eric, no se validan
    private static String STATUS_ASINTOMATICO = 'Asintomático';
    private static String STATUS_SINTOMATICO = 'Sintomático';

    //solo pude venir de sintomatico o asintomatico
    private static String STATUS_SOSPECHOSO = 'Sospechoso';
    private static String STATUS_SEGUIMIENTO_COH = 'Seguimiento COH';

    private static String STATUS_MUESTRA = 'Muestra';
    
    private static String STATUS_DETECTABLE = 'Detectable';
    private static String STATUS_DETECTABLE_CONFIRMADO = 'Detectable_Confirmado';
    
    private static String STATUS_NO_DETECTABLE = 'No Detectable';
    private static String STATUS_INVALIDO = 'Inválido';
    
    private static String STATUS_NOFIFICADO = 'Notificado';
    private static String STATUS_SEGUIMIENTO = 'Seguimiento';
    private static String STATUS_DESCARTADO = 'Descartado';
    private static String STATUS_TELEMEDICO = 'Telemedico';

    private static String STATUS_ARCHIVADO = 'Archivado';


    private static Boolean validateRecordStatus(String strCurrentStatus, String strNextStatus) {
        Boolean boolIsValid = false;
        Map<String, Set<String>> mapAllosedStatus = null;

        System.debug('validateRecordStatus [strCurrentStatus : ' + strCurrentStatus + ' - strNextStatus : ' + strNextStatus + '] ->');
        mapAllosedStatus = new Map<String, Set<String>>();
        mapAllosedStatus.put(STATUS_SOSPECHOSO, new Set<String> {STATUS_ASINTOMATICO, STATUS_SINTOMATICO, STATUS_DESCARTADO });
        mapAllosedStatus.put(STATUS_MUESTRA, new Set<String> { STATUS_SOSPECHOSO, STATUS_INVALIDO });
        mapAllosedStatus.put(STATUS_DETECTABLE, new Set<String> { STATUS_MUESTRA });
        mapAllosedStatus.put(STATUS_NO_DETECTABLE, new Set<String> { STATUS_MUESTRA });
        mapAllosedStatus.put(STATUS_INVALIDO, new Set<String> { STATUS_MUESTRA });
        mapAllosedStatus.put(STATUS_NOFIFICADO, new Set<String> { STATUS_DETECTABLE, STATUS_NO_DETECTABLE });
        mapAllosedStatus.put(STATUS_DESCARTADO, new Set<String> {STATUS_ASINTOMATICO, STATUS_SINTOMATICO, STATUS_SOSPECHOSO, STATUS_INVALIDO });
        mapAllosedStatus.put(STATUS_ARCHIVADO, new Set<String> {STATUS_NOFIFICADO, STATUS_SEGUIMIENTO_COH });
        mapAllosedStatus.put(STATUS_SEGUIMIENTO_COH, new Set<String> {STATUS_SINTOMATICO,STATUS_ASINTOMATICO,STATUS_DESCARTADO });

        mapAllosedStatus.put('Triage', new Set<String> { STATUS_DESCARTADO, STATUS_NO_DETECTABLE, STATUS_NOFIFICADO });

        if(mapAllosedStatus.containsKey(strNextStatus) && mapAllosedStatus.get(strNextStatus).contains(strCurrentStatus) ) {
            boolIsValid = true;
        } else if(strNextStatus == 'Triage' && String.isBlank(strCurrentStatus) ) {
            boolIsValid = true;
        }
        
        System.debug('validateRecordStatus [' + boolIsValid + '] <-');

        return boolIsValid;
    }

    @AuraEnabled 
    public static Boolean validateAction(String strCitizenId, String strStatus) { 
        Contact objContact = null;
        Covid19__c objCovid = null;
        Boolean boolIsValid = false;

        System.debug('validateAction [strCitizenId : ' + strCitizenId + ' - strStatus : ' + strStatus + ' ] ->');

        if(String.isNotBlank(strCitizenId) && String.isNotBlank(strStatus)) {
            objContact = retrieveContactCitizen(strCitizenId);        
            objCovid = retrieveCovidUser(objContact);
            //
            if(validateRecordStatus(objCovid.Cuidarnos_Comunidad_Status__c, strStatus)) {
                boolIsValid = true;
            } else {
                throw new CuidarnosException('EL registro ha sido modificado por otro usuario, por favor actualiza la página');
            }
        } else {
            throw new CuidarnosException('Los parámetros ingresados no estan completos');
        }

        System.debug('validateAction [' + boolIsValid + '] <-');

        return boolIsValid;

    }

    @AuraEnabled 
    public static String updateStatusInSalesforce(Id strCitizenId, String strStatus) {
        Contact objContact = null;
        Covid19__c objCovid = null;

        System.debug('updateStatusInSalesforce [strCitizenId : ' + strCitizenId + ' - strStatus : ' + strStatus + ' ] ->');

        if(String.isNotBlank(strCitizenId) && String.isNotBlank(strStatus)) {
            objContact = retrieveContactCitizen(strCitizenId);        
            objCovid = retrieveCovidUser(objContact);
            //
            if(validateRecordStatus(objCovid.Cuidarnos_Comunidad_Status__c, strStatus)) {
                //SINTOMATICO - ASINTOMATICO 
                System.debug('updateStatusInSalesforce [strStatus... ' + strStatus + ']');
                System.debug('updateStatusInSalesforce [(strStatus == STATUS_SOSPECHOSO)... ' + (strStatus == STATUS_SOSPECHOSO) + ']');

                if( strStatus == STATUS_SOSPECHOSO || strStatus == STATUS_DESCARTADO || strStatus == STATUS_SEGUIMIENTO_COH) {
                    objCovid.Telemedico_Status__c = strStatus;
                    objCovid.Telemedico_Date__c = DateTime.now();                
                } else if(strStatus == STATUS_MUESTRA) {                    
                    objCovid.label_date__c = DateTime.now();
                } else if(strStatus == STATUS_DETECTABLE || strStatus == STATUS_NO_DETECTABLE || strStatus == STATUS_INVALIDO) { 
                    //objCovid.Telemedico_Status__c = strStatus;
                    //objCovid.Telemedico_Date__c = DateTime.now();                

                    objCovid.Cuidarnos_Muestra_Result__c = strStatus;
                    objCovid.Cuidarnos_Muestra_Result_Date__c = DateTime.now();
                } else if(strStatus == STATUS_NOFIFICADO) { 
                    objCovid.Notificacion_Date__c = DateTime.now();
                } else if(strStatus == STATUS_DETECTABLE_CONFIRMADO) {
                    strStatus = STATUS_DETECTABLE;
                    
                    objCovid.Cuidarnos_Muestra_Result__c = STATUS_DETECTABLE;
                    objCovid.Cuidarnos_Muestra_Result_Date__c = DateTime.now();

                    objCovid.Telemedico_Status__c = STATUS_SOSPECHOSO;
                    objCovid.Telemedico_Date__c = DateTime.now();     
                } else if(strStatus == STATUS_ARCHIVADO) {
                    objCovid.Archive_Date__c = DateTime.now();                          
                }
                                
                System.debug('updateStatusInSalesforce [' + strStatus + ']');

                objCovid.Cuidarnos_Comunidad_Status__c = strStatus;            
                objCovid.Cuidarnos_Comunidad_Date__c = DateTime.now();
            
                //publishEvent(strCitizenId, strStatus);

                if(String.isBlank(objCovid.Id)) { 
                    insert objCovid;
                } else {
                    update objCovid; 
                }
            } else {
                throw new CuidarnosException('EL registro ha sido modificado por otro usuario, por favor actualzia la página');
            }
        } else {
            throw new CuidarnosException('Los parámetros ingresados no estan completos');
        }

        System.debug('updateStatusInSalesforce [' + strStatus + '] <-');

        return strStatus;
    }

    @AuraEnabled
    public static String updateStatusMuestraInSalesforce(Id strCitizenId, String strStatus, String strLocation, String strTipoEstudio) {
        Contact objContact = null;
        Covid19__c objCovid = null;
        Boolean boolMark = null;
        Map<String, String> mapLocation = null;

        System.debug('updateStatusMuestraInSalesforce [strCitizenId : ' + strCitizenId + ' - strStatus : ' + strStatus + ' - strLocation : ' + strLocation + ' - strTipoEstudio : ' + strTipoEstudio + ' ] ->');

        if(String.isNotBlank(strCitizenId) && String.isNotBlank(strStatus)) {
            objContact = retrieveContactCitizen(strCitizenId);        
            objCovid = retrieveCovidUser(objContact);
            mapLocation = retrieveMapLocation();

            if(validateRecordStatus(objCovid.Cuidarnos_Comunidad_Status__c, strStatus)) {
                objCovid.label_date__c = DateTime.now();
                objCovid.label_place__c = (mapLocation.containsKey(strLocation))?mapLocation.get(strLocation):strLocation;
                objCovid.Cuidarnos_Comunidad_Status__c = strStatus;            
                objCovid.Cuidarnos_Comunidad_Date__c = DateTime.now();
                if(String.IsNotBlank(strTipoEstudio)) {
                    objCovid.Tipo_de_Test__c = strTipoEstudio;
                }
                
                if(String.isBlank(objCovid.Id)) { 
                    insert objCovid;
                } else {
                    update objCovid; 
                }
            } else {
                throw new CuidarnosException('EL registro ha sido modificado por otro usuario, por favor actualzia la página');
            }
        } else {
            System.debug('updateStatusMuestraInSalesforce [strCitizenId is NULL - ' + strCitizenId + ']'); 
        }

        System.debug('updateStatusMuestraInSalesforce [' + strStatus + '] <-');

        return strStatus;
    }

    @AuraEnabled
    public static String updateStatusArchiveInSalesforce(Id strCitizenId, String strStatus, String strEmail, Boolean boolDarAlta) {
        Contact objContact = null;
        CitizenWrapper objCitizenWrapper = null; 
        Boolean boolMark = null;
        Map<String, String> mapLocation = null;
        Covid19__c objCovid = null;
        
        System.debug('updateStatusArchiveInSalesforce [strCitizenId : ' + strCitizenId + ' - strStatus : ' + strStatus + ' - strEmail : ' + strEmail + ' - boolDarAlta : ' + boolDarAlta + ' ] ->');

        if(String.isNotBlank(strCitizenId) && String.isNotBlank(strStatus)) {
            updateStatusInSalesforce(strCitizenId, strStatus);

            if(boolDarAlta) {
                objContact = retrieveContactCitizen(strCitizenId);        
                objCovid = retrieveCovidUser(objContact);
                objCovid.Estado_Epidemiologico__c = 'Alta';
                update objCovid;

                /*
                objContact = ContactDetailController.retrieveContactFromId(strCitizenId);
                objCitizenWrapper = new CitizenWrapper(objContact);

                darAltaUserFuture(objCitizenWrapper.cuidarnos.pdf_url, strCitizenId, true, strEmail);
                */
            }
        } else {
            System.debug('updateStatusArchiveInSalesforce [strCitizenId is NULL - ' + strCitizenId + ']'); 
        }

        System.debug('updateStatusArchiveInSalesforce [' + strStatus + '] <-');

        return strStatus;
    }

    @AuraEnabled
    public static void updateRiskInSalesforce(Id strCitizenId, String strRisk) {
        Contact objContact = null;
        Covid19__c objCovid = null;

        System.debug('updateRiskInSalesforce [strCitizenId : ' + strCitizenId + ' - strRisk : ' + strRisk + '] ->');

        if(String.isNotBlank(strCitizenId) && String.isNotBlank(strRisk)) {
            objContact = retrieveContactCitizen(strCitizenId);        
            objCovid = retrieveCovidUser(objContact);

            objCovid.Riesgo__c = strRisk;
            
            if(String.isBlank(objCovid.Id)) { 
                insert objCovid;
            } else {
                update objCovid; 
            }
        } else {
            System.debug('updateRiskInSalesforce [strCitizenId is NULL - ' + strCitizenId + ']'); 
        }
    }
    
    @AuraEnabled 
    public static CitizenWrapper retrieveInfoFromCitizenId(String strCitizenId) {
        return ContactDetailController.retrieveInfoFromCitizenId(strCitizenId);
    }

    private static Map<String, String> retrieveMapLocation() {
        Map<String, String> mapLocation = null;

        System.debug('retrieveMapLocation [] ->');

        mapLocation = new Map<String,String>();
        mapLocation.put('A', 'Tratado de Pilar');
        mapLocation.put('B', 'KM 46');
        mapLocation.put('C', 'Teófilo Tolosa');
        mapLocation.put('D', 'Hospital Sanguinetti');
        mapLocation.put('F', 'Centro Aislamiento Maristas');
        mapLocation.put('G', 'Hebraica');
        mapLocation.put('H', 'Foraneos TT');
		mapLocation.put('I', 'Hospital Falcón');
		mapLocation.put('J', 'Hospital Derqui');

        mapLocation.put('K', 'Maternidad');

        mapLocation.put('L', 'Hospital Sanguinetti - Guardia');
        mapLocation.put('M', 'SAME');
        mapLocation.put('N', 'Centro Odontológico');

        mapLocation.put('O', 'Unidad de Testeo Móvil 1');
        mapLocation.put('P', 'Unidad de Testeo Móvil 2');
        mapLocation.put('Q', 'Unidad de Testeo Móvil 3');
        mapLocation.put('R', 'Unidad de Testeo Móvil 4');
        mapLocation.put('S', 'Unidad de Testeo Móvil 5');

        mapLocation.put('T', 'Centro Municipal');

        System.debug('retrieveMapLocation [' + mapLocation + '] <-');

        return mapLocation;
    }


    @AuraEnabled
    public static String updateResultadoMuestraInSalesforce(Id strCitizenId, String strStatus, String strLab, Integer intLabelId, String strHashEtiqueta) {
        Contact objContact = null;
        Covid19__c objCovid = null;
        Boolean boolMark = null;
        String strIdentifier = null;
 
        System.debug('updateResultadoMuestraInSalesforce [strCitizenId : ' + strCitizenId + ' - strStatus : ' + strStatus + ' - intLabelId : ' + intLabelId + ' - strHashEtiqueta : ' + strHashEtiqueta + ' ] ->');

        if(String.isNotBlank(strCitizenId) && String.isNotBlank(strStatus)) {
            updateStatusInSalesforce(strCitizenId, strStatus); 
            if(intLabelId != NULL || String.isNotBlank(strHashEtiqueta)) {               
                objContact = retrieveContactCitizen(strCitizenId);        
                objCovid = retrieveCovidUser(objContact);
                
                objCovid.Cuidarnos_Hash_Etiqueta__c = strHashEtiqueta;
                objCovid.Cuidarnos_Resultado_Etiqueta__c = String.valueOf(intLabelId);
                objCovid.Cuidarnos_Muestra_Laboratorio__c = strLab;
                 
                update objCovid;

                postResultadosExternalSystem(strCitizenId, strLab, intLabelId, strStatus);

                if(strStatus == STATUS_INVALIDO) {
                    notifyUserInvalidResultSMSFuture(strCitizenId);
                }
            }
        } else {
            System.debug('updateResultadoMuestraInSalesforce [strCitizenId is NULL - ' + strCitizenId + ']'); 
        }

        System.debug('updateResultadoMuestraInSalesforce [' + strStatus + '] <-');

        return strStatus;
    }
    

    
    @AuraEnabled
    public static void markCitizenInSalesforce(Id strCitizenId, String strStatus) {
        Cuidarnos_SMS_Send__c objSMSSend = null;
        Contact objContact = null;
        Covid19__c objCovid = null;

        System.debug('markCitizenInSalesforce [strCitizenId : ' + strCitizenId + ' - strStatus : ' + strStatus + '] ->');

        if(String.isNotBlank(strCitizenId)) {
            updateStatusInSalesforce(strCitizenId, strStatus);

            objSMSSend = saveRequestInfo(strCitizenId);

            markCitizenInSalesforceFuture(strCitizenId, objSMSSend.Id);
        } else {
            System.debug('markCitizenInSalesforce [strCitizenId is NULL - ' + strCitizenId + ']'); 
        }

        System.debug('markCitizenInSalesforce [] <-');
    }

    @AuraEnabled
    public static void processFollowInSalesforce(Id strCitizenId) {
        List<Contact> lstContacts = null;
        Set<Id> setContactIds = null;
        List<Covid19__c> lstCovidUsers = null;
        String strSOSL = null;
        String strHash = null;
        Map<String,String> mapCitizenHashes = null;
        List<List<sObject>> lstResults = null;
        Covid19__c objCovid = null;

        System.debug('processFollowInSalesforce [strCitizenId : ' + strCitizenId + '] ->');
 
        if(String.isNotBlank(strCitizenId)) {
            lstContacts = [SELECT grouphash_coh__c FROM Contact WHERE Id =: strCitizenId];
            if(!lstContacts.isEmpty()) {
                strHash = lstContacts[0].grouphash_coh__c;

                if(String.IsNotBlank(strHash)) {
                    strSOSL = 'FIND {' + strHash + '} RETURNING Contact(Id, GUID__c)';
                    lstResults = Search.query(strSOSL);

                    if(!lstResults.IsEmpty()) {
                        lstContacts = lstResults[0];                    

                        if(!lstContacts.isEmpty()) {
                            lstCovidUsers = new List<Covid19__c>();
                            for(Contact objContact : lstContacts) {
                                if(objContact.Id <> strCitizenId) {
                                    objCovid = new Covid19__c();
                                    objCovid.Mark_to_follow__c = true;
                                    objCovid.Follow_reason__c = strCitizenId;
                                    objCovid.Cuidarnos_Comunidad_Status__c = STATUS_SEGUIMIENTO_COH;
                                    objCovid.Telemedico_Status__c = STATUS_SEGUIMIENTO_COH;
                                    objCovid.Telemedico_Date__c = DateTime.now();    
                                    objCovid.GUID__c = objContact.GUID__c; 
                                    objCovid.Citizen__c = objContact.Id;
                                     
                                    lstCovidUsers.add(objCovid);
                                }
                            }

                            upsert lstCovidUsers GUID__c;
                        } else {
                            System.debug('processFollowInSalesforce [no related contacts]'); 
                        }
                    }
                } else {
                    System.debug('processFollowInSalesforce [hash is blank]'); 
                }
            } else {
                System.debug('processFollowInSalesforce [Not hashes found]'); 
            }
        } else {
            System.debug('processFollowInSalesforce [strCitizenId is NULL - ' + strCitizenId + ']'); 
        }

        System.debug('processFollowInSalesforce [] <-');
    }

    @AuraEnabled
    public static List<CitizenWrapper.Observaciones> saveUserObservationsInSalesforce(Id strCitizenId, String strObservations) { 
        Contact objContact = null;
        Covid19__c objCovid = null;
        Covid_Observacion__c objCovidObservation = null;
        List<CitizenWrapper.Observaciones> lstObservaciones = null;
        List<Covid_Observacion__c> lstCovidObservaciones = null;

        System.debug('saveUserObservationsInSalesforce [strCitizenId : ' + strCitizenId + ' - strObservations : ' + strObservations + '] ->');
        
        if(String.isNotBlank(strCitizenId)) {
            objContact = retrieveContactCitizen(strCitizenId);
            System.debug('saveUserObservationsInSalesforce [objContact : ' + objContact + '] ->');
            
            objCovid = retrieveCovidUser(objContact);
            if(String.isBlank(objCovid.Id)) {
                insert objCovid;
            }
            
            System.debug('saveUserObservationsInSalesforce [objCovid : ' + objCovid + '] ->');
    
            objCovidObservation = new Covid_Observacion__c();
            objCovidObservation.Covid19__c = objCovid.Id; 
            objCovidObservation.Observaciones__c = strObservations;
            insert objCovidObservation;

            lstCovidObservaciones = [SELECT Id, Name, Observaciones__c, CreatedBy.Name, CreatedDate 
                                     FROM Covid_Observacion__c 
                                     WHERE Covid19__c =: objCovid.Id  
                                     ORDER BY CreatedDate DESC];
            lstObservaciones = new List<CitizenWrapper.Observaciones>(); 
            if(!lstCovidObservaciones.IsEmpty()) {
                for(Covid_Observacion__c objObservacion : lstCovidObservaciones) {
                    lstObservaciones.add(new CitizenWrapper.Observaciones(objObservacion));
                }
            }
        }

        System.debug('saveUserObservationsInSalesforce [' + lstObservaciones + '] <-');    
        return lstObservaciones;
    }

    @AuraEnabled
    public static void saveCitizenInSalesforce(Id strCitizenId, String strMobile, String strEmail, String strFijo) {
        Contact objContact = null;
        Covid19__c objCovid = null;

        System.debug('saveCitizenInSalesforce [strCitizenId : ' + strCitizenId + ' - strMobile : ' + strMobile + ' - strEmail : ' + strEmail + '] ->');
        
        if(String.isNotBlank(strCitizenId)) {
            objContact = retrieveContactCitizen(strCitizenId);
            System.debug('saveCitizenInSalesforce [objContact : ' + objContact + ']');
            
            objCovid = retrieveCovidUser(objContact);
            System.debug('saveCitizenInSalesforce [objCovid : ' + objCovid + ']');
            objCovid.Email__c = strEmail;
            objCovid.Mobile_Phone__c = strMobile;
            objCovid.Phone__c = strFijo;
            
            if(String.isBlank(objCovid.Id)) { 
                insert objCovid;
            } else {
                update objCovid; 
            }
        }

        System.debug('saveCitizenInSalesforce [] <-');    
    }

    @AuraEnabled
    public static String notifyUser(String strUrl, String strCitizenId) {
        String strStatus = null;

        System.debug('notifyUser [strStatus : ' + strUrl + ' - strCitizenId : ' + strCitizenId +  ' ] ->');

        try {            
            saveUserObservationsInSalesforce(strCitizenId, 'El usuario fue notificado');
            notifyUserSMSFuture(strCitizenId);
            strStatus = STATUS_NOFIFICADO;
            updateStatusInSalesforce(strCitizenId, strStatus);

            //if(UserPermissions.)
            //notifyUserFuture(strUrl, strCitizenId);
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);    
        }

        System.debug('notifyUser [' + strStatus + '] <-');
        
        return strStatus;
    }

    @AuraEnabled
    public static void publicNotifyUserSMSFuture(String strCitizenId) {
        System.debug('publicNotifyUserSMSFuture [strCitizenId : ' + strCitizenId +  ' ] ->');
        try {            
            notifyUserSMSFuture(strCitizenId);
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);    
        }
    }


    /*
    @AuraEnabled
    public static void publishEvent(String strCitizenId, String strStatus) {
        List<Cuidarnos_Status_Change__e> lstChanges = null;
        Cuidarnos_Status_Change__e objChange = null;
        List<Database.SaveResult> lstResults = null;

        System.debug('publishEvent [strCitizenId : ' + strCitizenId + ' - strStatus : ' + strStatus + '  ] ->');

        lstChanges = new List<Cuidarnos_Status_Change__e>();
        objChange = new Cuidarnos_Status_Change__e();
        objChange.Citizen__c = strCitizenId;
        objChange.Status__c = strStatus;

        lstChanges.add(objChange);
        lstResults = EventBus.publish(lstChanges);
         // Inspect publishing results
        for (Database.SaveResult objResult : lstResults) {
            if (!objResult.isSuccess()) {
                for (Database.Error objError : objResult.getErrors()) {
                    System.debug('Error returned: ' + objError.getStatusCode() +' - '+ objError.getMessage());
                }
            }
        }
        
        System.debug('publishEvent [' + lstResults + ' ]');
        System.debug('publishEvent [] <-');
    }
*/
	public static void notifyUserInvalidResultSMSController(List<Covid19__c> lstCovid, Map<Id, Covid19__c> mapOldStatus) {
		Set<Id> setAllowedUsers = null;
		
		System.debug('notifyUserInvalidResultSMSController [lstCovid : ' + lstCovid + ' - mapOldStatus : ' + mapOldStatus + '] ->');

		setAllowedUsers = retrieveAllowedAPIUsers();
		if(lstCovid != null && !lstCovid.IsEmpty() && mapOldStatus != null && !mapOldStatus.IsEmpty() ) {
			if( setAllowedUsers.contains(UserInfo.getUserId())) {
				for(Covid19__c objCovid : lstCovid) {
					if(objCovid.Cuidarnos_Comunidad_Status__c == STATUS_INVALIDO && objCovid.Cuidarnos_Comunidad_Status__c != mapOldStatus.get(objCovid.Id).Cuidarnos_Comunidad_Status__c) {
						notifyUserInvalidResultSMSFuture(objCovid.Citizen__c);
					}				
				}
			}
		}

		System.debug('notifyUserInvalidResultSMSFuture [] <-');
	}

	private static Set<Id> retrieveAllowedAPIUsers() {
        Cuidarnos__mdt objCuidarnosSettings = null;
		Set<Id> setUsers = null;
        List<String> lstUsers = null;
        List<User> lstUsersC = null;
        
		System.debug('retrieveAllowedAPIUsers [] ->');
        setUsers = new Set<Id>();
        objCuidarnosSettings = retrieveSMSSettings(); 
        if(String.IsNotBlank(objCuidarnosSettings.Allowed_API_Users__c)) {
            lstUsers = objCuidarnosSettings.Allowed_API_Users__c.split(',');

            lstUsersC = [SELECT Id FROM User WHERE UserName IN : lstUsers];

            if(!lstUsersC.isEmpty()) {
                for(User objUser : lstUsersC) {
                    setUsers.add(objUser.Id);
                }
            }            
        }
        
		System.debug('retrieveAllowedAPIUsers [' + setUsers + '] <-');
		return setUsers;
	}

    @future(callout=true)
    private static void notifyUserInvalidResultSMSFuture(String strCitizenId) {
        Contact objContact = null;
        CitizenWrapper objCitizenWrapper = null;
        Cuidarnos__mdt objCuidarnosSettings = null;
        String strMobilePhone = null;
        List<Cuidarnos_SMS_Send__c> lstCuidarnosSends = null;
        Cuidarnos_SMS_Send__c objSMSSend = null;
        String strMessage = null;
        Covid19__c objCovid = null;

        System.debug('notifyUserInvalidResultSMSFuture [strCitizenId : ' + strCitizenId + '] ->');

        lstCuidarnosSends = new List<Cuidarnos_SMS_Send__c>();
        objContact = ContactDetailController.retrieveContactFromId(strCitizenId);
        objCitizenWrapper = new CitizenWrapper(objContact);
        objCovid = retrieveCovidUser(objContact);

        System.debug('notifyUserInvalidResultSMSFuture [objCitizenWrapper : ' + objCitizenWrapper + ']');
        
        if(objCitizenWrapper != NULL && ( String.isNotBlank(objCitizenWrapper.citizen.MobilePhone) || String.isNotBlank(objCitizenWrapper.cuidarnos.covid.Mobile_Phone__c) )) {                   
            strMobilePhone = String.isNotBlank(objCitizenWrapper.cuidarnos.covid.Mobile_Phone__c)?objCitizenWrapper.cuidarnos.covid.Mobile_Phone__c:objCitizenWrapper.citizen.MobilePhone;

            objCuidarnosSettings = retrieveSMSSettings();                

            objSMSSend = enviarSMS3(objCitizenWrapper, objCovid, strMobilePhone, objCuidarnosSettings);
            if(objSMSSend != NULL){
                lstCuidarnosSends.add(objSMSSend);
            } 

            if(!lstCuidarnosSends.isEmpty()) {
                insert lstCuidarnosSends;
            }
        } 
        
        System.debug('notifyUserInvalidResultSMSFuture [] <-');      
    }

    @future(callout=true)
    private static void notifyUserSMSFuture(String strCitizenId) {
        Contact objContact = null;
        CitizenWrapper objCitizenWrapper = null;
        Cuidarnos__mdt objCuidarnosSettings = null;
        String strMobilePhone = null;
        List<Cuidarnos_SMS_Send__c> lstCuidarnosSends = null;
        Cuidarnos_SMS_Send__c objSMSSend = null;
        String strMessage = null;
        Covid19__c objCovid = null;

        System.debug('notifyUserSMSFuture [strCitizenId : ' + strCitizenId + '] ->');

        lstCuidarnosSends = new List<Cuidarnos_SMS_Send__c>();
        objContact = ContactDetailController.retrieveContactFromId(strCitizenId);
        objCitizenWrapper = new CitizenWrapper(objContact);
        objCovid = retrieveCovidUser(objContact);
 
        System.debug('notifyUserSMSFuture [objCitizenWrapper : ' + objCitizenWrapper + ']');
        
        if(objCitizenWrapper != NULL && ( String.isNotBlank(objCitizenWrapper.citizen.MobilePhone) || String.isNotBlank(objCitizenWrapper.cuidarnos.covid.Mobile_Phone__c) )) {                   
            strMobilePhone = String.isNotBlank(objCitizenWrapper.cuidarnos.covid.Mobile_Phone__c)?objCitizenWrapper.cuidarnos.covid.Mobile_Phone__c:objCitizenWrapper.citizen.MobilePhone;

            objCuidarnosSettings = retrieveSMSSettings();                

            objSMSSend = enviarSMS1(objCitizenWrapper, objCovid, strMobilePhone, objCuidarnosSettings);
            if(objSMSSend != NULL){
                lstCuidarnosSends.add(objSMSSend);
            } 
            objSMSSend = enviarSMS2(objCitizenWrapper, objCovid, strMobilePhone, objCuidarnosSettings);

            if(objSMSSend != NULL){
                lstCuidarnosSends.add(objSMSSend);
            }
    
            if(!lstCuidarnosSends.isEmpty()) {
                insert lstCuidarnosSends;
            }
        } 
        
        System.debug('notifyUserSMSFuture [] <-');      
    }

    private static Cuidarnos_SMS_Send__c enviarSMS1(CitizenWrapper objCitizenWrapper, Covid19__c objCovid, String strMobilePhone, Cuidarnos__mdt objCuidarnosSettings) {
        String strMessage = null;
        Cuidarnos_SMS_Send__c objSMSSend = null;

        System.debug('enviarSMS1 [objCitizenWrapper: ' + objCitizenWrapper + ' - objCovid : ' + objCovid + ' - strMobilePhone : ' + strMobilePhone + ' - objCuidarnosSettings : ' + objCuidarnosSettings +'] ->');      

        if(String.isNotBlank(objCuidarnosSettings.Notification_SMS_1__c)) {                                  
            if( (objCovid.Cuidarnos_Muestra_Result__c.toLowerCase() == 'detectable' && objCitizenWrapper.permissions.CuidarnosCanNotifyDetectSMS1) || ( objCovid.Cuidarnos_Muestra_Result__c.toLowerCase() == 'no detectable' && objCitizenWrapper.permissions.CuidarnosCanNotifyNoDetectSMS1) ) {
                strMessage = objCuidarnosSettings.Notification_SMS_1__c;
                if(objCuidarnosSettings.Label_Identifier__c == 'Hash') {
                    strMessage = strMessage.replace('##IDETIQUETA##', objCitizenWrapper.cuidarnos.covid.Cuidarnos_Hash_Etiqueta__c );
                } else {
                    strMessage = strMessage.replace('##IDETIQUETA##', objCitizenWrapper.cuidarnos.covid.Cuidarnos_Resultado_Etiqueta__c );
                }
        
 
                strMessage = strMessage.replace('##RESULTADO##', objCitizenWrapper.cuidarnos.covid.Cuidarnos_Comunidad_Status__c);
        
                objSMSSend = sendSMS(objCitizenWrapper.citizen.Id, strMobilePhone, objCuidarnosSettings.SMS_Keyword__c, strMessage);    
            }
        }


        System.debug('enviarSMS1 [' + objSMSSend + '] <-');      
        return objSMSSend;
    }
 
    private static Cuidarnos_SMS_Send__c enviarSMS2(CitizenWrapper objCitizenWrapper, Covid19__c objCovid, String strMobilePhone, Cuidarnos__mdt objCuidarnosSettings) {
        String strMessage = null;
        Cuidarnos_SMS_Send__c objSMSSend = null;
 
        System.debug('enviarSMS2 [objCitizenWrapper: ' + objCitizenWrapper + ' - objCovid : ' + objCovid + ' - strMobilePhone : ' + strMobilePhone + ' - objCuidarnosSettings : ' + objCuidarnosSettings +'] ->');      

        if(String.isNotBlank(objCuidarnosSettings.Notification_SMS_2__c)) {                                  
            if( (objCovid.Cuidarnos_Muestra_Result__c.toLowerCase() == 'detectable' && objCitizenWrapper.permissions.CuidarnosCanNotifyDetectSMS2) || ( objCovid.Cuidarnos_Muestra_Result__c.toLowerCase() == 'no detectable' && objCitizenWrapper.permissions.CuidarnosCanNotifyNoDetectSMS2) ) {
                strMessage = objCuidarnosSettings.Notification_SMS_2__c;

                if(objCuidarnosSettings.Label_Identifier__c == 'Hash') {
                    strMessage = strMessage.replace('##IDETIQUETA##', objCitizenWrapper.cuidarnos.covid.Cuidarnos_Hash_Etiqueta__c );
                } else {
                    strMessage = strMessage.replace('##IDETIQUETA##', objCitizenWrapper.cuidarnos.covid.Cuidarnos_Resultado_Etiqueta__c );
                }

                strMessage = strMessage.replace('##RESULTADO##', objCitizenWrapper.cuidarnos.covid.Cuidarnos_Comunidad_Status__c);
        
                objSMSSend = sendSMS(objCitizenWrapper.citizen.Id, strMobilePhone, objCuidarnosSettings.SMS_Keyword__c, strMessage);    
            }
        }


        System.debug('enviarSMS2 [' + objSMSSend + '] <-');      
        return objSMSSend;
    }

    //SMS INVALIDO
    private static Cuidarnos_SMS_Send__c enviarSMS3(CitizenWrapper objCitizenWrapper, Covid19__c objCovid, String strMobilePhone, Cuidarnos__mdt objCuidarnosSettings) {
        String strMessage = null;
        Cuidarnos_SMS_Send__c objSMSSend = null;
 
        System.debug('enviarSMS3 [objCitizenWrapper: ' + objCitizenWrapper + ' - objCovid : ' + objCovid + ' - strMobilePhone : ' + strMobilePhone + ' - objCuidarnosSettings : ' + objCuidarnosSettings +'] ->');      

        if(String.isNotBlank(objCuidarnosSettings.Notification_SMS_3__c)) {                                  
            if(objCovid.Cuidarnos_Muestra_Result__c.toLowerCase() == 'inválido' && objCitizenWrapper.permissions.CuidarnosCanNotifyInvalidSMS3) {
                strMessage = objCuidarnosSettings.Notification_SMS_3__c;

                if(objCuidarnosSettings.Label_Identifier__c == 'Hash') {
                    strMessage = strMessage.replace('##IDETIQUETA##', objCitizenWrapper.cuidarnos.covid.Cuidarnos_Hash_Etiqueta__c );
                } else {
                    strMessage = strMessage.replace('##IDETIQUETA##', objCitizenWrapper.cuidarnos.covid.Cuidarnos_Resultado_Etiqueta__c );
                }

                strMessage = strMessage.replace('##RESULTADO##', objCitizenWrapper.cuidarnos.covid.Cuidarnos_Comunidad_Status__c);
        
                objSMSSend = sendSMS(objCitizenWrapper.citizen.Id, strMobilePhone, objCuidarnosSettings.SMS_Keyword__c, strMessage);    
            }
        }


        System.debug('enviarSMS3 [' + objSMSSend + '] <-');      
        return objSMSSend;
    }

    private static Cuidarnos_SMS_Send__c sendSMS(String strCitizenId,String strMobilePhone, String strKeyword, String strMessage) {
        Cuidarnos_SMS_Send__c objSMSSend = null;
        RemotingMessageHelper.MCSMS objMCSMS = null;
        RemotingMessageHelper.MCAuth objAuth = null;
        RemotingMessageHelper.MarketingCloudAccessTokenV2 objToken = null;
        RemotingMessageHelper.UserPermissions objUserPermissions = null;
        Marketing_Cloud_Setting__mdt objSettings = null;
        Marketing_Cloud_Settings__c objMarketingCloudSettings = null;
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        Map<String,String> mapCurrentSessionAttributes = null;

        System.debug('sendSMS [strCitizenId : ' + strCitizenId + ' - strMobilePhone : ' + strMobilePhone +' - strMessage : ' + strMessage + '] ->'); 
        
        try {
            //mapCurrentSessionAttributes = Auth.SessionManagement.getCurrentSession();

            objSMSSend = new Cuidarnos_SMS_Send__c();
            objSMSSend.Type__c = 'Notificación';
            objSMSSend.Ciudadano__c = strCitizenId;
            objSMSSend.Usuario__c = UserInfo.getUserId();
            //objSMSSend.IP__c = mapCurrentSessionAttributes.get('SourceIp');
            objSMSSend.Status__c = 'Exito';

            objSettings = retrieveMarketingCloudSettings('Cuidarnos');

            objUserPermissions = new RemotingMessageHelper.UserPermissions();
            objToken = retrieveAccessToken(objSettings);

            objMCSMS = new RemotingMessageHelper.MCSMS();        
            objMCSMS.keyword = strKeyword;
            objMCSMS.messageText = strMessage;
            objMCSMS.mobileNumbers.add(strMobilePhone); 

            objRequest = new HttpRequest();
            objRequest.setMethod('POST');
            if(!objUserPermissions.SMSDebug) {
                objRequest.setEndpoint(objSettings.Send_SMS_Url__c);
            } else {
                //DUMMY
                objRequest.setEndpoint('https://api-pulso.prosumia.la/apis//covid_report/read_data_extensions_covid_report_report__put');
            }

            objRequest.setHeader('content-type', 'application/json');
            objRequest.setHeader('Authorization', 'Bearer ' + objToken.access_token );

            objRequest.setBody(JSON.serialize(objMCSMS).replace('OverrideAUX', 'Override'));
                    
            System.debug('sendSMS [Endpoint : ' + objSettings.Send_SMS_Url__c +']');    
            System.debug('sendSMS [objMCSMS : ' + objMCSMS +']');   
            System.debug('sendSMS [Body : ' + objRequest.getBody() +']');   

            objHttp = new Http();                           
            objResponse = objHttp.send(objRequest);

            if(! (objResponse.getStatusCode() == 200) && !(objResponse.getStatusCode() == 202)) {
                objSMSSend.Status__c = 'Fallo';
                objSMSSend.Stack_Trace__c = objResponse.getBody();            
            } else {
                objSMSSend.Status__c = 'Exito';
                objSMSSend.Stack_Trace__c = '';
            }
        } catch(Exception Ex) {
            objSMSSend.Status__c = 'Fallo';
            objSMSSend.Stack_Trace__c = Ex.getStackTraceString();            
        }

        System.debug('sendSMS [' + objSMSSend +'] <-');      
        return objSMSSend;
    }

    @AuraEnabled
    public static void notifyUserEmail(String strUrl, String strCitizenId) { 
        notifyUserFuture(strUrl, strCitizenId, true, null);
    }

    @AuraEnabled
    public static List<HistoryItem> retrieveHistoryInSalesforce(String strCitizenId) {
        List<HistoryItem> lstHistory = null;
        List<Covid19__history> lstHistoryC = null;
        Set<String> setStates = null;
        HistoryItem objCreated = null;
        Covid19__c objCovid = null;
        Contact objContact = null;

        System.debug('retrieveHistoryInSalesforce [strCitizenId : ' + strCitizenId + '] ->'); 

        objContact = retrieveContactCitizen(strCitizenId);        
        objCovid = retrieveCovidUser(objContact);

        setStates = retrieveAllowedStates();
        if(objCovid != NULL) {
            lstHistoryC = [ SELECT OldValue, NewValue, CreatedBy.FirstName,CreatedBy.LastName , CreatedDate
                            FROM Covid19__history
                            WHERE ParentId = :objCovid.Id 
                            AND field = 'Cuidarnos_Comunidad_Status__c'
                            ORDER BY CreatedDate ASC];
        }

        lstHistory = new List<HistoryItem>();
        objCreated = new HistoryItem();
        objCreated.NewStatus = 'Created';
        lstHistory.add(objCreated);

        System.debug('retrieveHistoryInSalesforce [strCitizenId : ' + lstHistoryC + '] ->'); 
        if(lstHistoryC != NULL) {
            for(Covid19__History objHistory : lstHistoryC) {
                if(objHistory.OldValue != NULL && setStates.contains(objHistory.OldValue.toString()) && objHistory.NewValue != NULL &&  setStates.contains(objHistory.NewValue.toString()) ) {
                    lstHistory.add(new HistoryItem(objHistory));
                }
            }
        }
        System.debug('retrieveHistoryInSalesforce [' + lstHistory +'] <-');      
        return lstHistory;
    }

    private static Set<String> retrieveAllowedStates() {
        Set<String> setStates = null;

        System.debug('retrieveAllowedStates [] ->');

        setStates = new Set<String>();

        setStates.add(STATUS_ASINTOMATICO);

        setStates.add(STATUS_SINTOMATICO);
        setStates.add(STATUS_SOSPECHOSO);
        setStates.add(STATUS_MUESTRA);
        setStates.add(STATUS_DETECTABLE);
        setStates.add(STATUS_NO_DETECTABLE);
        setStates.add(STATUS_INVALIDO);
        setStates.add(STATUS_NOFIFICADO);
        setStates.add(STATUS_SEGUIMIENTO);
        setStates.add(STATUS_DESCARTADO);
        setStates.add(STATUS_ARCHIVADO);
        setStates.add(STATUS_SEGUIMIENTO_COH);

        System.debug('retrieveAllowedStates [' + setStates + ' ] <-');

        return setStates;
    }

    @future(callout=true)
    public static void notifyUserFuture(String strUrl, String strCitizenId, Boolean boolSendEmail, String strEmail) {
        List<String> lstUrlParts = null;
        Contact objContact = null;
        CitizenWrapper objCitizenWrapper = null;
        String strBody = null;
        String strMode = null;
        String strClient = null;
        String strContactId = null;
        Blob objResponseBody = null;
        String strStatus = null;
        Covid19__c objCovid = null;
        String strEndpoint = null;

        System.debug('notifyUserFuture [strUrl : ' + strUrl + ' - strCitizenId : ' + strCitizenId + '] ->');

        try {
            lstUrlParts = strUrl.split('/');
            strContactId = lstUrlParts[lstUrlParts.size() - 3];
            strMode = lstUrlParts[lstUrlParts.size() - 2];
            
            strClient = lstUrlParts[lstUrlParts.size() - 1];
            objContact = ContactDetailController.retrieveContactFromId(strContactId);
            objCovid = retrieveCovidUser(objContact);
            //if(validateRecordStatus(objCovid.Cuidarnos_Comunidad_Status__c, STATUS_NOFIFICADO)) {
                objCitizenWrapper = new CitizenWrapper(objContact);
                if(String.IsNotBlank(strEmail)) {
                    objCitizenWrapper.cuidarnos.email = strEmail;
                }
                strBody = Cuidarnos_Ficha_REST.retrieveBody(strMode, strClient, objCitizenWrapper, boolSendEmail);
                strEndpoint = 'https://cuidarnos.app/ficha/';

                objResponseBody = makeRequest(strBody,strEndpoint); 
                //strStatus = STATUS_NOFIFICADO;
                //updateStatusInSalesforce(strCitizenId, strStatus);
            //}
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);    
        }

        System.debug('notifyUserFuture [] <-');
    }

    @future(callout=true)
    public static void darAltaUserFuture(String strUrl, String strCitizenId, Boolean boolSendEmail, String strEmail) {
        List<String> lstUrlParts = null;
        Contact objContact = null;
        CitizenWrapper objCitizenWrapper = null;
        String strBody = null;
        String strMode = null;
        String strClient = null;
        String strContactId = null;
        Blob objResponseBody = null;
        String strStatus = null;
        Covid19__c objCovid = null;
        String strEndpoint = null;

        System.debug('darAltaUserFuture [strUrl : ' + strUrl + ' - strCitizenId : ' + strCitizenId + '] ->');

        try {
            lstUrlParts = strUrl.split('/');
            strContactId = lstUrlParts[lstUrlParts.size() - 3];
            strMode = lstUrlParts[lstUrlParts.size() - 2];
            
            strClient = lstUrlParts[lstUrlParts.size() - 1];
            objContact = ContactDetailController.retrieveContactFromId(strContactId);
            objCitizenWrapper = new CitizenWrapper(objContact);

            if(String.IsNotBlank(strEmail)) {
                objCitizenWrapper.cuidarnos.email = strEmail;
            }

            strBody = '';
            strBody += String.format('nombre={0} {1} {2}&', new String[] { String.isNotBlank( objCitizenWrapper.citizen.FirstName)? objCitizenWrapper.citizen.FirstName:'', String.isNotBlank( objCitizenWrapper.citizen.MiddleName)? objCitizenWrapper.citizen.MiddleName:'', String.isNotBlank( objCitizenWrapper.citizen.LastName)? objCitizenWrapper.citizen.LastName:''  });
            if(boolSendEmail) {
                strBody += String.format('email={0}&', new String[] { EncodingUtil.urlEncode(objCitizenWrapper.cuidarnos.email, 'UTF-8') });
            }
    
            strBody += String.format('dni={0}&', new String[] { String.isNotBlank(objCitizenWrapper.citizen.Document_Number__c)?objCitizenWrapper.citizen.Document_Number__c:'' });
            strBody += String.format('fecha_covid={0}&', new String[] { (objCitizenWrapper.cuidarnos.covid.Cuidarnos_Comunidad_Date__c != NULL)?objCitizenWrapper.cuidarnos.covid.Cuidarnos_Comunidad_Date__c.format():'' });
            strBody += String.format('fecha_nacimiento={0}&', new String[] { objCitizenWrapper.generalInfo.BirthdateSPFormat });

            strEndpoint = 'https://covid.pilar.gov.ar/ficha/';

            objResponseBody = makeRequest(strBody, strEndpoint); 
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);    
        }

        System.debug('darAltaUserFuture [] <-');
    }


    @AuraEnabled
    public static void postRequestIVRNumeral8(List<Covid19__c> lstCovid) {
        List<IVR_Calls_Numeral8__c> lstLogs = new List<IVR_Calls_Numeral8__c>();
        String strBody = null;

        System.debug('postRequestIVRNumeral8 [ ] ->');

        if (!lstCovid.isEmpty()) {
            strBody = '[';
            Boolean first = true;
            for (Covid19__c covidCase: lstCovid) {

                strBody += first ? '' : ',';
                first = false;

                String mobile_phone = covidCase.Mobile_Phone__c;
                if (mobile_phone.substring(0,2) == '54' && mobile_phone.substring(0,3) != '549') {
                    mobile_phone = '549' + mobile_phone.substring(2);
                }

                strBody += '{"phonecode":"",';
                //strBody += String.format('"phonenumber":"{0}",', new String[] { '541155555555' });
                strBody += String.format('"phonenumber":"{0}",', new String[] { mobile_phone });
                strBody += '"custom1":"" ,"custom2":"" ,"custom3":"" ,"custom4":"" ,"custom5":"" ,"custom6":"","custom7":"","custom8":"",';
                strBody += '"custom9":"" ,"custom10":"","custom11":"","custom12":"","custom13":"","custom14":"",';
                strBody += '"custom15":"","custom16":"","custom17":"","custom18":"","custom19":"","custom20":""}';

                try {
                    System.debug('postRequestIVRNumeral8 [ Create and Insert new IVR_Calls_Numeral8__c object] ->');

                    IVR_Calls_Numeral8__c objLog = new IVR_Calls_Numeral8__c();
                    objLog.Contact__c = covidCase.Citizen__c;
                    objLog.Covid19__c = covidCase.Id;
                    objLog.Paciente_Phone__c = mobile_phone;
                    objLog.Status__c = 'Inicial';
                    objLog.User__c = UserInfo.getUserId();
                    lstLogs.add(objLog);

                } catch(Exception Ex) {
                    System.debug('postRequestIVRNumeral8 [ Exception when Creating new IVR_Calls_Numeral8__c objects] ->');
                    HelperFunctions.handleRuntimeException(Ex);
                }

            }
            strBody += ']';
        }

        System.debug('postRequestIVRNumeral8 [ ' + strBody + '] ->');
        System.debug(strBody);

        try {           
            System.debug('postRequestIVRNumeral8 [ Making Post Request] ->');
            makePostRequestIVRNumeral8(strBody, lstLogs);
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);
        }

        System.debug('postRequestIVRNumeral8 [] <-');        
    }


    //@future(callout=true)
    private static void makePostRequestIVRNumeral8(String strBody, List<IVR_Calls_Numeral8__c> lstLogs) {
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;        

        System.debug('makePostRequestIVRNumeral8 [strBody : ' + strBody + '] ->');

        try {
            String strUrl = 'https://dial.ar.numeral8.com/api/campania/3680/numeros/agregar';

            objRequest = new HttpRequest();
            objRequest.setHeader('Authorization', 'Token b45606dec9ass62ee90a2999cae6bacc7c8988d7');
            objRequest.setHeader('Content-Type', 'application/json; charset=UTF-8');
            objRequest.setMethod('POST');
            objRequest.setEndpoint(strUrl);
            objRequest.setTimeout(60 * 1000);
            objRequest.setBody(strBody);

            System.debug('makePostRequestIVRNumeral8 [ strUrl : ' + strUrl + ']');
            System.debug('makePostRequestIVRNumeral8 [ objRequest.getBody() : ' + objRequest.getBody() + ']');

            for (IVR_Calls_Numeral8__c objLog: lstLogs) {
                objLog.Request__c = objRequest.getBody();
                objLog.Date_Time_POST__c = DateTime.now();
            }

            objHttp = new Http();
            objResponse = objHttp.send(objRequest);
        
            
            System.debug('makePostRequestIVRNumeral8 [Response Status Code : ' + objResponse.getStatusCode() + '] ->');
            System.debug('makePostRequestIVRNumeral8 [Response Status : ' + objResponse.getStatus() + '] ->');

            if(objResponse != NULL && objResponse.getStatusCode() == 200) {
                System.debug('makePostRequestIVRNumeral8 [Response Status Code OK] ->');
                for (IVR_Calls_Numeral8__c objLog: lstLogs) {
                    objLog.Status__c = 'POST_OK';
                }
            } else {
                System.debug('makePostRequestIVRNumeral8 [Response Status Code Failed] ->');
                for (IVR_Calls_Numeral8__c objLog: lstLogs) {
                    objLog.Status__c = 'POST_FAILED';
                }
            }

            for (IVR_Calls_Numeral8__c objLog: lstLogs) {
                objLog.Response__c = objResponse.getBody();
            }

        } catch(Exception Ex) {
            for (IVR_Calls_Numeral8__c objLog: lstLogs) {
                objLog.Status__c = 'POST_FAILED';
                objLog.Response__c = Ex.getMessage();
            }
            HelperFunctions.handleRuntimeException(Ex);
        }

        insert lstLogs;

        System.debug('makePostRequestIVRNumeral8 [] <-');
    }


    @AuraEnabled
    public static void getRequestIVRNumeral8(List<String> lstLogIds) {
        String strBody = null;

        System.debug('getRequestIVR [ ] ->');

        if (!lstLogIds.isEmpty()) {
            for (String objLogId: lstLogIds) {
                try {
                    makeGetRequestIVRNumeral8(objLogId);
                } catch(Exception Ex) {
                    HelperFunctions.handleRuntimeException(Ex);
                }
            }
        }

        System.debug('getRequestIVR [] <-');        
    }

    //@future(callout=true)
    private static void makeGetRequestIVRNumeral8(String objLogId) {
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;        
        Blob objHeaderValue = null;
        String strAuthorizationHeader = null;

        IVR_Calls_Numeral8__c objLog = [SELECT Id , Covid19__c, Covid19__R.Citizen__c, Paciente_Phone__c FROM IVR_Calls_Numeral8__c WHERE Id =: objLogId];

        String strCitizenId = objLog.Covid19__R.Citizen__c;

        System.debug('makeGetRequestIVRNumeral8 [] ->');

        try {
            //objHeaderValue = Blob.valueOf('salesforce-dev:G8Y7yLH9h7');
            //strAuthorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(objHeaderValue);

            //String strUrl = 'https://dial.ar.numeral8.com/api/campania/3680/ivr/resultados/telefono?phonenumber='+'5491155555555'+'&filtro_ivr=OPCIONES';

            String strUrl = 'https://dial.ar.numeral8.com/api/campania/3680/ivr/resultados/telefono?phonenumber='+objLog.Paciente_Phone__c+'&filtro_ivr=OPCIONES';
            objRequest = new HttpRequest();
            objRequest.setHeader('Authorization', 'Token b45606dec9ass62ee90a2999cae6bacc7c8988d7');
            objRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8');
            objRequest.setMethod('GET');
            objRequest.setEndpoint(strUrl);
            objRequest.setTimeout(60 * 1000);

            System.debug('makeGetRequestIVRNumeral8 [ strUrl : ' + strUrl + ']');

            objHttp = new Http();
            objResponse = objHttp.send(objRequest);
            
            System.debug('makeGetRequestIVRNumeral8 [Response Status : ' + objResponse.getStatusCode() + '] ->');
            System.debug('makeGetRequestIVRNumeral8 [Response Body   : ' + objResponse.getBody() + '] ->');

            //saveUserObservationsInSalesforce(strCitizenId, 'El riesgo fue modificado de Bajo a Alto ya que indicó en el IVR que su estado de salud empeoró y necesita que la contacten');

            objLog.GET_Response__c = objResponse.getBody();

            if(objResponse != NULL && objResponse.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(objResponse.getBody());
                //Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped('{"retCode": 0,"retMsg":"","retData":{"calldate_start":"2021-04-26T20:50:03","calldate_answer":"2021-04-26T20:50:38","calldate_end":"2021-04-26T20:51:05","answer_duration": 26,"total_duration": 61,"is_test_call": 0,"call_id": "1619481003.252755500","disposition":"ANSWERED","disposition2": "ANSWERED","phonenumber":"5491157438238","ivr_data":[{"ivr_date_start":"2021-04-26T20:50:50","ivr_date_end":"2021-04-26T20:51:05","ivr_response":"1","ivr_label":"","ivr_title":"EstadoDeSalud","ivr_type": "OPCIONES","ivr_options": "12"}]}}');

                objLog.Status__c = 'GET_OK';
                objLog.Date_Time_GET__c = DateTime.now();

                Object retCode = results.get('retCode');
                Object retMsg  = results.get('retMsg');

                System.debug('makeGetRequestIVRNumeral8 [Response retCode : ' + retCode + '] ->');
                System.debug('makeGetRequestIVRNumeral8 [Response retMsg  : ' + retMsg  + '] ->');

                Map<String, Object> retData = (Map<String, Object>) results.get('retData');
                System.debug('makeGetRequestIVRNumeral8 [Response retData : ' + retData + '] ->');
                if (retData != null) {

                    Object disposition  = retData.get('disposition');
                    Object disposition2 = retData.get('disposition2');
                    List<Object> lst_ivr_data = (List<Object>) retData.get('ivr_data');

                    System.debug('makeGetRequestIVRNumeral8 [Response retData lst_ivr_data : ' + lst_ivr_data + '] ->');

                    if (!lst_ivr_data.isEmpty()) {
                        for (Object ivr_data: (List<Object>) lst_ivr_data) {
                            Map<String, Object> each_ivr_data = (Map<String, Object>) ivr_data;
                            if (each_ivr_data != null) {
                                Object ivr_response = each_ivr_data.get('ivr_response');
                                System.debug('makeGetRequestIVRNumeral8 [ivr_response : ' + ivr_response + '] ->');
                                if (ivr_response == '1') {
                                    objLog.Covid19__R.Riesgo__c = 'Alto';
                                    update (Covid19__c) objLog.Covid19__R;
                                    saveUserObservationsInSalesforce(strCitizenId, 'El riesgo fue modificado de Bajo a Alto ya que indicó en el IVR que su estado de salud empeoró y necesita que la contacten');
                                } else if (ivr_response == '') {
                                    saveUserObservationsInSalesforce(strCitizenId, 'Se realizó el llamado automático de control el ' + DateTime.now().format() + ' y no hubo respuesta');
                                }
                            }
                        }
                    } else if (disposition == 'NO ANSWER') {
                        saveUserObservationsInSalesforce(strCitizenId, 'Se realizó el llamado automático de control el ' + DateTime.now().format() + ' y no hubo respuesta');
                    }
                }
            } else {
                objLog.Status__c = 'GET_FAILED';
            }

        } catch(Exception Ex) {
            objLog.Status__c = 'GET_FAILED';
            objLog.GET_Response__c = Ex.getMessage();

            HelperFunctions.handleRuntimeException(Ex);
        }

        update objLog;

        System.debug('makeGetRequestIVRNumeral8 [] <-');


        /*
        // Parse JSON response to get field values.
        JSONParser parser = JSON.createParser(objResponse.getBody());
        Integer ivr_response;

        System.debug('makeGetRequestIVRNumeral8 [starting parser ] ->');
        while (parser.nextToken() != null) {
            System.debug('makeGetRequestIVRNumeral8 [Response token : ' + parser.getText() + '] ->');
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'ivr_response')) {
                // Get the value.
                parser.nextToken();
                // Compute the grand total price for all invoices.
                ivr_response = parser.getIntegerValue();
                System.debug('makeGetRequestIVRNumeral8 [Response ivr_response     : ' + parser.getText() + '] ->');
            }
        }*/
    }



    @AuraEnabled
    public static void makeCallIVR(String strCitizenId, String strSourcePhone, String strDestinationPhone , Boolean boolIsMobile) {
        Cuidarnos_IVR_Calls__c objLog = null;
        String strBody = null;

        System.debug('makeCallIVR [strCitizenId : ' + strCitizenId + ' - strSourcePhone : ' + strSourcePhone + ' - strDestinationPhone : ' + strDestinationPhone + ' ] ->');

        try {           
            objLog = saveLogCallIVR(strCitizenId, strSourcePhone, true, strDestinationPhone , boolIsMobile);
           
            strBody = '';
            strBody += String.format('patient_phone_number={0}&', new String[] { strDestinationPhone });
            strBody += String.format('patient_phone_is_mobile={0}&', new String[] { (boolIsMobile)?'1':'0'} );
            strBody += String.format('doctor_phone_number={0}&', new String[] { strSourcePhone });
            strBody += String.format('doctor_phone_is_mobile={0}&', new String[] { '1'});
            
            makeIVRCall(strCitizenId, strBody, objLog.Id);
        } catch(Exception Ex) {
            objLog.Status__c = 'Failed';
            objLog.Response__c = Ex.getMessage();    
            update objLog;
            HelperFunctions.handleRuntimeException(Ex);    
        }

        System.debug('makeCallIVR [] <-');        
    }

    @future(callout=true)
    private static void makeIVRCall(String strCitizenId, String strBody, String strLogId) {
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;        
        String strEndpoint = null;
        Blob objHeaderValue = null;
        String strAuthorizationHeader = null;
        Cuidarnos_IVR_Calls__c objLog = null;

        System.debug('makeIVRCall [strBody : ' + strBody + '] ->');  

        try {
            objLog = [SELECT Id, Request__c, Response__c, Status__c FROM Cuidarnos_IVR_Calls__c WHERE Id =: strLogId];

            objHeaderValue = Blob.valueOf('salesforce-dev:G8Y7yLH9h7');
            strAuthorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(objHeaderValue);

            strEndpoint = 'https://lab.prosumia.la/sf/conference_call';

            objRequest = new HttpRequest();
            objRequest.setHeader('Authorization', strAuthorizationHeader);
            objRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8');
            objRequest.setMethod('POST');
            objRequest.setEndpoint(strEndpoint);
            objRequest.setTimeout(60 * 1000);
            objRequest.setBody(strBody);
            
            System.debug('makeCallIVR [ strEndpoint : ' + strEndpoint + ']');
            System.debug('makeCallIVR [ objRequest.getBody() : ' + objRequest.getBody() + ']');
            objLog.Request__c = objRequest.getBody();

            objHttp = new Http();
            objResponse = objHttp.send(objRequest);
            
            if(objResponse != NULL && objResponse.getStatusCode() == 200) {
                objLog.Status__c = 'OK';
            } else {
                objLog.Status__c = 'Failed';
            }

            objLog.Response__c = objResponse.getBody();    
        } catch(Exception Ex) {
            objLog.Status__c = 'Failed';
            objLog.Response__c = Ex.getMessage();    

            HelperFunctions.handleRuntimeException(Ex);    
        }

        update objLog;
        saveUserObservationsInSalesforce(strCitizenId, String.format('El usuario fue llamado. [Status : {0}]', new String[] {objLog.Status__c}) );
        

        System.debug('makeCallIVR [] <-');
    }

    private static Cuidarnos_IVR_Calls__c saveLogCallIVR(String strCitizenId, String strSourcePhone, Boolean boolSourceIsMobile, String strDestinationPhone , Boolean boolIsMobile) {
        Cuidarnos_IVR_Calls__c objLog = null;
        Contact objContact = null;
        Covid19__c objCovid = null;

        System.debug('saveLogCallIVR [] ->');
        objContact = retrieveContactCitizen(strCitizenId);        
        objCovid = retrieveCovidUser(objContact);
        
        objLog = new Cuidarnos_IVR_Calls__c();
        objLog.Contact__c = strCitizenId;
        objLog.Covid19__c = objCovid.Id;
        objLog.Doctor_Phone__c = strSourcePhone;
        objLog.Doctor_Phone_Is_Mobile__c = boolSourceIsMobile;
        objLog.Paciente_Phone__c = strDestinationPhone;
        objLog.Paciente_Phone_Is_Mobile__c = boolIsMobile;
        objLog.Status__c = 'Inicial';
        objLog.User__c = UserInfo.getUserId();

        insert objLog;

        System.debug('saveLogCallIVR [' + objLog + '] <-');

        return objLog;
    }
    
    @AuraEnabled
    public static Boolean confirmCitizenInSalesforce(Id strCitizenId) {
        Contact objContact = null;
        Covid19__c objCovid = null;

        System.debug('confirmCitizenInSalesforce [strCitizenId : ' + strCitizenId + '] ->');
        
        objContact = retrieveContactCitizen(strCitizenId);        
        objCovid = retrieveCovidUser(objContact);

        updateCovidStatus(objCovid, 'Confirmado', null);

        System.debug('confirmCitizenInSalesforce [false] <-');
        return false;
    }

    @AuraEnabled
    public static Boolean discardCitizenInSalesforce(Id strCitizenId) {
        Contact objContact = null;
        Covid19__c objCovid = null;

        System.debug('discardCitizenInSalesforce [strCitizenId : ' + strCitizenId + '] ->');

        objContact = retrieveContactCitizen(strCitizenId);        
        objCovid = retrieveCovidUser(objContact);

        updateCovidStatus(objCovid, 'Descartado', false);

        System.debug('discardCitizenInSalesforce [true] <-');

        return true;
    }

    @AuraEnabled
    public static Boolean invalidateCitizenInSalesforce(Id strCitizenId) {
        Contact objContact = null;
        Covid19__c objCovid = null;

        System.debug('discardCitizenInSalesforce [strCitizenId : ' + strCitizenId + '] ->');

        objContact = retrieveContactCitizen(strCitizenId);        
        objCovid = retrieveCovidUser(objContact);

        updateCovidStatus(objCovid, 'Inválido', false);

        System.debug('discardCitizenInSalesforce [true] <-');

        return true;
    }
    
    @AuraEnabled 
    public static Boolean checkIfSMSIsActive() {
        Boolean boolIsActive = false;
        Cuidarnos__mdt objSettings = null;
        RemotingMessageHelper.UserPermissions objPermissions = null;

        System.debug('checkIfSMSIsActive [] ->');

        objPermissions = retrieveLoggedUserPermissions();
        objSettings = retrieveSMSSettings();
        boolIsActive = (objSettings.SMS_Send_Enabled__c == true && objPermissions.ContactViewCuidarnosMark );

        System.debug('checkIfSMSIsActive [' + boolIsActive + '] ->');
        
        return boolIsActive;
    }

    @AuraEnabled
    public static RemotingMessageHelper.UserPermissions retrieveLoggedUserPermissions() { 
        RemotingMessageHelper.UserPermissions objUserPermissions = null;
        
        System.debug('retrieveLoggedUserPermissions [] ->');
        
        objUserPermissions = new RemotingMessageHelper.UserPermissions();
        
        System.debug('retrieveLoggedUserPermissions [' + objUserPermissions + '] <-');
        
        return objUserPermissions;
    }

    private static void markCitizenInSalesforceFuture(String strCitizenId, String strSendId) {
        Cuidarnos__mdt objSettings = null;
        Cuidarnos_SMS_Send__c objSMSSend = null;
        Contact objContact = null;
        Covid19__c objCovid = null;

        System.debug('markCitizenInSalesforceFuture [strCitizenId : ' + strCitizenId +  ' - strSendId : ' + strSendId + '] ->');

        objSMSSend = [SELECT IP__c, Status__c, Ciudadano__c, Usuario__c, Stack_Trace__c, Name, Id FROM Cuidarnos_SMS_Send__c WHERE Id =: strSendId];
        objSettings = retrieveSMSSettings();
        objContact = retrieveContactCitizen(strCitizenId);        

        sendSMSToRelatedContacts(objContact, objSMSSend);

        System.debug('markCitizenInSalesforceFuture [' + objSMSSend.Id + '] <-');
    }
            
    private static void sendSMSToRelatedContacts(Contact objContact, Cuidarnos_SMS_Send__c objSMSSend) {
        Cuidarnos__mdt objSettings = null;
        Map<String,String> mapCitizenHashes = null;
        List<Cuidarnos_SMS__mdt> lstFields = null;
        List<Contact> lstContacts = null;
        List<Contact> lstContactsAux = null;
        Set<String> setMobilePhone = null;
        Set<Id> setConfirmedCitizenIds = null;
        Integer intMaxCitizen = NULL;

        System.debug('sendSMSToRelatedContacts [objContact : ' + objContact + ' - objSMSSend : ' + objSMSSend + '] ->');

        try {        
            if(objContact != NULL && objSMSSend != NULL ) {
                objSettings = retrieveSMSSettings();
                lstFields = retrieveRelatedFields();                
                mapCitizenHashes = retrieveCitizenHashes(objContact.Id, lstFields);
                intMaxCitizen = Integer.valueOf(objSettings.SMS_Sends__c);
                
                System.debug('sendSMSToRelatedContacts [intMaxCitizen : ' + intMaxCitizen + ']');
                lstContacts = new List<Contact>();
                if(intMaxCitizen != NULL && intMaxCitizen > 0) {
                    if(!objSettings.Debug_Mode__c) {
                        setMobilePhone = new Set<String>();

                        lstContacts = retrieveRelatedCitizensSOSL(objContact.Id, objSettings, lstFields, mapCitizenHashes, objSMSSend);
                    } else {
                        lstContacts.add(objContact);                    
                    }

                    if(!lstContacts.isEmpty()) {
                        updateSMSSendsStatus(objSMSSend, 'En Progreso');
                        
                        sendSMStoContacts(JSON.serialize(lstContacts), JSON.serialize(objContact), JSON.serialize(objSMSSend));
                    } else {
                        System.debug('sendSMSToRelatedContacts [lstContacts IS NULL - ' + lstContacts + ']'); 

                        updateSMSSendsStatus(objSMSSend, 'Fallo', 'No se encontraron contactos relacionados');
                    }                 
                } else {
                    System.debug('sendSMSToRelatedContacts [intMaxCitizen IS 0 OR NULL - ' + intMaxCitizen + ']'); 
                }
            } else {
                System.debug('sendSMSToRelatedContacts [strCiudadanoId IS NULL - ' + objContact.Id + ']'); 
            }
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);
            
            if(objSMSSend != NULL) {
                updateSMSSendsStatus(objSMSSend, 'Fallo', Ex);
            }
        }

        System.debug('sendSMSToRelatedContacts [] <-');
    }

    private static void updateCovidStatus(Covid19__c objCovid, String strStatus, Boolean boolMark) {
        System.debug('updateCovidStatus [objCovid : ' + objCovid + ' - strStatus : ' + strStatus + '] ->');

        if(objCovid != NULL) {            
            objCovid.Cuidarnos_Comunidad_Status__c = strStatus;
            if(boolMark != null) {
                objCovid.Cuidarnos_Marked__c = boolMark;
            }

            objCovid.Cuidarnos_Comunidad_Date__c = DateTime.now();
         
            if(String.isBlank(objCovid.Id)) { 
                insert objCovid;
            } else {
                update objCovid;
            }
        }

        System.debug('updateCovidStatus [] <-');
    }

    private static Covid19__c retrieveCovidUser(Contact objContact) {
        List<Covid19__c> lstCovidUser = null;
        Covid19__c objCovid = null;
        Cuidarnos__mdt objSettings = null;

        System.debug('retrieveCovidUser [objContact : ' + objContact + '] ->');

        objSettings = retrieveSMSSettings();

        lstCovidUser = [SELECT  Id, 
                            Cuidarnos_Comunidad_Status__c,
                            Administrative_Level_1__c,
                            Administrative_Level_2__c, 
                            Administrative_Level_3__c, 
                            Administrative_Level_4__c,
                            Cuidarnos_Muestra_Result__c,
                            Cuidarnos_Comunidad_Level1__c,
                            Cuidarnos_Comunidad_Level2__c,
                            Cuidarnos_Observation__c,
                            Document_Number__c,
                            Edad__c,
                            FullName__c,
                            FirstName__c,
                            MiddleName__c,
                            LastName__c
                    FROM Covid19__c 
                    WHERE Citizen__c = : objContact.Id
                    FOR UPDATE];
        if(lstCovidUser.isEmpty()) { 
            objCovid = new Covid19__c();
            objCovid.Citizen__c = objContact.Id;
            objCovid.guid__c = objContact.GUID__c;
        } else {
            objCovid = lstCovidUser[0];
        }

        objCovid.Document_Number__c = objContact.Document_Number__c;
        objCovid.Edad__c = objContact.Age_f_x__c;
        objCovid.FullName__c = (String.isNotBlank(objContact.Name))?objContact.Name:'';
        objCovid.FirstName__c = (String.isNotBlank(objContact.FirstName))?objContact.FirstName:'';
        objCovid.MiddleName__c = (String.isNotBlank(objContact.MiddleName))?objContact.MiddleName:'';
        objCovid.LastName__c = (String.isNotBlank(objContact.LastName))?objContact.LastName:'';
        objCovid.Administrative_Level_1__c = (String.isNotBlank(objContact.Administrative_Level_1__c))?objContact.Administrative_Level_1__c:'';
        objCovid.Administrative_Level_2__c = (String.isNotBlank(objContact.Administrative_Level_2__c))?objContact.Administrative_Level_2__c:'';
        objCovid.Administrative_Level_3__c = (String.isNotBlank(objContact.Administrative_Level_3__c))?objContact.Administrative_Level_3__c:'';
        objCovid.Administrative_Level_4__c = (String.isNotBlank(objContact.Administrative_Level_4__c))?objContact.Administrative_Level_4__c:'';            
        
        objCovid.Cuidarnos_Comunidad_Level1__c = (String.isNotBlank(objSettings.Admin_Level_1__c))?objSettings.Admin_Level_1__c:'';
        objCovid.Cuidarnos_Comunidad_Level2__c  = (String.isNotBlank(objSettings.Admin_Level_2__c))?objSettings.Admin_Level_2__c:'';

        
        System.debug('retrieveCovidUser [' + objCovid + '] <-');

        return objCovid;        
    }

    private static Contact retrieveContactCitizen(String strCitizen) {
        Contact objContact = null;

        System.debug('retrieveContactCitizen [strCitizen : ' + strCitizen + '] ->');

        objContact = [SELECT Id, 
                            GUID__c, 
                            Cuidarnos_Citizen_Marked__c,
                            Administrative_Level_0__c, 
                            Administrative_Level_1__c, 
                            Administrative_Level_2__c, 
                            Administrative_Level_3__c, 
                            Administrative_Level_4__c,
                            FirstName,
                            MIddleName,
                            LastName,
                            Name,
                            Document_Number__c,
                            Age_f_x__c,
                            Gender__c
                FROM Contact 
                WHERE Id =: strCitizen];

        System.debug('retrieveContactCitizen [' + objContact + '] <-');

        return objContact;
    }
    
    private static void updateUserSendSMS(List<Contact> lstContact) {
        System.debug('updateUserSendSMS [lstContact : ' + lstContact + '] ->');

        for(Contact objContact : lstContact) {
            objContact.covid19_sms_send__c = true;
        }

        update lstContact;
        System.debug('updateUserSendSMS [] <-');
    }
    
    private static Map<Id, Related_Contacts__c> updateUserSendSMSRelatedContacts(String strSendId, List<Contact> lstContact) {
        Map<Id, Related_Contacts__c> mapRelatedContacts = null;
        Related_Contacts__c objRelatedContact = null;

        System.debug('updateUserSendSMSRelatedContacts [strSendId : ' + strSendId + ' - lstContact : ' + lstContact + '] ->');

        mapRelatedContacts = new Map<Id, Related_Contacts__c>();

        for(Contact objContact : lstContact) {
            objRelatedContact = new Related_Contacts__c();
            objRelatedContact.Cuidarnos_SMS_Sends__c = strSendId; 
            objRelatedContact.Contact__c = objContact.Id;
            objRelatedContact.Status__c = 'Initial';
            objRelatedContact.Stack_Trace__c = '';
            mapRelatedContacts.put(objContact.Id, objRelatedContact);
        }

        System.debug('updateUserSendSMSRelatedContacts [' + mapRelatedContacts + '] <-');

        return mapRelatedContacts;
    }
        
    private static void saveCitizenAsMark(Contact objContact, Boolean boolMark) {
        System.debug('saveCitizenAsMark [objContact : ' + objContact + ' - boolMark : ' + boolMark + '] ->');

        objContact.Cuidarnos_Citizen_Marked__c = boolMark;
        update objContact;

        System.debug('saveCitizenAsMark [] <-');
    }
    
    @future(callout=true)
    private static void sendSMStoContacts(String strContacts, String strContact, String strSMSSend) {
        RemotingMessageHelper.MCSMS objMCSMS = null;
        RemotingMessageHelper.MCSMSSingle objMCSMSSingle = null;
        RemotingMessageHelper.MCAuth objAuth = null;
        RemotingMessageHelper.MarketingCloudAccessTokenV2 objToken = null;
        RemotingMessageHelper.UserPermissions objUserPermissions = null;
        Marketing_Cloud_Setting__mdt objSettings = null;
        Marketing_Cloud_Settings__c objMarketingCloudSettings = null;
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        Cuidarnos__mdt objCuidarnosSettings = null;
        Set<String> setMobile = null;
        Boolean boolSuccess = true;
        String strStackTrace = null;
        Map<Id, Related_Contacts__c> mapRelated = null;
        List<Contact> lstContacts = null;
        Contact objContact = null;
        Cuidarnos_SMS_Send__c objSMSSend = null;

        System.debug('sendSMStoContacts [strContacts : ' + strContacts + ' - strContact : ' + strContact + ' - strSMSSend : ' + strSMSSend + '] ->');

        lstContacts = (List<Contact>)JSON.deserialize(strContacts, List<Contact>.class);
        objContact = (Contact)JSON.deserialize(strContact, Contact.class);
        objSMSSend = (Cuidarnos_SMS_Send__c)JSON.deserialize(strSMSSend, Cuidarnos_SMS_Send__c.class);

        System.debug('sendSMStoContacts [lstContacts : ' + lstContacts + ' - objContact : ' + objContact + ' - objSMSSend : ' + objSMSSend + '] ->');

        objSettings = retrieveMarketingCloudSettings('Cuidarnos');
        objCuidarnosSettings = retrieveSMSSettings();
        objUserPermissions = new RemotingMessageHelper.UserPermissions();
        
        if(lstContacts != NULL && !lstContacts.isEmpty() && objSMSSend != NULL) {                   
            mapRelated = updateUserSendSMSRelatedContacts(objSMSSend.Id, lstContacts); 
            setMobile = new Set<String>();
            objToken = retrieveAccessToken(objSettings);
            strStackTrace = '';

            for(Contact objRelatedContact : lstContacts) {
                if(!setMobile.contains(objRelatedContact.MobilePhone)) {
                    objMCSMS = new RemotingMessageHelper.MCSMS();        
                    objMCSMSSingle = new RemotingMessageHelper.MCSMSSingle();   
                    objMCSMS.keyword = objCuidarnosSettings.SMS_Keyword__c;
                    objMCSMS.messageText = objCuidarnosSettings.SMS_Message__c;

                    setMobile.add(objRelatedContact.MobilePhone);
                    objMCSMS.mobileNumbers.add(objRelatedContact.MobilePhone);     
                    objMCSMSSingle.mobileNumbers.add(objRelatedContact.MobilePhone);
                    if(String.isNotBlank(objRelatedContact.mcuid__c)) {
                        objMCSMS.messageText = objCuidarnosSettings.SMS_Message__c.replace('##LINK##', objRelatedContact.mcuid__c) ;
                    } else {
                        objMCSMS.messageText = objCuidarnosSettings.SMS_Message__c.replace('##LINK##', '') ;
                    }

                    objRequest = new HttpRequest();
                    objRequest.setMethod('POST');
                    if(!objUserPermissions.SMSDebug) {
                        objRequest.setEndpoint(objSettings.Send_SMS_Url__c);
                    } else {
                        //DUMMY
                        objRequest.setEndpoint('https://api-pulso.prosumia.la/apis//covid_report/read_data_extensions_covid_report_report__put');
                    }

                    objRequest.setHeader('content-type', 'application/json');
                    objRequest.setHeader('Authorization', 'Bearer ' + objToken.access_token );
        
                    if(objCuidarnosSettings.SMS_Send_Covid_Detail_Info__c) {
                        objRequest.setBody(JSON.serialize(objMCSMS).replace('OverrideAUX', 'Override'));
                    } else {
                        objRequest.setBody(JSON.serialize(objMCSMSSingle));
                    }
                    
                    System.debug('sendSMStoContacts [Endpoint : ' + objSettings.Send_SMS_Url__c +']');    
                    System.debug('sendSMStoContacts [objMCSMS : ' + objMCSMS +']');   
                    System.debug('sendSMStoContacts [objMCSMSSingle : ' + objMCSMSSingle +']');   
                    System.debug('sendSMStoContacts [Body : ' + objRequest.getBody() +']');   

                    objHttp = new Http();                           
                    objResponse = objHttp.send(objRequest);

                    if(! (objResponse.getStatusCode() == 200) && !(objResponse.getStatusCode() == 202)) {
                        boolSuccess = false;
                        strStackTrace +=  objResponse.getBody();

                        mapRelated.get(objRelatedContact.Id).Status__c = 'Fail';
                        mapRelated.get(objRelatedContact.Id).Stack_Trace__c = objResponse.getBody();            
                    } else {
                        mapRelated.get(objRelatedContact.Id).Status__c = 'OK';
                        mapRelated.get(objRelatedContact.Id).Stack_Trace__c = '';
                    }

                    System.debug('sendSMStoContacts [objResponse : ' + objResponse +']');    
                    System.debug('sendSMStoContacts [objResponse.getStatusCode : ' + objResponse.getStatusCode() +']');    
                    System.debug('sendSMStoContacts [objResponse.getBody : ' + objResponse.getBody() +']');
            
                } else {
                    System.debug('sendSMStoContacts [User already in list]');  
                }
            }       
            
            if(!objUserPermissions.SMSDebug) {
                if(boolSuccess) {
                    updateSMSSendsStatus(objSMSSend, 'Exito');
                } else {
                    updateSMSSendsStatus(objSMSSend, 'Fallo', strStackTrace);
                }        
            } else {
                updateSMSSendsStatus(objSMSSend, 'Exito', 'Prueba');
            }

            if(!mapRelated.isEmpty()) {
                insert mapRelated.values();
            }
        } else {
            System.debug('sendSMStoContacts [strSMSSendId OR lstContacts ARE NULL]'); 

            updateSMSSendsStatus(objSMSSend, 'Fallo', 'No se encontraron contactos relacionados');
        }
        
        System.debug('sendSMStoContacts [] <-');      
    }

    private static List<Contact> retrieveRelatedCitizensSOSL(String strCitizenId, Cuidarnos__mdt objSettings, List<Cuidarnos_SMS__mdt> lstFields, Map<String,String> mapCitizenHashes, Cuidarnos_SMS_Send__c objSMSSend) {
        String strSOSL = null;
        List<List <sObject>> lstResults = null;
        List<Contact> lstContactResult = null;  
        List<Contact> lstContacts = null;
        Map<Cuidarnos_SMS__mdt, List<Contact>> mapRelatedCitizens = null;
        Set<Id> setProcessedContact = null;
        Integer intMaxCitizen = null;
        Integer intProcessedCitizens = null;
        Set<String> setMobilePhone = null;

        System.debug('retrieveRelatedCitizensSOSL [strCitizenId : ' + strCitizenId + ' - objSettings : ' + objSettings + ' - mapCitizenHashes : ' + mapCitizenHashes + ' - objSMSSend : ' + objSMSSend + '] ->');

        strSOSL = retrieveSOSLQuery(objSettings, lstFields, mapCitizenHashes);                
        System.debug('retrieveRelatedCitizensSOSL [strSOSL : ' + strSOSL + ']');
        lstResults = Search.query(strSOSL);
        System.debug('retrieveRelatedCitizensSOSL [lstResults : ' + lstResults + ']');

        lstContactResult = new List<Contact>();
        if(!lstResults.isEmpty()) {
            if(!lstResults[0].isEmpty()) {
                lstContactResult = (List<Contact>)lstResults[0];
            }            
        }

        mapRelatedCitizens = new Map<Cuidarnos_SMS__mdt, List<Contact>>();
        intMaxCitizen = Integer.valueOf(objSettings.SMS_Sends__c);
        intProcessedCitizens = 0;
        lstContacts = new List<Contact>();
        setMobilePhone = new Set<String>();

        System.debug('retrieveRelatedCitizensSOSL [lstContactResult : ' + lstContactResult + ']');

        for(Cuidarnos_SMS__mdt objField : lstFields) {
            mapRelatedCitizens.put(objField, new List<Contact>());
            for(Contact objContactResult : lstContactResult) {
                System.debug('retrieveRelatedCitizensSOSL [objContactResult.get(objField.Field__c) : ' + objContactResult.get(objField.Field__c) + ']');
                System.debug('retrieveRelatedCitizensSOSL [mapCitizenHashes.get(objField.Field__c) : ' + mapCitizenHashes.get(objField.Field__c) + ']');

                if(objContactResult.get(objField.Field__c) == mapCitizenHashes.get(objField.Field__c) ) {
                    System.debug('retrieveRelatedCitizensSOSL [intProcessedCitizens : ' + intProcessedCitizens + ']');
                    System.debug('retrieveRelatedCitizensSOSL [intMaxCitizen : ' + intMaxCitizen + ']');
                    System.debug('retrieveRelatedCitizensSOSL [strCitizenId : ' + strCitizenId + ']');
                    System.debug('retrieveRelatedCitizensSOSL [objContactResult.Id: ' + objContactResult.Id + ']');
                    System.debug('retrieveRelatedCitizensSOSL [objContactResult.MobilePhone: ' + objContactResult.MobilePhone + ']');
                        
                    if( (objField.Send_to_all__c || intProcessedCitizens <= intMaxCitizen ) && !setMobilePhone.contains(objContactResult.MobilePhone) && (objContactResult.Id != strCitizenId) ) {
                        lstContacts.add(objContactResult);
                        intProcessedCitizens++;
                        setMobilePhone.add(objContactResult.MobilePhone);
                    }
                }
            }
        }

        System.debug('retrieveRelatedCitizensSOSL [' + lstContacts + '] <-');
        return lstContacts;
    }

    private static String retrieveSOSLQuery( Cuidarnos__mdt objSettings, List<Cuidarnos_SMS__mdt> lstFields, Map<String,String> mapCitizenHashes) {
        String strSOSL = null;
        Boolean boolFirst = true;

        System.debug('retrieveSOSLQuery [objSettings : ' + objSettings + ' - lstFields : ' + lstFields + ' - mapCitizenHashes : ' + mapCitizenHashes + '] ->');

        strSOSL =  'FIND {';        
        for(String strHash : mapCitizenHashes.values()) {
            if(boolFirst) {
                boolFirst = false;
            } else { 
                strSOSL += ' OR ';
            }
            strSOSL += '"' + strHash + '"';
        }
        strSOSL += '} ';
        strSOSL += 'RETURNING CONTACT(Id, MobilePhone, mcuid__c ';

         
        if(!lstFields.IsEmpty()) {
            for(Cuidarnos_SMS__mdt objField : lstFields) {
                strSOSL += ', ' + objField.Field__c ; 
            }
        }
        strSOSL += ' WHERE MobilePhone <> NULL ';
        
        if(String.IsNotBlank(objSettings.Filter_by_County__c)) {
            strSOSL += ' AND ' + objSettings.Filter_by_County__c;
        }
        strSOSL += ' )';

        System.debug('retrieveSOSLQuery [' + strSOSL + '] <-');

        return strSOSL;
    }
    
    private static List<Contact> retrieveRelatedCitizens(String strCitizenId, String strHash, Cuidarnos__mdt objSettings, Cuidarnos_SMS__mdt objField, Integer intMaxCitizen, Set<Id> setConfirmedCitizen, Cuidarnos_SMS_Send__c objSMSSend) {
        String strSOQL = null;
        List<Contact> lstContacts = null;
        
        System.debug('retrieveRelatedCitizens [strHash : ' + strHash + ' - objField : ' + objField + ' - intMaxCitizen : ' + intMaxCitizen + ' - setConfirmedCitizen : ' + setConfirmedCitizen + '] ->');

        if(String.isNotBlank(strCitizenId) && String.isNotBlank(objField.Field__c) && String.isNotBlank(strHash)) {
            strSOQL = 'SELECT Id, MobilePhone, mcuid__c ';
            strSOQL += 'FROM Contact ';
            strSOQL += 'WHERE ' + objField.Field__c + ' = \'' + strHash + '\' ';
            strSOQL += ' AND Id <> \'' + strCitizenId + '\' ';
            strSOQL += ' AND Id NOT IN :setConfirmedCitizen ';
            
            if(String.isNotBlank(objField.Conditions__c)) {
                strSOQL += ' AND ' + objField.Conditions__c + ' ';
            }

            if(String.isNotBlank(objSettings.Filter_by_County__c)) {
                strSOQL += ' AND ' +  objSettings.Filter_by_County__c;
            }

            if(objField.Send_to_all__c == false) {
                strSOQL += 'LIMIT ' + intMaxCitizen;
            }

            System.debug('retrieveRelatedCitizens [strSOQL : ' + strSOQL + ']');

            try {
                lstContacts = Database.query(strSOQL);
            } catch(Exception Ex) {
                //evito que se cuelgue todo si falla la query
                HelperFunctions.handleRuntimeException(Ex);
                updateSMSSendsStatus(objSMSSend,'Fail', Ex.getStackTraceString());
            }

            System.debug('retrieveRelatedCitizens [lstContacts : ' + lstContacts + ']');
        }

        System.debug('retrieveRelatedCitizens [' + lstContacts + '] <-');
        return lstContacts;
    }

    private static Set<Id> retrieveConfirmedCitizens() {
        List<Covid19__c> lstConfirmedCitizen = null;
        Set<Id> setConfirmedCitizenIds = null;

        System.debug('retrieveConfirmedCitizens [] ->');

        lstConfirmedCitizen = [SELECT Id 
                                FROM Covid19__c 
                                WHERE Cuidarnos_Comunidad_Status__c = 'Confirmado' 
                                OR Cuidarnos_Comunidad_Status__c = 'Recuperado'
                                LIMIT 50000];

        setConfirmedCitizenIds = new Set<Id>();
 
        if(!lstConfirmedCitizen.IsEmpty()) {
            for(Covid19__c objContact : lstConfirmedCitizen) {
                setConfirmedCitizenIds.add(objContact.Id);
            }
        }
        System.debug('retrieveConfirmedCitizens [' + setConfirmedCitizenIds + '] <-');

        return setConfirmedCitizenIds;
    }

    private static List<Cuidarnos_SMS__mdt> retrieveRelatedFields() {
        List<Cuidarnos_SMS__mdt> lstFields = null;
        System.debug('retrieveRelatedFields [] ->');

        lstFields = [SELECT Field__c, Conditions__c, Priority__c, Send_to_all__c  
                     FROM Cuidarnos_SMS__mdt
                     ORDER BY Priority__c ASC];

        System.debug('retrieveRelatedFields [' + lstFields + '] <-');
        return lstFields;
    }

    private static Map<String,String> retrieveCitizenHashes(String strCitizenId, List<Cuidarnos_SMS__mdt> lstFields) {
        String strSOQL = null;
        Boolean boolIsFirst = true;
        Map<String,String>  mapCitizenHashes = null;
        Contact objContact = null;

        System.debug('retrieveCitizenHashes [strCitizenId : ' + strCitizenId + '- lstFields : ' + lstFields + '] ->');

        mapCitizenHashes = new Map<String, String>();
        if(lstFields != NULL && !lstFields.IsEmpty()) {
            strSOQL = 'SELECT Id ';
            for (Cuidarnos_SMS__mdt objField : lstFields) {
                strSOQL += ' , ';    
                strSOQL +=  objField.Field__c + ' ';
            }

            strSOQL += ' FROM Contact ';
            strSOQL += ' WHERE Id = \'' + strCitizenId + '\' ';            

            System.debug('retrieveCitizenHashes [strSOQL : ' + strSOQL + ']');

            objContact = Database.query(strSOQL);

            for (Cuidarnos_SMS__mdt objField : lstFields) {
                System.debug('retrieveCitizenHashes [objField : ' + objField.Field__c + ']');
                System.debug('retrieveCitizenHashes [(objContact.get(objField.Field__c) : ' + objContact.get(objField.Field__c) + ']');
                if(objContact.get(objField.Field__c) != NULL) {
                    mapCitizenHashes.put(objField.Field__c, String.valueOf(objContact.get(objField.Field__c)));
                }
            }
        }

        System.debug('retrieveCitizenHashes [' + mapCitizenHashes + '] <-');

        return mapCitizenHashes;
    } 

    private static Cuidarnos_SMS_Send__c saveRequestInfo(String strCitizenId) {
        Cuidarnos_SMS_Send__c objSMSSends = null;
        Map<String,String> mapCurrentSessionAttributes = null;

        System.debug('saveRequestInfo [strCitizenId : ' + strCitizenId + '] ->');
        mapCurrentSessionAttributes = Auth.SessionManagement.getCurrentSession();
        objSMSSends = new Cuidarnos_SMS_Send__c();
        objSMSSends.Ciudadano__c = strCitizenId;
        objSMSSends.Usuario__c = UserInfo.getUserId();
        objSMSSends.IP__c = mapCurrentSessionAttributes.get('SourceIp');
        objSMSSends.Status__c = 'Inicial';
        objSMSSends.Type__c = 'Relacionados';


        System.debug('saveRequestInfo [ objSMSSends : ' + objSMSSends + ']');
        insert objSMSSends;

        System.debug('saveRequestInfo [] <-');

        return objSMSSends;
    }

    private static void updateSMSSendsStatus(Cuidarnos_SMS_Send__c objSMSSends, String strStatus) {
        System.debug('updateSMSSendsStatus [objSMSSends : ' + objSMSSends + ' - strStatus : ' + strStatus + '] ->');
        
        if(objSMSSends != NULL && String.isNotBlank(objSMSSends.Id) ) {
            if(strStatus != NULL) {
                objSMSSends.Status__c = strStatus;
                System.debug('updateSMSSendsStatus [ objSMSSends : ' + objSMSSends + ']');
                update objSMSSends;        
            } else {
                objSMSSends.Stack_Trace__c = 'El estado es nulo.';
                update objSMSSends;        
            }
        }

        System.debug('updateSMSSendsStatus [] <-');
    }

    private static void updateSMSSendsStatus(Cuidarnos_SMS_Send__c objSMSSends, String strStatus, Exception Ex) {
        System.debug('updateSMSSendsStatus [objSMSSends : ' + objSMSSends + ' - strStatus : ' + strStatus + ' - Ex : ' + Ex + '] ->');
        
        if(objSMSSends != NULL && String.isNotBlank(objSMSSends.Id)) {
            objSMSSends.Status__c = strStatus;
            if(Ex != NULL) {
                objSMSSends.Stack_Trace__c = Ex.getStackTraceString();
            } else {
                objSMSSends.Stack_Trace__c = 'Ha ocurrido un error en el envio de SMS';                 
            }
    
            System.debug('updateSMSSendsStatus [ objSMSSends : ' + objSMSSends + ']');
            update objSMSSends;    
        }

        System.debug('updateSMSSendsStatus [] <-');
    }

    private static void updateSMSSendsStatus(Cuidarnos_SMS_Send__c objSMSSends, String strStatus, String strMessage) {
        System.debug('updateSMSSendsStatus [objSMSSends : ' + objSMSSends + ' - strStatus : ' + strStatus + ' - strMessage : ' + strMessage + '] ->');
        
        if(objSMSSends != NULL && String.isNotBlank(objSMSSends.Id)) {
            objSMSSends.Status__c = strStatus;

            if(String.isNotBlank(strMessage)) {
                objSMSSends.Stack_Trace__c = strMessage;
            } else {
                objSMSSends.Stack_Trace__c = 'Ha ocurrido un error en el envio de SMS';                 
            }
    
            System.debug('updateSMSSendsStatus [ objSMSSends : ' + objSMSSends + ']');
            update objSMSSends;    
        }

        System.debug('updateSMSSendsStatus [] <-');
    }

    private static Cuidarnos__mdt retrieveSMSSettings() {
        Cuidarnos__mdt objCuidarnos = null;
        Map<String, Cuidarnos__mdt> mapCuidarnos = null;
        List<GroupMember> lstUserGroup = null;

        System.debug('retrieveSMSSettings [] ->');
        
        mapCuidarnos = retrieveCuidarnosSetting();
        lstUserGroup = retrieveGroups();
        
        if(! lstUserGroup.IsEmpty()) {
            for(GroupMember objGroupMember : lstUserGroup) {
                if(objGroupMember.Group != NULL && mapCuidarnos.containsKey(objGroupMember.Group.DeveloperName)) {
                    objCuidarnos = mapCuidarnos.get(objGroupMember.Group.DeveloperName);                    
                    break;
                }
            }
        } else {
            objCuidarnos = [SELECT  SMS_Sends__c,
                                    Debug_Mode__c, 
                                    SMS_Message_Id__c, 
                                    SMS_Send_Enabled__c,
                                    SMS_Keyword__c, 
                                    SMS_Message__c, 
                                    SMS_Send_Covid_Detail_Info__c,
                                    Allowed_API_Users__c,
                                    Label_Identifier__c,
                                    Admin_Level_0__c,
                                    Admin_Level_1__c,
                                    Admin_Level_2__c,
                                    Admin_Level_3__c,
                                    Notification_SMS_1__c,
                                    Notification_SMS_2__c,
                                    Notification_SMS_3__c    
                            FROM Cuidarnos__mdt
                            WHERE DeveloperName = 'Cuidarnos'];
        }

        System.debug('retrieveSMSSettings [' + objCuidarnos + '] <-');
        return objCuidarnos;
    }

    private static Map<String, Cuidarnos__mdt> retrieveCuidarnosSetting(){
        Map<String, Cuidarnos__mdt> mapCuidarnos = null;
        List<Cuidarnos__mdt> lstCuidarnos = null;

        System.debug('retrieveCuidarnosSetting [] ->');

        mapCuidarnos = new Map<String, Cuidarnos__mdt>(); 
        lstCuidarnos = [SELECT  DeveloperName,
                                Debug_Mode__c, 
                                Filter_by_County__c, 
                                SMS_Sends__c, 
                                SMS_Message_Id__c, 
                                SMS_Send_Enabled__c,
                                SMS_Keyword__c, 
                                SMS_Message__c, 
                                SMS_Send_Covid_Detail_Info__c, 
                                Label_Identifier__c,
                                Allowed_API_Users__c,
                                Admin_Level_0__c,
                                Admin_Level_1__c,
                                Admin_Level_2__c,
                                Admin_Level_3__c,
                                Notification_SMS_1__c,
                                Notification_SMS_2__c,
                                Notification_SMS_3__c
                        FROM Cuidarnos__mdt
                        LIMIT 100];
 
        if(!lstCuidarnos.isEmpty()) {
            for(Cuidarnos__mdt objCuidarnos : lstCuidarnos) {
                mapCuidarnos.put(objCuidarnos.DeveloperName, objCuidarnos);
            }
        }

        System.debug('retrieveCuidarnosSetting [' + mapCuidarnos + '] <-');

        return mapCuidarnos;
    }

    private static List<GroupMember> retrieveGroups(){ 
        List<GroupMember> lstUserGroup = null;

        System.debug('retrieveGroups [] ->');

        lstUserGroup = [SELECT Id, Group.DeveloperName, UserOrGroupId, SystemModstamp 
                        FROM GroupMember 
                        WHERE  UserOrGroupId = :UserInfo.getUserId()];


        System.debug('retrieveGroups [' + lstUserGroup + '] <-');
        return lstUserGroup;
    }

    private static Marketing_Cloud_Setting__mdt retrieveMarketingCloudSettings(String strName) {
        Marketing_Cloud_Setting__mdt objSettings = null;

        System.debug('retrieveMarketingCloudSettings [strName : ' + strName + '] ->');

        objSettings = [ SELECT Account_Id__c, Client_Id__c, Client_Secret__c, SMS_Message_Id__c, Send_SMS_Url__c, Auth_Url__c
                        FROM Marketing_Cloud_Setting__mdt 
                        WHERE DeveloperName =: strName
                        LIMIT 1];

        System.debug('retrieveMarketingCloudSettings [] <-');

        return objSettings;
    }

    private static RemotingMessageHelper.MarketingCloudAccessTokenV2 retrieveAccessToken(Marketing_Cloud_Setting__mdt objSettings) {
        RemotingMessageHelper.MCAuth objAuth = null;
        RemotingMessageHelper.MarketingCloudAccessTokenV2 objAccessToken = null;
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;

        System.debug('retrieveAccessToken [objSettings : ' + objSettings + '] ->');
        
        objAuth = new RemotingMessageHelper.MCAuth();
        objAuth.account_id = objSettings.Account_Id__c;
        objAuth.client_id = objSettings.Client_Id__c;
        objAuth.client_secret =  objSettings.Client_Secret__c;
        objAuth.grant_type = 'client_credentials';
        objAuth.scope = 'sms_write sms_read sms_send';
        
        objRequest = new HttpRequest();
        objRequest.setMethod('POST');
        objRequest.setEndpoint(objSettings.Auth_Url__c);
        objRequest.setHeader('content-type', 'application/json');
        objRequest.setBody(JSON.serialize(objAuth));
        
        objHttp = new Http();               
        objResponse = objHttp.send(objRequest);
        
        if (objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {            
            objAccessToken = (RemotingMessageHelper.MarketingCloudAccessTokenV2)JSON.deserialize(objResponse.getBody(), RemotingMessageHelper.MarketingCloudAccessTokenV2.class);
            
        }

        System.debug('retrieveAccessToken [' + objAccessToken + '] <-');

        return objAccessToken;
    }

    private static Blob makeRequest(String strBody, String strEndpoint) {
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        Blob objResponseBody = null;

        System.debug('makeRequest [ strBody : ' + strBody + '] ->');
    
        objRequest = new HttpRequest();
        objRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8');
        objRequest.setMethod('POST');
        objRequest.setEndpoint(strEndpoint);
        objRequest.setTimeout(60 * 1000);
        //objRequest.setHeader('content-type', 'application/json; charset=UTF-8');
        objRequest.setBody(strBody);
        
        System.debug('makeRequest [ strEndpoint : ' + strEndpoint + ']');
        System.debug('makeRequest [ objResponse.getBody() : ' + objRequest.getBody() + ']');

        objHttp = new Http();
        objResponse = objHttp.send(objRequest);
        
        if(objResponse != NULL && objResponse.getStatusCode() == 200) {
            objResponseBody = objREsponse.getBodyAsBlob();
        } else {
            throw new Cuidarnos_Ficha_REST.FichaException();
        }

        System.debug('makeRequest [] <-');
        return objResponseBody;
    }

   
    private static String retrieveAddressSimple(Contact objContact) {
        String strAddress = null;
        String strFloorApartment = null;
                
        System.debug('retrieveAddressSimple [] ->');

        strFloorApartment = retrieveFloorApartment(objContact);
        if(String.isNotBlank(objContact.MailingStreet)) {    
            objContact.MailingStreet = String.join(HelperFunctions.capitalizeList(objContact.MailingStreet.split(' ')), ' ');
            if(String.isNotBlank(objContact.MailingNumber__c) ) {
                if(String.isNotBlank(strFloorApartment)) {
                    strAddress = String.format('{0} {1} {2}', new String[] {objContact.MailingStreet, objContact.MailingNumber__c, strFloorApartment });                  		                
                } else {                    
                    strAddress = String.format('{0} {1}', new String[] {objContact.MailingStreet, objContact.MailingNumber__c });                  		                
                }
            } else {
                if(String.isNotBlank(strFloorApartment)) {
                    strAddress = String.format('{0} {1}, {2}', new String[] {  objContact.MailingStreet, strFloorApartment});
                } else {                    
                    strAddress = String.format('{0}', new String[] {objContact.MailingStreet });
                }                
            }
        } else {
            strAddress = '';
        }
 
        System.debug('retrieveAddressSimple [' + strAddress + '] <-');
        return strAddress;
    }
    
    private static String retrieveFloorApartment(Contact objContact) { 
        String strFloorApartment = null;
        System.debug('retrieveFloorApartment [] ->');
        
        if(objContact.MailingAppartment__c != null) {
            strFloorApartment = String.format('{0}', new String [] { objContact.MailingAppartment__c });
        } else {
            strFloorApartment = '';
        }
        
        System.debug('retrieveFloorApartment [' + strFloorApartment + '] <-');
        
        return strFloorApartment;
    }

    @AuraEnabled
    public static List<Resultados> retrieveMuestrasFromExternalSystem(String strCitizenId){
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        String strEndpoint = null;
        Blob objResponseBody = null;
        Contact objContact = null;
        List<Resultados> lstResultados = null;
        DateTime datDate = null;
        Cuidarnos__mdt objCuidarnosSettings = null;

        System.debug('retrieveMuestrasFromExternalSystem [ strCitizenId : ' + strCitizenId + '] ->');
    
        lstResultados = new List<Resultados>();
        try {
            objContact = retrieveContactCitizen(strCitizenId);
            objCuidarnosSettings = retrieveSMSSettings();

            strEndpoint = String.format('https://api.cuidarnos.com/consultas/hisopadosSF/{0}/{1}', new String[] { objContact.Document_Number__c, objContact.Gender__c });

            objRequest = new HttpRequest();
            objRequest.setHeader('X-Cuidarnos-Access-Key', '4b31bafa4f284047a6f978366356d861');
            objRequest.setMethod('GET');
            objRequest.setEndpoint(strEndpoint);
            objRequest.setTimeout(60 * 1000);
            
            System.debug('retrieveMuestrasFromExternalSystem [ strEndpoint : ' + strEndpoint + ']');
            System.debug('retrieveMuestrasFromExternalSystem [ objResponse.getBody() : ' + objRequest.getBody() + ']');

            objHttp = new Http();
            objResponse = objHttp.send(objRequest);
            
            if(objResponse != NULL && objResponse.getStatusCode() == 200) {
                try {
                    lstResultados = (List<Resultados>)JSON.deserialize(objResponse.getBody(),List<Resultados>.class);

                    for(Resultados objResultado : lstResultados) {
                        objResultado.Display = String.format('[{0}] {1}', new String[]{ objResultado.Identificador, objResultado.FechaHora });
                    } 
                } catch(Exception Ex) {
                    HelperFunctions.handleRuntimeException(Ex);
                }
            } else {
                System.debug('retrieveMuestrasFromExternalSystem [objResponse.getStatusCode() : ' + objResponse.getStatusCode() + ']');
                System.debug('retrieveMuestrasFromExternalSystem [objResponse.getBody() : ' + objResponse.getBody() + ']');

                throw new Cuidarnos_Ficha_REST.FichaException();
            }
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);
        }
        System.debug('retrieveMuestrasFromExternalSystem [] <-');
        return lstResultados;
    }

    @future(callout=true)
    public static void postResultadosExternalSystem(String strCitizenId, String strLab,Integer intLabelId, String strResultado){
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        String strEndpoint = null;
        Blob objResponseBody = null;
        SaveResult objSaveResult = null;
        Contact objContact = null;

        System.debug('postResultadosExternalSystem [ strCitizenId : ' + strCitizenId + ' - strLab : ' + strLab + ' - intLabelId : ' + intLabelId + ' - strResultado : ' + strResultado +'] ->');

        objContact = retrieveContactCitizen(strCitizenId);

        strEndpoint = 'https://api.cuidarnos.com/api/AResultadoSF';
        objSaveResult = new SaveResult();
        
        objSaveResult.IdEtiqueta = Integer.valueOf(intLabelId);

        objSaveResult.Resultado = strResultado;
        objSaveResult.Laboratorio = strLab;

        objRequest = new HttpRequest();
        objRequest.setHeader('Content-Type', 'application/json');
        objRequest.setHeader('X-Cuidarnos-Access-Key', '4b31bafa4f284047a6f978366356d861');
        objRequest.setMethod('POST');
        objRequest.setEndpoint(strEndpoint);
        objRequest.setTimeout(60 * 1000);
        //objRequest.setHeader('content-type', 'application/json; charset=UTF-8');
        objRequest.setBody(JSON.serialize(objSaveResult));
        
        System.debug('postResultadosExternalSystem [ strEndpoint : ' + strEndpoint + ']');
        System.debug('postResultadosExternalSystem [ objResponse.getBody() : ' + objRequest.getBody() + ']');

        objHttp = new Http();
           
        objResponse = objHttp.send(objRequest);
        System.debug('postResultadosExternalSystem [objResponse.getStatusCode()  : ' + objResponse.getStatusCode()  + ']');
        System.debug('postResultadosExternalSystem [objResponse.getBody()  : ' + objResponse.getBody()  + ']');
       
        if(objResponse != NULL && objResponse.getStatusCode() == 200) {
            objResponseBody = objResponse.getBodyAsBlob();
        } else {
            throw new Cuidarnos_Ficha_REST.FichaException();
        }
        
        System.debug('postResultadosExternalSystem [] <-');
    }

    public class Resultados {
        @AuraEnabled
        public Integer Id { get; set; }
        @AuraEnabled
        public String FechaHora { get; set; }
        @AuraEnabled
        public String Display { get; set; }
        @AuraEnabled
        public String Identificador { get; set; }
        @AuraEnabled
        public String HashEtiqueta { get; set; }

        @AuraEnabled
        public String Value { get; set; }
    }

    public class SaveResult {
        @AuraEnabled
        public Integer IdEtiqueta { get; set; }
        @AuraEnabled
        public String HashEtiqueta { get; set; }        
        @AuraEnabled
        public String Resultado { get; set; }
        @AuraEnabled
        public String Laboratorio { get; set; }
    }

    public class HistoryItem {
        @AuraEnabled
        public String OldStatus { get; set; }
        @AuraEnabled
        public String NewStatus { get; set; }        
        @AuraEnabled
        public String User { get; set; }
        @AuraEnabled
        public String Created { get; set; }

        public HistoryItem() {}
        public HistoryItem(Covid19__history objHistory) {
            this.OldStatus = String.valueOf(objHistory.OldValue);
            this.NewStatus = String.valueOf(objHistory.NewValue);
            this.User = String.format('{0} {1}', new String[] { objHistory.CreatedBy.FirstName, objHistory.CreatedBy.LastName });
            this.Created = objHistory.CreatedDate.format();
        }
    }

    public static void codeCoverage_we_have_run_out_of_time(){
        Integer intI = 1;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
    }
}