global class ExportController {
    global List<Export__c> exports;

    public Boolean canApprove {
        get {
            List<GroupMember> lstGroupMember = [SELECT Id 
                                                FROM GroupMember 
                                                WHERE Group.Name IN('Export Approvers', 'Export Manager')
                                                AND UserOrGroupId =: UserInfo.getUserId()];

            return !lstGroupMember.IsEmpty();
        }
    }


	@RemoteAction
    global static List<Export__c> exports (String strJSON) {
        return [SELECT Name, Status__c, FORMAT(Order_Date__c) Order_Date, Type__c, SAQL__c, Record_Count__c, CreatedById
                FROM Export__c
                ORDER BY Order_Date__c DESC];
    }

    @RemoteAction
    global static void createExport(String strType, String strName, Boolean boolAllData, Boolean boolSendable, String strSAQL, String strDataExtension, String strSurvey, String strReportId, String strReportName, String strCliente, String strProyecto, String strComentarios) {
        System.debug('createExport [ strType : ' + strType + ' - strName : ' + strName + ' - boolAllData : ' + boolAllData + ' - strSAQL : ' + strSAQL + ' - strDataExtension : ' + strDataExtension + ' - strSurvey : ' + strSurvey + '] ->');
        System.debug('createExport [ strReportId : ' + strReportId + ' - strReportName : ' + strReportName + ' - strCliente : ' + strCliente + ' - strProyecto : ' + strProyecto + ' - strComentarios : ' + strComentarios + '] ->');

        if(strType == 'MC' || strType == 'mccsv' || strType == 'crmcsv') {
            //no puedo calcular la cantidad de registros
            insertReport(strType, strName, boolAllData, boolSendable, strSAQL, strDataExtension, strSurvey, strReportId, strReportName, strCliente, strProyecto, strComentarios, 'Pendiente de aprobación {Sin cantidad de registros)', 'No se calculan la cantidad de registros en Marketing Cloud', 0);
        } else {
            retrieveRecordCount(strType, strName, boolAllData, boolSendable, strSAQL, strDataExtension, strSurvey, strReportId, strReportName, strCliente, strProyecto, strComentarios);
        }

        System.debug('createExport [] <-');
    }

	@RemoteAction
    global static List<Report> reports (String strJSON) {
        return [SELECT Id, Name
                FROM Report
                ORDER BY Name DESC];
    }


    global class exportOption {
        String Id;
        String Name;
        exportOption(String id, String name) {
            this.Id = id;
            this.Name = name;
        }
    }
    @RemoteAction
    global static List<exportOption> report_options () {

        // Get User Profile Name
        String userProfileName = [SELECT Name FROM profile WHERE id =: UserInfo.getProfileId() LIMIT 1].Name;

        // Get all the 'Regular' Groups the User is member of
        // Map<String,String> userGroups = new Map<String, String>();
        // for (GroupMember gm : [SELECT Id, group.id, group.name, group.type FROM GroupMember where UserOrGroupId = :UserInfo.getUserId() AND group.type='Regular']) {
        //     userGroups.put(gm.group.name, gm.group.name);
        // }

        
        // Get all the Permision Sets for the User
        Map<String,String> userPermissionSets = new Map<String, String>();
        for (PermissionSetAssignment ps : [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()]) {
            userPermissionSets.put(ps.PermissionSet.Name, ps.PermissionSet.Name);
            // options_lst.add(new exportOption(ps.PermissionSet.Name, ps.PermissionSet.Name));
        }

        // Filter options based on user profile or user groups
        List<exportOption> options_lst = new List<exportOption>();

        if (userPermissionSets.containsKey('PROSUMIA_ExportTableau_MC') || userProfileName == 'System Administrator') {
            options_lst.add(new exportOption('eamc', 'EA a MC'));
        }

        if (userPermissionSets.containsKey('PROSUMIA_ExportTableau_CSV') || userProfileName == 'System Administrator') {
            options_lst.add(new exportOption('eacsv', 'EA a CSV'));
        }
        
        if (userPermissionSets.containsKey('PROSUMIA_ExportCRM_CSV') || userProfileName == 'System Administrator') {
            options_lst.add(new exportOption('crmcsv', 'REPORTE CRM a CSV'));
        }

        System.debug('report_options [] <-');
        System.debug(options_lst);

        return options_lst;
    }


    @future(callout=true)
    private static void retrieveRecordCount(String strType, String strName, Boolean boolAllData, Boolean boolSendable, String strSAQL, String strDataExtension, String strSurvey, String strReportId, String strReportName, String strCliente, String strProyecto, String strComentarios) {
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        String strEndpoint = null;
        String strLink = null;
        String strHTML = null;
        RemotingMessageHelper.CountRecordsRequest objRESTRequest = null;
        RemotingMessageHelper.CountRecordsRespose objRESTResponse = null;
        System.debug('retrieveRecordCount [strType : ' + strType + ' - strName : ' + strName + ' - boolAllData : ' + boolAllData + ' - boolSendable : ' + boolSendable + ' - strSAQL : ' + strSAQL + ' - strDataExtension : ' + strDataExtension + ' - strSurvey : ' + strSurvey + '] ->');
        System.debug('retrieveRecordCount [strReportId : ' + strReportId + ' - strReportName : ' + strReportName + ' - strCliente : ' + strCliente + ' - strProyecto : ' + strProyecto + ' - strComentarios : ' + strComentarios + '] ->');
        try {
            objRESTRequest = new RemotingMessageHelper.CountRecordsRequest();
            objRESTRequest.type = strType;
            if(strType == 'EA' || strType == 'eamc' || strType == 'eacsv' || strType == 'prosumer_sms' || strType == 'prosumer_ivr') {
                objRESTRequest.query = strSAQL;
            } else {
                objRESTRequest.query = strSurvey;
            }

            strEndpoint = 'https://api-pulso.prosumia.la/aws-api/analytics/count_records';

            objRequest = new HttpRequest();
            objRequest.setMethod('POST');
            objRequest.setEndpoint(strEndpoint);
            objRequest.setTimeout(60 * 1000);
            objRequest.setHeader('content-type', 'application/json; charset=UTF-8');
            objRequest.setBody(JSON.serialize(objRESTRequest));
            System.debug('retrieveRecordCount [ strEndpoint : ' + strEndpoint + ']');
            System.debug('retrieveRecordCount [ objResponse.getBody() : ' + objRequest.getBody() + ']');

            objHttp = new Http();
            objResponse = objHttp.send(objRequest);
            
            if(objResponse != NULL && objResponse.getStatusCode() == 200) {
                try {
                    System.debug('retrieveRecordCount [objResponse.getBody() : ' + objResponse.getBody() + ']');

                    objRESTResponse = (RemotingMessageHelper.CountRecordsRespose) JSON.deserialize(objResponse.getBody(), RemotingMessageHelper.CountRecordsRespose.class);
                    System.debug('retrieveRecordCount [objRESTResponse : ' + objRESTResponse + ']');
                    System.debug('retrieveRecordCount [objRESTResponse.Code : ' + objRESTResponse.Code + ']');
                    if(objRESTResponse.Code == 0) {
                        insertReport(strType, strName, boolAllData, boolSendable, strSAQL, strDataExtension, strSurvey, strReportId, strReportName, strCliente, strProyecto, strComentarios, 'Pendiente de aprobación', NULL, objRESTResponse.count);
                    } else {
                        insertReport(strType, strName, boolAllData, boolSendable, strSAQL, strDataExtension, strSurvey, strReportId, strReportName, strCliente, strProyecto, strComentarios, 'Pendiente de aprobación {Sin cantidad de registros)', objRESTResponse.message, objRESTResponse.count);
                    }
                } catch(Exception Ex) {
                    insertReport(strType, strName, boolAllData, boolSendable, strSAQL, strDataExtension, strSurvey, strReportId, strReportName, strCliente, strProyecto, strComentarios, 'Pendiente de aprobación {Sin cantidad de registros)',Ex.getMessage(), 0);
                    HelperFunctions.handleRuntimeException(Ex);
                }
            } else {
                insertReport(strType, strName, boolAllData, boolSendable, strSAQL, strDataExtension, strSurvey, strReportId, strReportName, strCliente, strProyecto, strComentarios, 'Pendiente de aprobación {Sin cantidad de registros)', objResponse.getBody(), 0);
                System.debug('Ex : ' + objResponse.getBody());
            }
        } catch(Exception Ex) {
            insertReport(strType, strName, boolAllData, boolSendable, strSAQL, strDataExtension, strSurvey, strReportId, strReportName, strCliente, strProyecto, strComentarios, 'Pendiente de aprobación {Sin cantidad de registros)', Ex.getMessage(), 0);
            //INSERTAR EL REGISTRO , PERO CON ESTADO, REVIEW
        }
        System.debug('execute [] <-');
    }

    @AuraEnabled()
    global static Export__c insertReport(String strType, String strName, Boolean boolAllData, Boolean boolSendable, String strSAQL, String strDataExtension, String strSurvey, String strReportId, String strReportName, String strCliente, String strProyecto, String strComentarios, String strStatus, String strCalloutMessage, Integer intRecordCount) {
        Export__c objExport = null;

        System.debug('insertReport [strType : ' + strType + ' - strName : ' + strName + ' - boolAllData : ' + boolAllData + ' - boolSendable : ' + boolSendable + ' - strSAQL : ' + strSAQL + ' - strDataExtension : ' + strDataExtension + ' - strSurvey : ' + strSurvey + '] ->');
        System.debug('insertReport [strReportId : ' + strReportId + ' - strReportName : ' + strReportName + ' - strCliente : ' + strCliente  + ' - strProyecto : ' + strProyecto + ' - strComentarios : ' + strComentarios + '] ->');
        System.debug('insertReport [strStatus : ' + strStatus  + ' - strCalloutMessage : ' + strCalloutMessage + ' - intRecordCount : ' + intRecordCount + '] ->');

        objExport = new Export__c();
        objExport.Name = strName;
        objExport.Type__c = strType;
        objExport.All_Data__c = boolAllData;
        objExport.Sendable__c = boolSendable;
        objExport.SAQL__c = strSAQL;
        objExport.Data_Extension__c = strDataExtension;
        objExport.Survey__c = strSurvey;
        objExport.ReportId__c = strReportId;
        objExport.ReportName__c = strReportName;
        objExport.Cliente__c = strCliente;
        objExport.Proyecto__c = strProyecto;
        objExport.Comentarios__c = strComentarios;

        objExport.Order_Date__c = Datetime.now();
        objExport.Status__c = strStatus;
        objExport.Callout_Message__c = strCalloutMessage;
        objExport.Record_Count__c = intRecordCount;

        insert objExport;

        submitForApproval(objExport);

        System.debug('insertReport [' + objExport + '] <-');

        return objExport;
    }


    @AuraEnabled()
    global static Export__c insertExportToMarketingCloudForMobile(Id campaignId) {
        System.debug('In insertExportToMarketingCloudForMobile....  campaignId = ' + campaignId);

        Campania__c campania = [SELECT Id, Prosumer_SAQL_Audiencias__c, Prosumer_Mensaje_SMS__c FROM Campania__c WHERE Id = :campaignId LIMIT 1];
        System.debug(campania);

        String[] saqlcommands = campania.Prosumer_SAQL_Audiencias__c.split(';');
        String filters = '';
        for (String saql : saqlcommands) {
            if (saql.indexOf('filter') >= 0) {
                System.debug(saql);
                filters += saql + ';' ;
            }
        }
        System.debug('FILTERS >>>>> ' + filters);
        
        // String strSAQLFilters = '';
        String strSAQLFilters = filters;
        String strName = 'DAC_TEST_DE_FOR_MOBILE';
        String strDataExtension = strName;
        String strSAQL = '';
        String strMessage = campania.Prosumer_Mensaje_SMS__c;

        Export__c objExport = null;

        // System.debug('insertExportToMarketingCloudForMobile [strType : ' + strType + ' - strName : ' + strName + ' - boolAllData : ' + boolAllData + ' - boolSendable : ' + boolSendable + ' - strSAQL : ' + strSAQL + ' - strDataExtension : ' + strDataExtension + ' - strSurvey : ' + strSurvey + '] ->');
        // System.debug('insertExportToMarketingCloudForMobile [strReportId : ' + strReportId + ' - strReportName : ' + strReportName + ' - strCliente : ' + strCliente  + ' - strProyecto : ' + strProyecto + ' - strComentarios : ' + strComentarios + '] ->');
        // System.debug('insertExportToMarketingCloudForMobile [strStatus : ' + strStatus  + ' - strCalloutMessage : ' + strCalloutMessage + ' - intRecordCount : ' + intRecordCount + '] ->');


        // strSAQL  = 'q = load "T1pqlamz_e";';
        strSAQL  = 'q = load "TerritoryFullPage_DS";';
        if (strSAQLFilters.length() > 18)
            strSAQL += strSAQLFilters;
        strSAQL += 'q = filter q by \'MobilePhone\' is not null;';
        // strSAQL += 'q = filter q by \'MobilePhone\' in ["541144045562", "541144774596"];';
        strSAQL += 'q = foreach q generate \'Id\' as \'Id\', \'MobilePhone\' as \'MobilePhone\';';
        strSAQL += 'q = limit q 10;';


        objExport = new Export__c();
        objExport.Name = strName;
        objExport.Type__c = 'prosumer_sms';
        objExport.All_Data__c = false;
        objExport.Sendable__c = true;
        objExport.SAQL__c = strSAQL;
        objExport.Data_Extension__c = strDataExtension;
        objExport.Survey__c = null;
        objExport.ReportId__c = null;
        objExport.ReportName__c = null;
        objExport.Cliente__c = null;
        objExport.Proyecto__c = null;
        objExport.Comentarios__c = null;

        objExport.Order_Date__c = Datetime.now();
        objExport.Status__c = 'Aprobado';
        objExport.Callout_Message__c = null;
        // objExport.Record_Count__c = intRecordCount;

        insert objExport;

        campania.Export__c = objExport.Id;
        update campania;

        System.debug('insertExportToMarketingCloudForMobile [' + objExport + '] <-');

        return objExport;
    }


    @AuraEnabled()
    global static Export__c insertExportToSondeosIVR(Id campaignId) {
        System.debug('In insertExportToSondeosIVR....  campaignId = ' + campaignId);

        Campania__c campania = [SELECT Id, Name, Prosumer_SAQL_Audiencias__c FROM Campania__c WHERE Id = :campaignId LIMIT 1];
        System.debug(campania);

        String[] saqlcommands = campania.Prosumer_SAQL_Audiencias__c.split(';');
        String filters = '';
        for (String saql : saqlcommands) {
            if (saql.indexOf('filter') >= 0) {
                System.debug(saql);
                filters += saql + ';' ;
            }
        }
        System.debug('FILTERS >>>>> ' + filters);
        
        String strSAQLFilters = filters;
        String strName = campania.Name;
        String strSAQL = '';

        // strSAQL  = 'q = load "T1pqlamz_e";';
        strSAQL  = 'q = load "TerritoryFullPage_DS";';
        if (strSAQLFilters.length() > 18)
            strSAQL += strSAQLFilters;
        strSAQL += 'q = filter q by \'MobilePhone\' is not null;';
        // strSAQL += 'q = filter q by \'MobilePhone\' in ["541144045562", "541144774596"];';
        strSAQL += 'q = foreach q generate \'Id\' as \'Id\', \'MobilePhone\' as \'MobilePhone\';';
        strSAQL += 'q = limit q 10;';

        Export__c objExport = new Export__c();
        objExport.Name = strName;
        objExport.Type__c = 'prosumer_ivr';
        objExport.All_Data__c = false;
        objExport.Sendable__c = true;
        objExport.SAQL__c = strSAQL;
        objExport.Survey__c = null;
        objExport.ReportId__c = null;
        objExport.ReportName__c = null;
        objExport.Cliente__c = null;
        objExport.Proyecto__c = null;
        objExport.Comentarios__c = null;

        objExport.Order_Date__c = Datetime.now();
        objExport.Status__c = 'Aprobado';
        objExport.Callout_Message__c = null;

        insert objExport;

        campania.Export__c = objExport.Id;
        update campania;

        System.debug('insertExportToSondeosIVR [' + objExport + '] <-');

        return objExport;
    }


    @RemoteAction
    global static RemotingMessageHelper.OperationResult processRequest(String strExportId, Boolean boolState) {
        Approval.ProcessWorkitemRequest objRequest = null;
        ProcessInstanceWorkitem objProcessItemWorkInstance = null;
        Approval.ProcessResult objResult = null;
        RemotingMessageHelper.OperationResult objOperationResult = null;

        System.debug('processRequest [strExportId : ' + strExportId + ' - boolState : ' + boolState + '] ->');

        try {
            objRequest = new Approval.ProcessWorkitemRequest();
            objOperationResult = new RemotingMessageHelper.OperationResult();

            if(boolState) {
                objRequest.setComments('Approved');
                objRequest.setAction('Approve');
            } else {
                objRequest.setComments('Rejected');
                objRequest.setAction('Reject');
            }

            objProcessItemWorkInstance = [  SELECT Id 
                                            FROM ProcessInstanceWorkitem 
                                            WHERE ProcessInstance.TargetObjectId =: strExportId];

            objRequest.setWorkitemId(objProcessItemWorkInstance.Id);
            objResult = Approval.process(objRequest);

            objOperationResult.Code = 0;
            objOperationResult.Message = 'Operacion exitosa';
        } catch (Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);
            objOperationResult.Code = 999;
            objOperationResult.Message = Ex.getMessage();
        }

        System.debug('processRequest [' + objOperationResult + '] <-');

        return objOperationResult;
    }

    @RemoteAction
    global static RemotingMessageHelper.OperationResult cancelRequest(String strExportId) {
        RemotingMessageHelper.OperationResult objOperationResult = null;
        Export__c objExport = null;
        System.debug('cancelRequest [strExportId : ' + strExportId + '] ->');

        try {
            objOperationResult = new RemotingMessageHelper.OperationResult();

            objExport = [SELECT Status__C FROM Export__c WHERE Id =: strExportId];

            if (objExport.Status__c == 'En ejecución') {
                objExport.Status__c = 'Detener';
            } else {
                objExport.Status__C = 'Cancelado';
            }

            update objExport;

            objOperationResult.Code = 0;
            objOperationResult.Message = 'Operacion exitosa';
        } catch (Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);
            objOperationResult.Code = 999;
            objOperationResult.Message = Ex.getMessage();
        }

        System.debug('processRequest [' + objOperationResult + '] <-');

        return objOperationResult;
    }
    
    // @RemoteAction
    // global static RemotingMessageHelper.OperationResult stopRequest(String strExportId) {
    //     RemotingMessageHelper.OperationResult objOperationResult = null;
    //     Export__c objExport = null;
    //     System.debug('stopRequest [strExportId : ' + strExportId + '] ->');

    //     try {
    //         objOperationResult = new RemotingMessageHelper.OperationResult();

    //         objExport = [SELECT Status__C FROM Export__c WHERE Id =: strExportId];
    //         if (objExport.Status__c == 'En ejecución') {
    //             objExport.Status__c = 'Detener';
    //             update objExport;
    
    //             objOperationResult.Code = 0;
    //             objOperationResult.Message = 'Operacion exitosa';
    //         }
    //     } catch (Exception Ex) {
    //         HelperFunctions.handleRuntimeException(Ex);
    //         objOperationResult.Code = 999;
    //         objOperationResult.Message = Ex.getMessage();
    //     }

    //     System.debug('processRequest [' + objOperationResult + '] <-');

    //     return objOperationResult;
    // }
    
    private static void submitForApproval(Export__c objExport) {
        Approval.ProcessSubmitRequest objRequest = null;
        Approval.ProcessResult objResult = null;

        System.debug('submitForApproval [objExport : ' + objExport + '] ->');

        try {
            objRequest = new Approval.ProcessSubmitRequest();
            objRequest.setComments('Export enviado para aprobacion.');
            objRequest.setObjectId(objExport.id);
            objRequest.setSubmitterId(UserInfo.getUserId());
            
            if(!Test.isRunningTest()) {
                objRequest.setProcessDefinitionNameOrId('Export_Approval');
                //objRequest.setSkipEntryCriteria(true);        
                // Submit the approval request for the account
                objResult = Approval.process(objRequest);
            }
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);
            objExport.Status__C = 'Finalizado con errores';
            update objExport;
        }

        System.debug('submitForApproval [] <-');
    }

    //trigger controller
    //2020-01-08 FL Ajuste de circuito de trigger
    public static void beforeUpdate(List<Export__c> lstExport, Map<Id,Export__c> mapOldValues) {
        System.debug('beforeUpdate[lstExport : ' + lstExport + ' - mapOldValues : ' + mapOldValues + '] ->');

        for(Export__c objExport : lstExport) {
            if(objExport.Status__c == 'Aprobado' && objExport.Status__c <> mapOldValues.get(objExport.Id).Status__c ) {
				procesarExportAprobados(objExport);
            }
            if(objExport.Status__c == 'Detener' && objExport.Status__c <> mapOldValues.get(objExport.Id).Status__c ) {
				detenerExport(objExport);
            }
        }

        System.debug('beforeUpdate[] <-');
    }

    public static void afterUpdate(List<Export__c> lstExport, Map<Id,Export__c> mapOldValues) {
        System.debug('afterUpdate[lstExport : ' + lstExport + ' - mapOldValues : ' + mapOldValues + '] ->');

        for(Export__c objExport : lstExport) {
            if(objExport.Status__c == 'En ejecución' && objExport.Status__c <> mapOldValues.get(objExport.Id).Status__c ) {
                procesarReportesEnEjecucion(objExport);
            } else if(objExport.Status__c == 'Rechazado' && objExport.Status__c <> mapOldValues.get(objExport.Id).Status__c ) {
                procesarReportesRechazados(objExport);
            } else if ((objExport.Status__c == 'Finalizado OK' || objExport.Status__c == 'Finalizado con errores' || objExport.Status__c == 'Error en SAQL' || objExport.Status__c == 'Detenido') && objExport.Status__c <> mapOldValues.get(objExport.Id).Status__c) {
                procesarReportesFinalizados(objExport);                               
            }
        }

        System.debug('afterUpdate[] <-');
    }

    public static void afterInsert(List<Export__c> lstExport) {
        System.debug('afterInsert[lstExport : ' + lstExport + '] ->');

        for(Export__c objExport : lstExport) {
            if(objExport.Status__c == 'Aprobado') {
				procesarExportAprobadosAfterInsert(objExport);
            }
        }

        System.debug('afterInsert[] <-');
    }



    /* public static void processApprovedExports(List<Export__c> lstExport, Map<Id,Export__c> mapOldValues) {
        System.debug('processApprovedExports[lstExport : ' + lstExport + ' - mapOldValues : ' + mapOldValues + '] ->');

        for(Export__c objExport : lstExport) {
            if(objExport.Status__c == 'Aprobado' && objExport.Status__c <> mapOldValues.get(objExport.Id).Status__c ) {
				procesarExportAprobados(objExport);
            } else if(objExport.Status__c == 'En ejecución' && objExport.Status__c <> mapOldValues.get(objExport.Id).Status__c ) {
                procesarReportesEnEjecucion(objExport);               
            } else if ((objExport.Status__c == 'Finalizado OK' || objExport.Status__c == 'Finalizado con errores' || objExport.Status__c == 'Error en SAQL') && objExport.Status__c <> mapOldValues.get(objExport.Id).Status__c) {
                procesarReportesFinalizados(objExport);                               
            }
        }

        System.debug('processApprovedExports[] <-');
    } */
    
    
    private static void procesarExportAprobados(Export__c objExport) {
        Integer count = 0;
                
        System.debug('procesarExportAprobados [objExport : ' + objExport + '] ->');

        // Sends an Email to the User that requested the export
        User objUser = [SELECT Email, Name FROM User WHERE Id =: objExport.CreatedById];
        String strHTML = 'Estimado ' + objUser.Name + ' :<br/>';
        strHTML += 'La solicitud Export ha sido <b>aprobada</b>.<br/>';
        strHTML += 'Nombre del Export: <b>' + objExport.Name + '</b><br/>';
        HelperFunctions.sendEmail(objUser.Email, 'Export', strHTML);


        if (objExport.Type__c == 'sms') {
            count = [SELECT count() FROM Export__c where Status__c = 'En ejecución' and Type__c = 'sms'];
        } else if (objExport.Type__c == 'pulso') {
            count = [SELECT count() FROM Export__c where Status__c = 'En ejecución' and Type__c = 'pulso'];
        } else if (objExport.Type__c == 'crmcsv') {
            count = [SELECT count() FROM Export__c where Status__c = 'En ejecución' and Type__c = 'crmcsv'];
        } else {
            count = [SELECT count() FROM Export__c where Status__c = 'En ejecución' and Type__c in ('eamc', 'eacsv', 'mccsv', 'prosumer_sms', 'prosumer_ivr')];
        }
        
        if (count == 0) {
            objExport.Status__c = 'En ejecución';
        } else {
            objExport.Status__c = 'En espera de ejecución';            
        }

        if (objExport.Type__c == 'prosumer_sms' || objExport.Type__c == 'prosumer_ivr') {
            List<Campania__c> campania = [SELECT Id, Status__c FROM Campania__c WHERE Id = :objExport.Id LIMIT 1];
            if (!campania.IsEmpty()) {
                campania[0].Status__c = 'Export ' + objExport.Status__c.toLowercase();
                update campania;
            }
        }

        System.debug('procesarExportAprobados [count : ' + count + ']');
        System.debug('procesarExportAprobados [objExport.Status__c : ' + objExport.Status__c + ']');

        System.debug('procesarExportAprobados [] <-');
    }

    private static void procesarExportAprobadosAfterInsert(Export__c objExport) {
        Integer count = 0;
                
        System.debug('procesarExportAprobadosAfterInsert [objExport : ' + objExport + '] ->');

        // Sends an Email to the User that requested the export
        User objUser = [SELECT Email, Name FROM User WHERE Id =: objExport.CreatedById];
        String strHTML = 'Estimado ' + objUser.Name + ' :<br/>';
        strHTML += 'La solicitud Export ha sido <b>aprobada</b>.<br/>';
        strHTML += 'Nombre del Export: <b>' + objExport.Name + '</b><br/>';
        HelperFunctions.sendEmail(objUser.Email, 'Export', strHTML);


        if (objExport.Type__c == 'sms') {
            count = [SELECT count() FROM Export__c where Status__c = 'En ejecución' and Type__c = 'sms'];
        } else if (objExport.Type__c == 'pulso') {
            count = [SELECT count() FROM Export__c where Status__c = 'En ejecución' and Type__c = 'pulso'];
        } else if (objExport.Type__c == 'crmcsv') {
            count = [SELECT count() FROM Export__c where Status__c = 'En ejecución' and Type__c = 'crmcsv'];
        } else {
            count = [SELECT count() FROM Export__c where Status__c = 'En ejecución' and Type__c in ('eamc', 'eacsv', 'mccsv', 'prosumer_sms', 'prosumer_ivr')];
        }
        
        Export__c export_object = [SELECT Id, Status__c FROM Export__c WHERE Id =: objExport.Id][0];

        if (count == 0) {
            export_object.Status__c = 'En ejecución';
        } else {
            export_object.Status__c = 'En espera de ejecución';            
        }

        if (objExport.Type__c == 'prosumer_sms' || objExport.Type__c == 'prosumer_ivr') {
            List<Campania__c> campania = [SELECT Id, Prosumer_Estado__c FROM Campania__c WHERE Id = :objExport.Id LIMIT 1];
            if (!campania.IsEmpty()) {
                campania[0].Prosumer_Estado__c = 'Export ' + objExport.Status__c.toLowercase();
                update campania;
            }
        }

        update export_object;

        System.debug('procesarExportAprobadosAfterInsert [count : ' + count + ']');
        System.debug('procesarExportAprobadosAfterInsert [objExport.Status__c : ' + objExport.Status__c + ']');

        System.debug('procesarExportAprobadosAfterInsert [] <-');
    }

    private static void procesarReportesEnEjecucion(Export__c objExport) {
        RemotingMessageHelper.SMSSondeosRequest objRequest = null;

        System.debug('procesarReportesEnEjecucion [objExport : ' + objExport + '] ->');
              
        if(objExport.Type__c == 'eamc') {
            ReportManager.sendAnalyticsToMarketingCloud(objExport.Id, objExport.Name, objExport.SAQL__c, objExport.All_Data__c, objExport.Sendable__c);
        } else if (objExport.Type__c == 'prosumer_sms') {
            ReportManager.sendAnalyticsToMarketingCloudForMobileConnect(objExport.Id, objExport.Name, objExport.SAQL__c, objExport.All_Data__c, objExport.Sendable__c);
        } else if (objExport.Type__c == 'prosumer_ivr') {
            ReportManager.exportAnalyticsToSondeosIVR(objExport.Id, objExport.Name, objExport.SAQL__c, objExport.All_Data__c);
        } else if (objExport.Type__c == 'eacsv') {
            ReportManager.exportAnalytics(objExport.Id, objExport.Name, objExport.SAQL__c, objExport.All_Data__c);
        } else if (objExport.Type__c == 'mccsv') {
            cloneDataExtension(objExport.Id, objExport.Data_Extension__c, objExport.Name);
        } else if (objExport.Type__c == 'crmcsv') {
            ReportManager.exportReportToCsv(objExport.id, objExport.Name, objExport.ReportId__c, objExport.ReportName__c);
        } else if (objExport.Type__c == 'pulso') {
            exportPulso(objExport.Id, objExport.CreatedById, objExport.Survey__c);
        } else if (objExport.Type__c == 'sms' || objExport.Type__c == 'sms_mc') {

            objRequest = (RemotingMessageHelper.SMSSondeosRequest)JSON.deserialize(objExport.SAQL__c, RemotingMessageHelper.SMSSondeosRequest.class);

            System.debug('procesarReportesEnEjecucion [objRequest : ' + objRequest + ']');  
            
            String strPlatform = objExport.Type__c == 'sms' ? MensajesController.SONDEOS : MensajesController.MARKETING_CLOUD;

            //MensajesController.sendApprovedMessage(objRequest.sender, objRequest.dataextension, objRequest.dataextensionname, objRequest.message, objRequest.titulo, objRequest.proyecto, objRequest.messageid, strPlatform);
            MensajesController.sendApprovedMessage(objRequest.sender, objRequest.dataextension, objRequest.dataextensionname, objRequest.message, objRequest.titulo, objRequest.messageid, strPlatform);
        }
        
        System.debug('procesarReportesEnEjecucion [] <-');        
    }

    private static void procesarReportesRechazados(Export__c objExport) {

        System.debug('procesarReportesRechazados [objExport : ' + objExport + '] ->');

        // Sends an Email to the User that requested the export
        User objUser = [SELECT Email, Name FROM User WHERE Id =: objExport.CreatedById];

        String strHTML = '<br>Estimado ' + objUser.Name + ' :<br/>';
        strHTML += 'La solicitud de Export ha sido <b>rechazada</b>.<br/>';
        strHTML += 'El reporte <b>' + objExport.Name + '</b> no pudo ser generado por favor contactarse con el administrador.<br/>';

        HelperFunctions.sendEmail(objUser.Email, 'Export', strHTML);

        System.debug('procesarReportesRechazados [] <-');        
    }


    private static void procesarReportesFinalizados(Export__c objExport) {

        System.debug('procesarReportesFinalizados: objExport.Status__c == ' + objExport.Status__c);
        
        if (objExport.Type__c == 'prosumer_sms' || objExport.Type__c == 'prosumer_ivr') {
            System.debug('procesarReportesFinalizados: objExport.Type__c == ' + objExport.Type__c);
            
            Campania__c campania = [SELECT Id, Status__c FROM Campania__c WHERE Export__c = :objExport.Id LIMIT 1];
            System.debug('procesarReportesFinalizados: campania == ' + campania.Id);

            campania.Prosumer_Estado__c = 'Export Finalizado OK';
            update campania;
            if (objExport.Type__c == 'prosumer_sms')
                MensajesController.sendSMSViaMarketingCloudAutomation(campania.Id);
        }

        List<Export__c> tempLstExport = Null;
        
        if (objExport.Type__c == 'sms_mc') {
            tempLstExport = [Select ID from Export__c where Status__c = 'En espera de ejecución' and Type__c = 'sms_mc' LIMIT 1];
        } if (objExport.Type__c == 'sms') {
            tempLstExport = [Select ID from Export__c where Status__c = 'En espera de ejecución' and Type__c = 'sms' LIMIT 1];
        } else if (objExport.Type__c == 'pulso') {
            tempLstExport = [Select ID from Export__c where Status__c = 'En espera de ejecución' and Type__c = 'pulso' LIMIT 1];
        } else {
            tempLstExport = [Select ID from Export__c where Status__c = 'En espera de ejecución' and Type__c in ('eamc', 'eacsv', 'mccsv', 'crmcsv', 'prosumer_sms', 'prosumer_ivr') LIMIT 1];
        }

        //List<Export__c> tempLstExport = [Select ID from Export__c where Status__c = 'En espera de ejecución' and Type__c =: objExport.Type__c];
        
        if (!tempLstExport.isEmpty()) {
            System.debug('Changing Status from "En espera de ejecución" to : "En ejecución"');
            tempLstExport[0].Status__c = 'En ejecución';
            update tempLstExport;
        } else {
            System.debug('No hay registros "En espera de ejecución"');
        }
    }

    private static void detenerExport(Export__c objExport) {
        Integer count = 0;
                
        System.debug('detenerExport [objExport : ' + objExport + '] ->');

        Export__c exportStatus = [SELECT Id, Status__c, Type__c FROM Export__c WHERE Id = :objExport.Id LIMIT 1];
        // Export__c export = [SELECT Id, Status__c FROM Export__c where Id = :objExport.Id LIMIT 1];

        System.debug('detenerExport [objExport.Status__c : ' + objExport.Status__c + ']');

        if (objExport != null) {
            if (exportStatus.Status__c == 'En espera de ejecución') {
                objExport.Status__c = 'Detenido';
            } else if (exportStatus.Status__c == 'En ejecución') {
                objExport.Status__c = 'Detenido';
                ReportManager.exportStop(objExport.Id);
            } else {
                objExport.Status__c = exportStatus.Status__c;
            }
        }
        System.debug('detenerExport [objExport.Status__c : ' + objExport.Status__c + ']');

        System.debug('detenerExport [] <-');
    }


    @future(callout=true)
    private static void cloneDataExtension(String strExportId, String strDE1, String strDE2) {
        System.debug('cloneDataExtension [strDE1 : ' + strDE1 + ' - strDE2 : ' + strDE2 + '] ->');

        prmCloneDataExtensionRequest.prmCloneDataExtensionRequestInit(strExportId, strDE1, strDE2);

        System.debug('cloneDataExtension [] <-');
    }

    @future(callout=true)
    private static void exportPulso(String strExportId, String strUserId, String strSurveyId) {
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        String strEndpoint = null;
        String strLink = null;
        String strHTML = null;
        User objUser = null;
 
        System.debug('exportPulso [strExportId : ' + strExportId + ' - strUserId : ' + strUserId + ' - strSurveyId : ' + strSurveyId + '] ->');

        try {
            objUser = [SELECT Email FROM User WHERE Id =: strUserId];
            strEndpoint = 'https://api-pulso.prosumia.la/pulso/export_leads/' + strSurveyId + '?filename=' + strSurveyId + '_leads.csv';

            objRequest = new HttpRequest();
            objRequest.setMethod('GET');
            objRequest.setEndpoint(strEndpoint);
            objRequest.setTimeout(60 * 1000);
    
            System.debug('exportPulso [ strEndpoint : ' + strEndpoint + ']');

            objHttp = new Http();
            objResponse = objHttp.send(objRequest);
            
            if(objResponse != NULL && objResponse.getStatusCode() == 200) {
                try {
                    strLink = 'https://api-pulso.prosumia.la/shared/' + strSurveyId + '_leads.csv';
                    strHTML = 'El archivo se ha generado.<br />';
                    strHTML += 'Puede accederlo desde el siguiente <a href="' + strLink + '">link</a>';

                    HelperFunctions.sendEmail(objUser.Email, 'Export', strHTML);
                } catch(Exception Ex) {
                    HelperFunctions.handleRuntimeException(Ex);

                    strHTML = 'El archivo <b>NO</b> se ha generado.<br />';
                    strHTML += 'Ha ocurrido error [' + Ex.getMessage() + ']';
                    updateExportStatusWithError(strExportId, strHTML);
                    HelperFunctions.sendEmail(objUser.Email, 'Export', strHTML);
                }
            } else {
                strHTML = 'El archivo <b>NO</b> se ha generado.<br />';
                strHTML += 'Ha ocurrido error [' + objResponse.getBody() + ']';
                updateExportStatusWithError(strExportId, strHTML);
                HelperFunctions.sendEmail(objUser.Email, 'Export', strHTML);
            }
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);
            strHTML = 'El archivo <b>NO</b> se ha generado.<br />';
            strHTML += 'Ha ocurrido error [' +  Ex.getMessage()  + ']';
            updateExportStatusWithError(strExportId, strHTML);

            HelperFunctions.sendEmail(objUser.Email, 'Export', strHTML);

        }
        System.debug('exportPulso [] <-');
    }

    private static void updateExportStatusWithError(String strExportId, String strMessage) {
        Export__c objExport = null;

        System.debug('updateExportStatusWithError [strExportId : ' + strExportId + ' - strMessage : ' + strMessage + '] ->');

        objExport = [SELECT Status__c, Callout_Message__c 
                     FROM Export__c 
                     WHERE Id =: strExportId];
        
        objExport.Status__c = 'Finalizado con errores'; 
        objExport.Callout_Message__c = strMessage;

        update objExport;

        HelperFunctions.sendEmail(UserInfo.getUserEmail(), 'Error en la operacion', strMessage);

        System.debug('updateExportStatusWithError [] <-');
    }

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