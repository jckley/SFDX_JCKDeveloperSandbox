public class ReportManager {
    public class ExportException extends Exception {
        public Integer Code   { get; set; }
        public String Message { get; set; }
       
        public ExportException(Integer intCode, String strMessage) {
            this.Code = intCode;
            this.Message = strMessage;
        }
    }
       
    @RemoteAction
    public static List<RemotingMessageHelper.ProfileUser> listUserProfile() {
        List<RemotingMessageHelper.ProfileUser> lstProfileUser = null;
        RemotingMessageHelper.ProfileUser objUserProfile = null;
        List<User> lstUser = null;
        List<Profile> lstProfile = null;
        
        System.debug('listUserProfile [] ->');
        
        lstUser 	= [SELECT Id, Name, IsPortalEnabled, Username 	FROM User WHERE IsActive = TRUE ORDER BY Name];
        lstProfile 	= [SELECT Id, Name 								FROM Profile  					ORDER BY Name];
        
        lstProfileUser = new List<RemotingMessageHelper.ProfileUser>();
        for(User objUser : lstUser) {
            objUserProfile = new RemotingMessageHelper.ProfileUser(objUser);
            lstProfileUser.add(objUserProfile);
        }
        
        for(Profile objProfile : lstProfile) {
            objUserProfile = new RemotingMessageHelper.ProfileUser(objProfile);
            lstProfileUser.add(objUserProfile);
        }
        
        System.debug('listUserProfile [' + lstProfileUser + '] <-');
        
        return lstProfileUser;
    }
    
    @RemoteAction
    public static List<String> retrieveTimeRange() {
        List<String> lstTimeRange = null;
        Schema.DescribeFieldResult objDescribeFieldResult = null;
        List<Schema.PicklistEntry> lstPicklistEntry = null;
        System.debug('retrieveTimeRange [] ->');
        
        lstTimeRange = new List<String>();
        objDescribeFieldResult = Permission_Type__c.Time__c.getDescribe();
        lstPicklistEntry = objDescribeFieldResult.getPicklistValues();
        for( Schema.PicklistEntry objPicklitValue : lstPicklistEntry){
            lstTimeRange.add(objPicklitValue.getLabel());
        }     
        
        System.debug('retrieveTimeRange [' + lstTimeRange + '] <-');        
        return lstTimeRange;
    }
    
    @RemoteAction
    public static RemotingMessageHelper.ProfileUserPermission retrievePermissions(Id objUserId, Id objProfileId, String strSObject) { 
        List<RemotingMessageHelper.FieldPermission> lstFields = null;
        RemotingMessageHelper.FieldPermission objFieldPermission = null;
        List<Permission__c> lstExportPermissions = null;
        Map<String, Boolean> mapFieldAccesibilty = null;
        RemotingMessageHelper.ProfileUserPermission objProfileUserPermission = null;
        List<Permission_Type__c> lstPermissionType = null;
        
        System.debug('retrievePermissions [ objUserId : ' + objUserId + ' - objProfileId : ' + objProfileId + ' - strSObject : ' + strSObject + '] ->');
        
        objProfileUserPermission = new RemotingMessageHelper.ProfileUserPermission();
        lstFields = showFields(strSObject);
        if(String.isNotBlank(objProfileId)) {
            lstExportPermissions = [SELECT Id, Name, sObject__c, FieldName__c, Can_Export__c, Permission_Type__c
                                    FROM Permission__c 
                                    WHERE Permission_Type__r.Profile_Id__c =: objProfileId 
                                    AND sObject__c = :strSObject];       
            lstPermissionType = [SELECT Time__c, Records__c, MaxRecords__c FROM Permission_Type__c WHERE Profile_Id__c =: objProfileId ];
        } else if(String.isNotBlank(objUserId)) {
            lstExportPermissions = [SELECT Id, Name, sObject__c, FieldName__c, Can_Export__c, Permission_Type__c
                                    FROM Permission__c
                                    WHERE Permission_Type__r.UserId__c =: objUserId 
                                    AND sObject__c = :strSObject];   
            lstPermissionType = [SELECT Time__c, Records__c, MaxRecords__c FROM Permission_Type__c WHERE UserId__c =: objUserId ];
        }
        
        if(!lstPermissionType.IsEmpty()) {
            objProfileUserPermission.TimeRange = lstPermissionType[0].Time__c;
            if(lstPermissionType[0].Records__c != NULL) {
                objProfileUserPermission.Records = lstPermissionType[0].Records__c.intValue();                
            }
            
            if(lstPermissionType[0].MaxRecords__c != NULL) {
                objProfileUserPermission.MaxRecords = lstPermissionType[0].MaxRecords__c.intValue();                
            }
        }
        if(!lstExportPermissions.isEmpty()) {
            mapFieldAccesibilty = new Map<String, Boolean>();
            for(Permission__c objPermission : lstExportPermissions ) {
                mapFieldAccesibilty.put(objPermission.FieldName__c, objPermission.Can_Export__c);
            }
            
            for(RemotingMessageHelper.FieldPermission objFP : lstFields) {
                if(mapFieldAccesibilty.containsKey(objFP.Name)) {
                    objFP.CanExport = mapFieldAccesibilty.get(objFP.Name);                
                }
            }
        } 
        
        objProfileUserPermission.Fields = lstFields;
        
        System.debug('retrievePermissions [' + objProfileUserPermission.Fields + '] <-');        
        return objProfileUserPermission;
    }
    
    @RemoteAction
    public static Boolean updatePermissions(String strJSON) { 
        Savepoint objSavePoint = null;
        List<Permission_Type__c> lstPermissionType = null;
        List<Permission__c> lstPermissionTypeUpdate = null;
        Permission_Type__c objPermissionType = null;
        Permission__c objPermission = null;
        RemotingMessageHelper.PermissionRequest objPermissionRequest = null;
        Boolean boolResult = false;
        System.debug('updatePermissions [ objPermissionRequest : ' + objPermissionRequest + '] ->');
        try {
            objSavePoint = Database.setSavepoint();
            objPermissionRequest = (RemotingMessageHelper.PermissionRequest)JSON.deserialize(strJSON, RemotingMessageHelper.PermissionRequest.class);
            if(String.isNotBlank(objPermissionRequest.ProfileId)) {
                delete [SELECT Id 
                        FROM Permission__c  
                        WHERE Permission_Type__r.Profile_Id__c =: objPermissionRequest.ProfileId 
                        AND sObject__c = :objPermissionRequest.SObjectName];
            } else if(String.isNotBlank(objPermissionRequest.UserId)) {
                delete [SELECT Id 
                        FROM Permission__c  
                        WHERE Permission_Type__r.UserId__c =: objPermissionRequest.UserId
                        AND sObject__c = :objPermissionRequest.SObjectName];
                
            }
            
            if(String.isNotBlank(objPermissionRequest.UserId)) {
                lstPermissionType = [SELECT ID 
                                     FROM Permission_Type__c 
                                     WHERE UserId__c =: objPermissionRequest.UserId];
            } else if(String.isNotBlank(objPermissionRequest.ProfileId)) {
                if(lstPermissionType.IsEmpty()) {
                    lstPermissionType = [SELECT ID 
                                         FROM Permission_Type__c 
                                         WHERE Profile_Id__c =: objPermissionRequest.ProfileId];                    
                }
            }
            
            if(lstPermissionType.isEmpty()) {
                objPermissionType = new Permission_Type__c();
                objPermissionType.Profile_Id__c = objPermissionRequest.ProfileId;
                objPermissionType.UserId__c = objPermissionRequest.UserId;
                if(String.isNotBlank(objPermissionRequest.RecordsQuota)) {
                    objPermissionType.Records__c = Decimal.valueOf(objPermissionRequest.RecordsQuota);
                }
                
                if(String.isNotBlank(objPermissionRequest.RecordsQuota)) {
                    objPermissionType.MaxRecords__c = Decimal.valueOf(objPermissionRequest.MaxRecords);
                }
                objPermissionType.Time__c = objPermissionRequest.TimeRange;
                
                insert objPermissionType;      
            } else {
                objPermissionType = lstPermissionType[0];
                if(String.isNotBlank(objPermissionRequest.RecordsQuota)) {
                    objPermissionType.Records__c = Decimal.valueOf(objPermissionRequest.RecordsQuota);
                }
                
                if(String.isNotBlank(objPermissionRequest.RecordsQuota)) {
                    objPermissionType.MaxRecords__c = Decimal.valueOf(objPermissionRequest.MaxRecords);
                }
                objPermissionType.Time__c = objPermissionRequest.TimeRange;
                update objPermissionType;
            }
            lstPermissionTypeUpdate = new List<Permission__c>();
            for(RemotingMessageHelper.FieldPermission objPermissionWrapper : objPermissionRequest.ActivePermissions) {
                objPermission = objPermissionWrapper.toSObject();
                objPermission.sObject__c = objPermissionRequest.SObjectName;
                objPermission.Permission_Type__c = objPermissionType.Id;
                lstPermissionTypeUpdate.add(objPermission);
            }
            
            insert lstPermissionTypeUpdate;
            
            boolResult = true;
        } catch(Exception Ex) {
            Database.rollback(objSavePoint);
            System.debug('Ex : ' + Ex.getMessage() );
        }
        System.debug('updatePermissions [] <-');
        
        return boolResult;
    }
    
    @RemoteAction
    public static RemotingMessageHelper.OperationResult exportReport(String strReportId) {  
        ReportsBatch objReports = null;
        RemotingMessageHelper.OperationResult objResult = null;
        Integer intRecords = NULL;
        
        System.debug('exportReport [ strReportId : ' + strReportId + '] ->');
        
        try {
            objResult = new RemotingMessageHelper.OperationResult();
            if(String.isNotBlank(strReportId)) {
                intRecords = checkQuota();
                
                objReports = new ReportsBatch(strReportId, intRecords);
                Database.executeBatch( objReports, 10000);     
                
                objResult.Code = 0;
                objResult.Message = 'El reporte se esta generando.';  
            } else {
                objResult.Code = 110;
                objResult.Message = 'Debe ingresar el identificador de reporte para exportarlo.';                  
            }            
        } catch (ExportException Exc) {
            objResult.Code = Exc.Code;
            objResult.Message = Exc.Message;            
        } catch(Exception Ex) {
            System.debug('exportReport [' + Ex + ']');
            objResult.Code = 999;
            objResult.Message = Ex.getMessage();
        }
        
        System.debug('exportReport [' + objResult + '] <-');
        return objResult;
    }


    @RemoteAction
    @future(callout=true)
    public static void sendAnalyticsToMarketingCloud(String strExportId, String strDataExtensionName, String strSAQL, Boolean boolQueryAll, Boolean boolSendable) { 
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        RemotingMessageHelper.AnalyticsMCWrapper objBody = null;

        System.debug('procesarReportesEnEjecucion [strExportId : ' + strExportId + ' - strDataExtensionName : ' + strDataExtensionName + ' - strSAQL : ' + strSAQL + ' -boolQueryAll : ' + boolQueryAll + ' - boolSendable : ' + boolSendable + ' ] ->');

        if(String.isNotBlank(strDataExtensionName) && String.isNotBlank(strSAQL)) {
            objBody = new RemotingMessageHelper.AnalyticsMCWrapper();
            objBody.name = strDataExtensionName;
            objBody.saql = strSAQL;
            objBody.sendable = boolSendable;
            objBody.queryall = boolQueryAll;
            objBody.userid = UserInfo.getUserId();
            objBody.exportid = strExportId;

            objHttp = new Http();
            objRequest = new HttpRequest();
            objRequest.setMethod('POST');
            objRequest.setEndpoint('callout:HerokuAPI/analytics');
            objRequest.setHeader('content-type', 'application/json; charset=UTF-8');
            objRequest.setBody(JSON.serialize(objBody));

            System.debug('procesarReportesEnEjecucion [objBody : ' + objBody + ']');

            try {
                objResponse = objHttp.send(objRequest);
                
                if(objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {            
                    System.debug('sendAnalyticsToMarketingCloud BODY : ' + objResponse.getBody());
                } else {
                    updateExportStatusWithError(strExportId, objResponse.getStatusCode(), objResponse.getBody());
                }
            } catch (Exception Ex) {
                if (Ex.getMessage() != 'Read timed out') {
                    HelperFunctions.handleRuntimeException(Ex);
                    updateExportStatusWithError(strExportId, -1, Ex.getMessage());    
                }
            }
        }

        System.debug('procesarReportesEnEjecucion [] <-');
    }


    @RemoteAction
    @future(callout=true)
    public static void sendAnalyticsToMarketingCloudForMobileConnect(String strExportId, String strDataExtensionName, String strSAQL, Boolean boolAllData, Boolean boolSendable) { 
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;

        System.debug('sendAnalyticsToMarketingCloudForMobileConnect [strExportId : ' + strExportId + ' - strDataExtensionName : ' + strDataExtensionName + ' - strSAQL : ' + strSAQL + ' ] ->');

        if(String.isNotBlank(strDataExtensionName) && String.isNotBlank(strSAQL)) {
            Campania__c campania = [SELECT Id, Prosumer_Mensaje_SMS__c FROM Campania__c WHERE Export__c = :strExportId LIMIT 1];
            System.debug(campania);

            RemotingMessageHelper.AnalyticsMCWrapper objBody = new RemotingMessageHelper.AnalyticsMCWrapper();
            objBody.name = strDataExtensionName;
            objBody.saql = strSAQL;
            objBody.sendable = boolSendable;
            objBody.queryall = boolAllData;
            objBody.userid = UserInfo.getUserId();
            objBody.exportid = strExportId;
            objBody.smsmessage = campania.Prosumer_Mensaje_SMS__c;


            objHttp = new Http();
            objRequest = new HttpRequest();
            objRequest.setMethod('POST');
            objRequest.setEndpoint('callout:HerokuAPI/analyticsformobile');
            objRequest.setHeader('content-type', 'application/json; charset=UTF-8');
            objRequest.setBody(JSON.serialize(objBody));

            System.debug('sendAnalyticsToMarketingCloudForMobileConnect [objBody : ' + objBody + ']');

            try {
                objResponse = objHttp.send(objRequest);
                
                if(objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {            
                    System.debug('sendAnalyticsToMarketingCloudForMobileConnect BODY : ' + objResponse.getBody());
                } else {
                    updateExportStatusWithError(strExportId, objResponse.getStatusCode(), objResponse.getBody());
                }
            } catch (Exception Ex) {
                if (Ex.getMessage() != 'Read timed out') {
                    HelperFunctions.handleRuntimeException(Ex);
                    updateExportStatusWithError(strExportId, -1, Ex.getMessage());    
                }
            }
        }

        System.debug('sendAnalyticsToMarketingCloudForMobileConnect [] <-');
    }


    private static void updateExportStatusWithError(String strExportId, Integer intStatusCode, String strMessage) {
        Export__c objExport = null;
        String strStatusDescription;

        // strStatusDescription = 'Finalizado con Errores';
        // if (intStatusCode == 502) {
        //     strStatusDescription = 'Servicio no disponble';
        // } else if (intStatusCode )

        switch on intStatusCode {
            when 500 {
                strStatusDescription = 'Server caido o en mantenimiento (500)';
            }
            when 502 {
                strStatusDescription = 'Servicio no disponble (502)';
            }
            when 503 {
                strStatusDescription = 'Servicio no disponble (503)';
            }
            when else {
                strStatusDescription = 'Finalizado con Errores';
            }
        }

        System.debug('updateExportStatusWithError [strExportId : ' + strExportId + ' - strMessage : ' + strMessage + '] ->');

        objExport = [SELECT Status__c, Callout_Message__c 
                     FROM Export__c 
                     WHERE Id =: strExportId];
        
        objExport.Status__c = strStatusDescription;
        objExport.Callout_Message__c = strMessage;

        update objExport;

        HelperFunctions.sendEmail(UserInfo.getUserEmail(), 'Status Export: ' + strStatusDescription, strMessage);

        System.debug('updateExportStatusWithError [] <-');
    }

    @RemoteAction
    @future(callout=true)
    public static void exportAnalytics(String strExportId, String strName, String strSAQL, Boolean boolQueryAll) { 
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        RemotingMessageHelper.ExportWrapper objBody = null;
        Set<String> setAllowedFields = null;

        System.debug('exportAnalytics [strExportId : ' + strExportId + ' - strName : ' + strName + ' - strSAQL : ' + strSAQL + ' -boolQueryAll : ' + boolQueryAll + '] ->');

        try {
            if(String.isNotBlank(strSAQL)) {
                setAllowedFields = new Set<String>();
                objBody = new RemotingMessageHelper.ExportWrapper();

                objBody.name = strName;
                objBody.saql = strSAQL;
                objBody.queryall = boolQueryAll;
                objBody.exportid = strExportId;
                objBody.userid = retrieveExportUserId(strExportId); // UserInfo.getUserId();
                /* DADO QUE EL REPORTE ES APROBADO MANUALMENTE, YA NO IMPORTA LA CANTIDAD DE MAXIMA DE REGISTROS QUE PUEDE EXPORTAR EL TIPO */
                //objBody.maxrecords = checkQuota();
                //objBody.allowedfields = ReportsBatch.retrieveAllowedFields(UserInfo.getProfileId(), UserInfo.getUserId(), 'Contact');              

                System.debug('exportAnalytics [objBody : ' + objBody + ']');

                objHttp = new Http();
                objRequest = new HttpRequest();
                objRequest.setMethod('POST');
                objRequest.setEndpoint('callout:HerokuAPI/export');
                objRequest.setHeader('content-type', 'application/json; charset=UTF-8');
                objRequest.setBody(JSON.serialize(objBody));

                try {
                    objResponse = objHttp.send(objRequest);
                    
                    if(objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {            
                        System.debug('exportAnalytics BODY : ' + objResponse.getBody());
                    } else {
                        updateExportStatusWithError(strExportId, objResponse.getStatusCode(), objResponse.getBody());
                    }
                } catch (Exception Ex) {
                    if (Ex.getMessage() != 'Read timed out') {
                        HelperFunctions.handleRuntimeException(Ex);
                        updateExportStatusWithError(strExportId, objResponse.getStatusCode(), Ex.getMessage());    
                    }
                }                                               
            }
        } catch (ExportException Ex) {
            HelperFunctions.handleRuntimeException(Ex);
            updateExportStatusWithError(strExportId, -1, Ex.getMessage());              
        }

        System.debug('exportAnalytics [] <-');
    }


    @RemoteAction
    @future(callout=true)
    public static void exportAnalyticsToSondeosIVR(String strExportId, String strName, String strSAQL, Boolean boolQueryAll) { 
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        RemotingMessageHelper.ExportWrapperForSondeosIVR objBody = null;
        Set<String> setAllowedFields = null;

        System.debug('exportAnalyticsToSondeosIVR [strExportId : ' + strExportId + ' - strName : ' + strName + ' - strSAQL : ' + strSAQL + ' -boolQueryAll : ' + boolQueryAll + '] ->');

        try {
            if(String.isNotBlank(strSAQL)) {
                setAllowedFields = new Set<String>();
                objBody = new RemotingMessageHelper.ExportWrapperForSondeosIVR();

                objBody.name = strName;
                objBody.saql = strSAQL;
                objBody.queryall = boolQueryAll;
                objBody.exportid = strExportId;
                objBody.userid = retrieveExportUserId(strExportId);

                Campania__c campania = [SELECT Id, Prosumer_Mensaje_Audio__c, Prosumer_Fecha_de_Inicio__c, Prosumer_Fecha_de_Finalizacion__c, Prosumer_Hora_de_Inicio__c, Prosumer_Hora_de_Finalizacion__c FROM Campania__c WHERE Export__c = :strExportId LIMIT 1];
                objBody.fecha_inicio = campania.Prosumer_Fecha_de_Inicio__c.formatGMT('dd-MM-yyyy');
                objBody.fecha_finalizacion = campania.Prosumer_Fecha_de_Finalizacion__c.formatGMT('dd-MM-yyyy');
                objBody.hora_inicio = campania.Prosumer_Hora_de_Inicio__c;
                objBody.hora_finalizacion = campania.Prosumer_Hora_de_Finalizacion__c;
                // System.Debug('exportAnalyticsToSondeosIVR   campania.Prosumer_Fecha_de_Inicio__c = ' + campania.Prosumer_Fecha_de_Inicio__c);
                // System.Debug('exportAnalyticsToSondeosIVR   campania.Prosumer_Fecha_de_Finalizacion__c = ' + campania.Prosumer_Fecha_de_Finalizacion__c);
                // System.Debug('exportAnalyticsToSondeosIVR   objBody.fecha_inicio = ' + objBody.fecha_inicio);
                // System.Debug('exportAnalyticsToSondeosIVR   objBody.fecha_finalizacion = ' + objBody.fecha_finalizacion);

                // Id contentVersionId = '068Da000002B1yCIAS';
                // ContentVersion cv = [SELECT Title, VersionData FROM ContentVersion WHERE Id = :contentVersionId];

                ContentVersion cv = [SELECT Title, VersionData FROM ContentVersion WHERE Id = :campania.Prosumer_Mensaje_Audio__c LIMIT 1];

                Blob audioFileBlob = cv.VersionData;
                String audioFileBody = EncodingUtil.base64Encode(audioFileBlob);
                System.Debug('exportAnalyticsToSondeosIVR   contentVersion cv.Id = ' + cv.Id);

                objBody.audio = audioFileBody;

                System.debug('exportAnalyticsToSondeosIVR [objBody : ' + objBody + ']');

                objHttp = new Http();
                objRequest = new HttpRequest();
                objRequest.setMethod('POST');
                objRequest.setEndpoint('callout:HerokuAPI/analyticstosondeosivr');
                objRequest.setHeader('content-type', 'application/json; charset=UTF-8');

                objRequest.setBody(JSON.serialize(objBody));

                try {
                    objResponse = objHttp.send(objRequest);
                    
                    if(objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {            
                        System.debug('exportAnalyticsToSondeosIVR BODY : ' + objResponse.getBody());
                    } else {
                        updateExportStatusWithError(strExportId, objResponse.getStatusCode(), objResponse.getBody());
                    }
                } catch (Exception Ex) {
                    if (Ex.getMessage() != 'Read timed out') {
                        HelperFunctions.handleRuntimeException(Ex);
                        updateExportStatusWithError(strExportId, objResponse.getStatusCode(), Ex.getMessage());    
                    }
                }                                               
            }
        } catch (ExportException Ex) {
            HelperFunctions.handleRuntimeException(Ex);
            updateExportStatusWithError(strExportId, -1, Ex.getMessage());              
        }

        System.debug('exportAnalyticsToSondeosIVR [] <-');
    }

    class WrapperForSondeosGetCampaigns {
        String usuario {get; set;}
        String clave {get; set;}
    }

    @RemoteAction
    @future(callout=true)
    public static void exportAnalyticsToSondeosIVRCheckStatus(String strExportId) { 
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;

        String usuario = 'SmartIVR';
        String clave = 'MmEwY2Q5';
        String url = 'https://cmpapi.sondeosglobal.com/campaign/get';

        WrapperForSondeosGetCampaigns objBody = null;

        System.debug('exportAnalyticsToSondeosIVRCheckStatus [strExportId : ' + strExportId + '] ->');

        try {
            objBody.usuario = usuario;
            objBody.clave = clave;

            System.debug('exportAnalyticsToSondeosIVRCheckStatus [objBody : ' + objBody + ']');

            objHttp = new Http();
            objRequest = new HttpRequest();
            objRequest.setMethod('GET');
            objRequest.setEndpoint(url);
            objRequest.setHeader('content-type', 'application/json; charset=UTF-8');

            objRequest.setBody(JSON.serialize(objBody));

            try {
                objResponse = objHttp.send(objRequest);
                
                if(objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {            
                    System.debug('exportAnalyticsToSondeosIVRCheckStatus BODY : ' + objResponse.getBody());
                } else {
                    updateExportStatusWithError(strExportId, objResponse.getStatusCode(), objResponse.getBody());
                }
            } catch (Exception Ex) {
                if (Ex.getMessage() != 'Read timed out') {
                    HelperFunctions.handleRuntimeException(Ex);
                    updateExportStatusWithError(strExportId, objResponse.getStatusCode(), Ex.getMessage());    
                }
            }                                               
        } catch (ExportException Ex) {
            HelperFunctions.handleRuntimeException(Ex);
            updateExportStatusWithError(strExportId, -1, Ex.getMessage());              
        }

        System.debug('exportAnalyticsToSondeosIVRCheckStatus [] <-');
    }


    public static void exportReportToCsv(String strExportId, String strName, String strReportId, String strReportName) {
        String strUserId = null;
        String strReportURL = null;
        String strReportHTML = null;
        String strUserEmail = null;

        System.debug('exportReportToCsv [strExportId : ' + strExportId + ' - strName : ' + strName + ' - strReportId : ' + strReportId + ' - strReportName : ' + strReportName + '] ->');
                
        if(String.isNotBlank(strExportId) && String.isNotBlank(strReportId)) {
            try {
                strUserId = retrieveExportUserId(strExportId);
                strUserEmail = [SELECT Email FROM User WHERE Id =: strUserId].Email;
    
                strReportURL =  URL.getSalesforceBaseUrl().toExternalForm() + '/' + strReportId + '?csv=true';
                strReportHTML = String.format('Puede descargar el reporte desde el siguiente <a href="{0}">link</a>', new String[]{ strReportURL });
    
                ExportRESTInterface.updateExportStatus('crmcsv', 'Finalizado OK');     
                HelperFunctions.sendEmail(strUserEmail, 'Reporte : ' + strName, strReportHTML);
                    
            } catch (Exception Ex) {
                HelperFunctions.handleRuntimeException(Ex);
                updateExportStatusWithError(strExportId, -1, Ex.getMessage()); 
            }

        } else {
            updateExportStatusWithError(strExportId, -1, 'Los datos ingresados para exportar el reporte no son válidos');       
        }

        System.debug('exportReportToCsv [] <-');
    }


    private static Id retrieveExportUserId(String strExportId) {
        Id  objUserId = null;
        System.debug('retrieveExportUserId [] ->');
        try {
            objUserId = [SELECT CreatedById FROM Export__c WHere Id =: strExportId ].CreatedById;
        } catch(Exception Ex) {
            objUserId = UserInfo.getUserId();
        }

        System.debug('retrieveExportUserId [] <-');

        return objUserId;
    }

    
    @RemoteAction 
    public static RemotingMessageHelper.UserQuota retrieveCurrentUserQuota() { 
    	Integer intUserQuota = null;
        RemotingMessageHelper.UserQuota objUserQuota = null;

        try {
            objUserQuota = new RemotingMessageHelper.UserQuota();
            
            intUserQuota = checkQuota();
            
            objUserQuota.Code = 0;
            objUserQuota.Message = 'La operación se ha realizado correctamente.';
            objUserQuota.Quota = intUserQuota;
        } catch(ExportException Ex) {
            System.debug('Ex : ' + Ex);
            objUserQuota.Code = Ex.Code;
            objUserQuota.Message = Ex.Message;
            objUserQuota.Quota = 0;
        }          

        return objUserQuota;
    }

   	private static Integer checkQuota() {
        List<Permission_Type__c> lstPermission = null;
        User objUser = null;
        Integer intRecordsLimit = 0;

        System.debug('checkQuota [] ->');

        objUser = [SELECT Records_Processed__c 
                   FROM User 
                   WHERE Id =: UserInfo.getUserId()];

        lstPermission = [SELECT Records__c, MaxRecords__c, Time__c
                         FROM Permission_Type__c
                         WHERE UserId__c =: UserInfo.getUserId()];

        if(!lstPermission.isEmpty()) {
            if(objUser.Records_Processed__c == NULL) {
                objUser.Records_Processed__c = 0;
            }
            System.debug('checkQuota [ Processed : ' + objUser.Records_Processed__c + ' - Records : ' + lstPermission[0].Records__c + ' ]');
            if(objUser.Records_Processed__c < lstPermission[0].Records__c) {
                intRecordsLimit = ( (lstPermission[0].Records__c - objUser.Records_Processed__c) > lstPermission[0].MaxRecords__c )?lstPermission[0].MaxRecords__c.intValue():(lstPermission[0].Records__c - objUser.Records_Processed__c).intValue();
            } else {
                System.debug('Ha superado la cantidad máxima de registros que puede exportar [' + lstPermission[0].Time__c + ']');                
                throw new ExportException(100, 'Ha superado la cantidad máxima de registros que puede exportar [' + lstPermission[0].Time__c + ']');                
            }
        } else {
            lstPermission = [SELECT Records__c, MaxRecords__c, Time__c
                             FROM Permission_Type__c
                             WHERE Profile_Id__c =: UserInfo.getProfileId()];
            if(!lstPermission.isEmpty()) {
                if(objUser.Records_Processed__c < lstPermission[0].Records__c) {
                    intRecordsLimit = ( (lstPermission[0].Records__c - objUser.Records_Processed__c) > lstPermission[0].MaxRecords__c )?lstPermission[0].MaxRecords__c.intValue():(lstPermission[0].Records__c - objUser.Records_Processed__c).intValue();
                } else {
	                System.debug('Error: Ha superado la cantidad máxima de registros que puede exportar [' + lstPermission[0].Time__c + ']');
                    throw new ExportException(120, 'Ha superado la cantidad máxima de registros que puede exportar [' + lstPermission[0].Time__c + ']');                
                }
            } else {
                System.debug('Error: No tiene permisos de exportación.');
                throw new ExportException(130, 'No tiene permisos de exportación.');                                
            }
        }

        System.debug('checkQuota [' + intRecordsLimit + '] <-');

        return intRecordsLimit;
    }

    public static List<RemotingMessageHelper.FieldPermission> showFields(String strSObject) {
        Map<String, Schema.SObjectField> mapFields = null;
        Map<String, Schema.SObjectType> mapSchema = null;
        Schema.DescribeFieldResult objDecribeResult = null; 
        List<RemotingMessageHelper.FieldPermission> lstFields = null;
        RemotingMessageHelper.FieldPermission objFieldPermission = null;

        System.debug('showFields [ strSObject : ' + strSObject + '] ->');

        mapSchema = Schema.getGlobalDescribe();
        mapFields = mapSchema.get(strSObject).getDescribe().fields.getMap();
        lstFields = new List<RemotingMessageHelper.FieldPermission>();

        for(Schema.SObjectField objField : mapFields.Values()) {
            objDecribeResult = objField.getDescribe();
            objFieldPermission = new RemotingMessageHelper.FieldPermission();
            objFieldPermission.CanWrite = objDecribeResult.isUpdateable();
            objFieldPermission.CanRead = objDecribeResult.isAccessible();
            objFieldPermission.Name = objDecribeResult.getName();
            objFieldPermission.CanExport = false;

            lstFields.add(objFieldPermission);
        }

        System.debug('showFields [ ' + lstFields + ' ] <-');

        return lstFields;
    }

    private static void sendEmail(String strSubject, String strBody) {
        System.debug('sendEmail [ strSubject : ' + strSubject + ' - strBody : ' + strBody + '] ->');

        HelperFunctions.sendEmail(UserInfo.getUserEmail(), strSubject, strBody);

        System.debug('sendEmail [] <-');
    }

    @RemoteAction
    @future(callout=true)
    public static void exportStop(String strExportId) { 
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        RemotingMessageHelper.ExportWrapper objBody = null;

        System.debug('exportStop [strExportId : ' + strExportId + '] ->');

        try {
            if(String.isNotBlank(strExportId)) {
                System.debug('exportStop [objBody : ' + objBody + ']');
                objHttp = new Http();
                objRequest = new HttpRequest();
                objRequest.setMethod('GET');
                objRequest.setEndpoint('callout:HerokuAPI/export/' + strExportId + '/stop');

                try {
                    objResponse = objHttp.send(objRequest);
                    
                    if(objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {            
                        System.debug('exportStop BODY : ' + objResponse.getBody());
                    } else {
                        updateExportStatusWithError(strExportId, objResponse.getStatusCode(), objResponse.getBody());
                    }
                } catch (Exception Ex) {
                    if (Ex.getMessage() != 'Read timed out') {
                        HelperFunctions.handleRuntimeException(Ex);
                        updateExportStatusWithError(strExportId, objResponse.getStatusCode(), Ex.getMessage());    
                    }
                }                                               
            }
        } catch (ExportException Ex) {
            HelperFunctions.handleRuntimeException(Ex);
            updateExportStatusWithError(strExportId, -1, Ex.getMessage());              
        }

        System.debug('exportStop [] <-');
    }


    /*
      @RemoteAction
    public static String retrieveReportMetadata(Id strReportId) {
        Reports.ReportDescribeResult objResult = null;
        Reports.ReportMetadata objMetadata = null;
        String strReportType = null;
        
        System.debug('retrieveReportMetadata [ strReportId : ' + strReportId + '] ->');
        
        if(String.isNotBlank(strReportId)) {
            objResult = Reports.ReportManager.describeReport(strReportId);
            objMetadata = objResult.getReportMetadata();                  
            strReportType = objMetadata.getReportType().getType();  
        } 
        
        System.debug('retrieveReportMetadata [] <-');        
        return strReportType;
    }

@RemoteAction
    @future(callout=true)
    public static void createAndFillDataExtension(String strDataExtensionName, String strCSV) { 
        RemotingMessageHelper.OperationResult objResult = null;
        MarketingCloudAPIHandler objMC = null;
        RemotingMessageHelper.MarketingCloudAccessToken objAccessToken = null;
        List<MarketingCloudAPIHandler.Field> lstColumns = null;
        List<String> lstRecords = null;
        List<String> lstColumnNames = null;
        String strObjectId = null;
        
        System.debug('createAndFillDataExtension [ strDataName : ' + strDataExtensionName + ' - strCSV : ' + strCSV + '] ->');
        objResult = new RemotingMessageHelper.OperationResult();
        try {
            lstRecords = strCSV.split('\r');
            lstColumnNames = lstRecords[0].split(';');
            lstColumns = retrieveDataExtensionFields(lstColumnNames);
            lstRecords.remove(0);
            
            objMC = new MarketingCloudAPIHandler();
            objAccessToken = objMC.retrieveAccessToken();
            
            strObjectId = objMC.retrieveDataExtension(objAccessToken, strDataExtensionName);
            
            if(String.isBlank(strObjectId)) {
                strObjectId = objMC.createDataExtension(objAccessToken, strDataExtensionName, lstColumns);                
            }
             
            if(String.isNotBlank(strObjectId)) {
                objMC.fillDataExtension(objAccessToken, strObjectId, lstColumns, lstRecords );
                objResult.Code = 0;
                objResult.Message = 'La operación se esta ejecutando.';

            } else {
                throw new MarketingCloudAPIHandler.OperationException('No se encontró la data extension');
            }
        } catch(Exception Ex) {
            objResult.Code = 999;
            objResult.Message = Ex.getMessage();
            
            System.debug('Ex : ' + Ex.getMessage());
            System.debug('Ex : ' + Ex.getStackTraceString());
        }
        System.debug('createAndFillDataExtension [SIZE : ' + lstRecords.size() + ' * ' + lstColumns.size()  + ']');
        System.debug('createAndFillDataExtension [' + objResult + '] <-');
    }

private static List<MarketingCloudAPIHandler.Field> retrieveDataExtensionFields(List<String> lstColumns) {
        List<MarketingCloudAPIHandler.Field> lstFields = null;
		MarketingCloudAPIHandler.Field objField = null;
        
        lstFields = new List<MarketingCloudAPIHandler.Field>();
        objField = new MarketingCloudAPIHandler.Field();
        objField.Name = 'Subscriber Id';
        objField.Description = 'Subscriber Id';
        objField.IsNillable = false;
        objField.IsPrimaryKey = false;
        objField.FieldType = 'Number';
        objField.DefaultValue = '';
        lstFields.add(objField);
        
        if(!lstColumns.isEmpty()) {
            for(String strColumn : lstColumns) {
                objField = new MarketingCloudAPIHandler.Field();
                objField.Name = strColumn;
                objField.Description = strColumn;
                objField.MaxLength = 100;
                objField.IsNillable = false;
                objField.IsPrimaryKey = false;
                objField.FieldType = 'Text';
                objField.DefaultValue = '';
                lstFields.add(objField);
            }
        }
            
        return lstFields;
    }
*/

    public static void elmejortestlohacelusuarioenproduccion(){
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
    }

}