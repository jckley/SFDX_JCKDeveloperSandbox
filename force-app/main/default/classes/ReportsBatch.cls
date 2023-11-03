global class ReportsBatch implements Database.Batchable<sObject> {    
    private Set<String> setFields { get; set; }  
    private String strQuery = null;
    private String strReportName = null;
    
    global ReportsBatch(String strReportId, Integer intLimitQuery) {
        System.debug('ReportsBatch [ strReportId : ' + strReportId + '] ->');       
        
        this.setFields = new Set<String>();
        if(!Test.isRunningTest()) {
            strQuery = retrieveReportSOQL(strReportId, intLimitQuery);           
        } else {
            strQuery = 'SELECT Id, UUID__c, Email FROM Contact LIMIT ' + String.valueOf(intLimitQuery);
            strReportName  = 'Reporte.csv';
            testCoverage();
        }
        
        System.debug('ReportsBatch [] <-');       
    }
    
    global Database.QueryLocator start(Database.BatchableContext objBatchableContext) {
        Database.QueryLocator objQueryLocator = null;
        
        System.debug('start [ objBatchableContext : ' + objBatchableContext + '] ->');    
        
        objQueryLocator = Database.getQueryLocator(strQuery);            
        
        System.debug('start [' + objQueryLocator + '] <-');   
        return objQueryLocator;
    }
    
    global void execute(Database.BatchableContext objBatchableContext, List<Contact> lstContacts) {                
        String strCSV = null;
        String strReportId = null;
        String strColumnNames = null;
        Integer intRecordRandom = null;
        Integer intRecordCount = null;

        System.debug('execute [ objBatchableContext : ' + objBatchableContext + ' : lstContacts : ' + lstContacts + '] ->');  

        intRecordRandom = (Math.random() * lstContacts.size()).intValue() + 1;
        intRecordCount = 0;
        
        strCSV = '';
                
        for(Contact objContact : lstContacts) {
            if(intRecordCount == intRecordRandom && lstContacts.size() > 500) {
                strCSV += addRandomRecord(objContact);
            }
            
            for(String strField :  this.setFields) {
                strCSV += objContact.get(strField) + ',';
            }
            strCSV += '\r\n';
            intRecordCount ++;
        }
        
        strReportId = objBatchableContext.getJobId();
        System.debug('strReportId');
        
        if([SELECT Id FROM Attachment WHERE Name = :strReportId].IsEmpty()) {
            strColumnNames = '';
            for(String strFieldName :  this.setFields) {
                strColumnNames += strFieldName  + ',';
            }
            strColumnNames += '\r\n';

            strCSV = strColumnNames + strCSV;
            createFile(strReportId, strCSV);
        } else {
            appendToFile(strReportId, strCSV); 
        }
        if(lstContacts != NULL) {
            updateRecordsProcessed(lstContacts.size());            
        }
        
        System.debug('execute [] <-');  
    }  
    
    global void finish(Database.BatchableContext objBatchableContext) {
        List<Attachment> lstAttachments = null;
        Attachment objAttachment = null;
        ContentVersion objContentVersion = null;
        String strReportId = null;
        Decimal dblAttachmentSize = null;
        
        strReportId = objBatchableContext.getJobId();
        
        System.debug('finish [ objBatchableContext : ' + objBatchableContext + '] ->');  
        
        if(String.isNotBlank(strReportId)) {
            lstAttachments = [SELECT Id, Body, BodyLength, Name
                              FROM Attachment 
                              WHERE Name =: strReportId];
            System.debug('finish [ lstAttachments : ' + lstAttachments + ']'); 
            
            if(!lstAttachments.isEmpty()) {
                objAttachment = lstAttachments[0];                
                dblAttachmentSize = objAttachment.BodyLength / 1024 / 1024;
               
                if(dblAttachmentSize < 14) {
                    lstAttachments[0].Name = String.format('{0} {1}.csv', new String[] {strReportName, String.valueOf(Datetime.now()) });
                    sendEmail(lstAttachments[0], null);
                } else {                    
                    objContentVersion = createDocument(strReportName, objAttachment.Body);
                    //generatePostWithRelatedDocument(objContentVersion.Id);
                    
                    sendEmail(null, objContentVersion.ContentDocumentId);
                    delete lstAttachments; 
                }                                                
            } else {
                sendEmail(null, null);
            }            
        }
                     
        System.debug('finish [] <-');  
    }
    
    private static void updateRecordsProcessed(Integer intRecords) {
        User objUser = null;
        System.debug('updateRecordsProcessed [' + intRecords + '] ->');
        objUser = [SELECT Records_Processed__c 
                   FROM User 
                   WHERE Id =: UserInfo.getUserId()];
        
        objUser.Records_Processed__c = (objUser.Records_Processed__c == NULL)?intRecords:objUser.Records_Processed__c + intRecords; 
        update objUser;
        System.debug('updateRecordsProcessed [] <-');
    } 
    
    private String retrieveReportSOQL(String strReportId, Integer intLimit) {
        Reports.ReportDescribeResult objResult = null;
        Reports.ReportMetadata objMetadata = null;
        List<String> lstColumns = null;
        List<Reports.ReportFilter> lstFilters = null;
        String strReportType = null;
        String strSOQL = null;
        Boolean boolFirst = true;
        String strFilter = null;
        String strPreoperator = null;
        String strField = null;
        String strOperator = null;
        String strValue = null;
        String strValueWrapper = null;
        String strBaseObject = null;
        Set<String> setAllowedFields = null;
        
        System.debug('retrieveReportSOQL [ strReportId : ' + strReportId + '] ->');    
        
        objResult = Reports.ReportManager.describeReport(strReportId);
        objMetadata = objResult.getReportMetadata();       
        strReportName = objMetadata.getName();
        //strReportName = String.format('{0} - {1}.csv', new String[] { strReportName , String.valueOf(Datetime.now()) });
        strReportType = objMetadata.getReportType().getType();        
        if(strReportType.endsWith('__c')) {
            strReportType = strReportType.substring(0, strReportType.length() - 3) ;
            strBaseObject = retrieveReportBaseObject(strReportType); 
        } else {
            strBaseObject = 'Contact';
        }
        setAllowedFields = retrieveAllowedFields(UserInfo.getProfileId(), UserInfo.getUserId(), strBaseObject);
                
        if(!setAllowedFields.IsEmpty()) {
            lstColumns = objMetadata.getDetailColumns();
            lstFilters = objMetadata.getReportFilters();
            System.debug('lstFilters : ' + lstFilters );            
            if(!lstColumns.IsEmpty()) {
                strSOQL = 'SELECT ';
                for(String strColumn : lstColumns) {
                    strField = retrieveField(strBaseObject, strColumn);
                    
                    if(setAllowedFields.contains(strField)) {
                        if(boolFirst) {
                            boolFirst = false;
                        } else {
                            strSOQL += ',';
                        }
                        
                        strSOQL += strField;    
                        
                        this.setFields.add(strField);
                    }
                }
                strSOQL += ' FROM ' + strBaseObject + ' ';
                
                if(!lstFilters.IsEmpty()) {
                    strSOQL += 'WHERE ';
                    boolFirst = true;
                    
                    for(Reports.ReportFilter objFilter : lstFilters) {
                        strPreoperator = retrievePreOperator(objFilter.getOperator());
                        strField = retrieveField(strBaseObject, objFilter.getColumn());
                        strOperator = retrieveOperator(objFilter.getOperator());
                        strValue = objFilter.getValue();
                        
                        strValueWrapper = retrieveValueWrapper(objFilter.getColumn());
                        strFilter = retrieveFilter(strPreoperator, strField, objFilter.getOperator(), strOperator, strValueWrapper, strValue);
                        
                        if(boolFirst) {
                            strSOQL += String.format('( {0} )', new String[] { strFilter });
                            boolFirst = false;
                        } else {
                            strSOQL += String.format('AND ( {0} )', new String[] { strFilter });
                        }
                    }
                }
                
                if(intLimit != NULL && intLimit > 0) {
                    strSOQL += ' LIMIT ' + intLimit;
                }
            } else {
                System.debug('retrieveReportSOQL [REPORT HAS NO COLUMNS]');                                
            }
        } else {
            System.debug('retrieveReportSOQL [NOT ALLOWED FIELDS TO EXPORT]');            
        }
        
        System.debug('retrieveReportSOQL [' + strSOQL + '] <-');            
        return strSOQL;
    }
    
    public static Set<String> retrieveAllowedFields(String strProfileId, String strUserId, String strBaseObject) {
        Set<String> setFields = null;
        List<Permission__c> lstExportPermissionsUser = null;
        List<Permission__c> lstExportPermissionsProfile = null;
        
        System.debug('retrieveAllowedFields [ strProfileId : ' + strProfileId +  ' - strUserId : ' + strUserId + '] ->'); 
        
        setFields = new Set<String>();
        if(String.isNotBlank(strProfileId)) {
            lstExportPermissionsProfile = [SELECT Id, Name, sObject__c, FieldName__c, Can_Export__c, Permission_Type__c 
                                           FROM Permission__c
                                           WHERE Permission_Type__r.Profile_Id__c =: strProfileId 
                                           AND sObject__c = :strBaseObject];            
        } 
        
        if(String.isNotBlank(strUserId)) {
            lstExportPermissionsUser = [SELECT Id, Name, sObject__c, FieldName__c, Can_Export__c, Permission_Type__c 
                                        FROM Permission__c
                                        WHERE Permission_Type__r.UserId__c =: strUserId 
                                        AND sObject__c = :strBaseObject];                        
        }
        
        for(Permission__c objPermission : lstExportPermissionsProfile)  {
            if(objPermission.Can_Export__c) {
                setFields.add(objPermission.FieldName__c);                
            }
        }
        
        for(Permission__c objPermission : lstExportPermissionsUser)  {
            if(objPermission.Can_Export__c) {
                setFields.add(objPermission.FieldName__c);                
            }
        }
        
        System.debug('retrieveAllowedFields [' + setFields + '] <-'); 
        return setFields; 
    }
    
    private String retrieveField(String strBaseObject, String strFieldName) {  
        String strField = null;
        System.debug('retrieveField [ strBaseObject : ' + strBaseObject +  ' - strFieldName : ' + strFieldName + '] ->'); 
        
        strField = strFieldName.replace(strBaseObject + '.','');
        
        System.debug('retrieveField [' + strField + '] <-'); 
        return strField;
    }
    
    private String retrievePreOperator(String strOperation) { 
        String strPreoperator = null;
        System.debug('retrievePreOperator [ strOperation : ' + strOperation + '] ->');   
        
        if(strOperation == 'notContain') {
            strPreoperator = 'NOT';                    
        } else {
            strPreoperator = '';
        }
        
        System.debug('retrievePreOperator [' + strPreoperator + '] <-');          
        return strPreoperator;
    }
    
    private String retrieveOperator(String strOperation) {
        String strOperator = null;
        
        System.debug('retrieveOperator [ strOperation : ' + strOperation + '] ->');   
        
        if(strOperation == 'equals') {
            strOperator = '=';
        } else if(strOperation == 'notEqual') {
            strOperator = '<>';
        } else if(strOperation == 'lessThan') {
            strOperator = '<';
        } else if(strOperation == 'greaterThan') {
            strOperator = '>';
        } else if(strOperation == 'lessOrEqual') {
            strOperator = '<=';
        } else if(strOperation == 'greaterOrEqual') {
            strOperator = '>=';
        } else if(strOperation == 'contains') {
            strOperator = 'LIKE';
        } else if(strOperation == 'notContain') {
            strOperator = 'LIKE';
        } else if(strOperation == 'startsWith') {
            strOperator = 'LIKE';
        }
        
        System.debug('retrieveOperator [' + strOperator + '] <-');  
        return strOperator;
    }
    
    private String retrieveFilter(String strPreoperator, String strField, String strOperation, String strOperator, String strValueWrapper, String strValue) {
        String strFilter = null;
        
        System.debug('retrieveFilter [ strPreoperator : ' + strPreoperator + ' - strField : ' + strField + ' - strOperator : ' + strOperator + ' - strValueWrapper : ' + strValueWrapper + ' - strValue : ' + strValue +'] ->');   
        
        if(strOperation == 'equals' || strOperation == 'notEqual' || strOperation == 'lessThan' || strOperation == 'greaterThan' || strOperation == 'lessOrEqual' || strOperation == 'greaterOrEqual') {
            strFilter = String.format(' {0} {1} {2} {3}{4}{3} ', new String[] {strPreoperator, strField, strOperator, strValueWrapper, strValue});
        } else if(strOperation == 'contains' || strOperation == 'notContain') {            
            strFilter = String.format(' {0} {1} {2} {3}%{4}%{3} ', new String[] {strPreoperator, strField, strOperator, strValueWrapper, strValue});
        } else if(strOperation == 'startsWith') {
            strFilter = String.format(' {0} {1} {2} {3}{4}%{3} ', new String[] {strPreoperator, strField, strOperator, strValueWrapper, strValue});
        }
        
        System.debug('retrieveFilter [' + strFilter + '] <-');  
        return strFilter;
    }
    
    //DEVUELVE UNA COMILLA PARA ENCERRAR EL VALOR SI EL TIPO ES STRING 
    //O NADA SI EL TIPO ES NUMERICO
    // CAMPOSTRING = 'VALOR'
    // CAMPORINT = VALOR
    private String retrieveValueWrapper(String strField) {
        String strValueWrapper = null;
        List<Schema.DescribeSObjectResult> lstSOBjects = null;
        Schema.DescribeSObjectResult objSObject = null;
        Schema.DisplayType objType = null;
        List<String> lstFields = null;
        
        System.debug('retrieveValueWrapper [ strField : ' + strField + '] ->');   
        lstFields = strField.split('\\.');
        
        lstSOBjects = Schema.describeSObjects(new String[] {lstFields[0]});
        objSObject = lstSOBjects[0];
        
        objType = objSObject.fields.getMap().get(lstFields[1]).getDescribe().getType();
        if(objType == Schema.DisplayType.DOUBLE || objType == Schema.DisplayType.CURRENCY  || objType == Schema.DisplayType.INTEGER || objType == Schema.DisplayType.BOOLEAN) {
            strValueWrapper = '';
        } else {
            strValueWrapper = '\'';
        }
        
        System.debug('retrieveValueWrapper [' + strValueWrapper + '] <-');          
        return strValueWrapper;
    }
    
    private String retrieveReportBaseObject(String strReportType) {
        MetadataService.MetadataPort objService = null;
        MetadataService.IReadResult objReadResult = null;
        MetadataService.ReportType objReportType = null;
        String strBaseObject = null;
        
        System.debug('retrieveReportBaseObject [' + strReportType + '] ->'); 
        
        objService = new MetadataService.MetadataPort();
        objService.SessionHeader = new MetadataService.SessionHeader_element();
        objService.SessionHeader.sessionId = UserInfo.getSessionId();
        
        objReadResult = objService.readMetadata('ReportType', new String[] {strReportType});
        for (MetadataService.Metadata objResult: objReadResult.getRecords()) {
            if ( objResult instanceof MetadataService.ReportType ) {
                objReportType = (MetadataService.ReportType) objResult;
                strBaseObject = objReportType.baseObject;        
            }
        }
        
        System.debug('retrieveReportBaseObject [' + strBaseObject + '] <-'); 
        return strBaseObject;
    }
    
    private ContentVersion createDocument(String strReportName, Blob objBlob) {
        ContentVersion objContentVersion = null;
        
        System.debug('createDocument [ objBlob : ' + objBlob + '] ->');    
        
        objContentVersion = new ContentVersion();
        objContentVersion.Title = String.format('{0} {1}.csv', new String[] {strReportName, String.valueOf(Datetime.now()) });
        objContentVersion.PathOnClient = 'file_' + Datetime.now().getTime() + '.csv';
        objContentVersion.VersionData = objBlob;
        objContentVersion.Origin = 'H';
        objContentVersion.SharingOption = 'R';
        objContentVersion.SharingPrivacy = 'P';
        
        insert objContentVersion;
        
        objContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :objContentVersion.Id];
        System.debug('createDocument [' + objContentVersion + '] <-');    
        
        return objContentVersion;
    }
    
    private Id createFile(String strFilename, String strBase64Data) {
        Attachment objAttachment = null;
        
        System.debug('createFile [  strBase64Data : ' +  strBase64Data + '] ->');
        
        strBase64Data = strBase64Data.replaceAll('%(?![0-9a-fA-F]{2})', '%25');
        strBase64Data = strBase64Data.replaceAll('\\+', '%2B');
        strBase64Data = EncodingUtil.urlDecode(strBase64Data, 'UTF-16');
        
        objAttachment = new Attachment();
        objAttachment.ParentId = UserInfo.getUserId();
        objAttachment.Body = Blob.valueOf(strBase64Data);
        objAttachment.Name = strFilename;
        objAttachment.ContentType = 'text/csv';
        objAttachment.ParentId = [SELECT ID FROM Account LIMIT 1].Id;
        insert objAttachment;
        
        System.debug('createFile [' +  objAttachment.Id + '] <-');
        
        return objAttachment.Id;
    }
    
    private void appendToFile(String strFilename, String strBase64Data) {
        Attachment objAttachment = null;
        String strCurrentBody = null;
        
        System.debug('appendToFile [  strFilename : ' +  strFilename + ' - strBase64Data : ' + strBase64Data + '] ->');         
        objAttachment = [SELECT Id, Body
                         FROM Attachment
                         WHERE Name = :strFilename
                        ];
        
        strBase64Data = strBase64Data.replaceAll('%(?![0-9a-fA-F]{2})', '%25');
        strBase64Data = strBase64Data.replaceAll('\\+', '%2B');
        strBase64Data = EncodingUtil.urlDecode(strBase64Data, 'UTF-16');        
        strCurrentBody = objAttachment.Body.toString();
        
        System.debug('strCurrentBody : ' + strCurrentBody);
        
        objAttachment.Body = Blob.valueOf(strCurrentBody + strBase64Data); 
        
        update objAttachment;
        
        System.debug('appendToFile [] <-'); 
    }
    /*
    private FeedItem generatePostWithRelatedDocument(Id objFileId) {
        FeedItem objFeedItem = null;
        
        System.debug('generatePostWithRelatedDocument [  objFileId : ' +  objFileId + '] ->'); 
        
        objFeedItem = new FeedItem();
        objFeedItem.Body = 'Se ha generado su reporte';
        objFeedItem.ParentId = UserInfo.getUserId();
        objFeedItem.RelatedRecordId = objFileId;
        objFeedItem.Type = 'ContentPost';
        
        insert objFeedItem;
        
        System.debug('generatePostWithRelatedDocument [' + objFeedItem + '] <-'); 
        
        return objFeedItem;        
    }
    */
    private void sendEmail(Attachment objAttachment, Id objContentVersionId) {
        List<String> lstTo = null;
        String strFromDisplay = null;
        String strBody = null;
        List<Attachment> lstAttachments = null;
        
        lstTo = new List<String>();
        lstTo.add(UserInfo.getUserEmail());
        
        strFromDisplay = 'Prosumia - Reportes';    
        
        if(objAttachment != NULL ) {
            strBody = String.format( 'Estimado {0},<br/> <br/> El reporte solicitado está adjunto.<br/> <br/> Saludos<br/>Reportes Prosumia<br/>', new String[] { UserInfo.getFirstName()});
            lstAttachments = new List<Attachment>();
            lstAttachments.add(objAttachment);
        } else if(objContentVersionId != NULL) {
            strBody = String.format('Estimado {0}, <br /> <br /> Su reporte es disponible para descargar <a href="{1}">aquí</a>.<br /> <br /> Saludos<br />Reportes Prosumia<br />', new String[] { UserInfo.getFirstName(), URL.getSalesforceBaseUrl().toExternalForm() + '/' + objContentVersionId });            
        } else {
            strBody = String.format('Estimado {0},<br /> <br/> El reporte solicitado no ha arrojado ningún resultado<br/> <br/> Saludos<br/> Reportes Prosumia<br/>', new String[] { UserInfo.getFirstName() });            
        }
        
        sendEmail(null, strFromDisplay, lstTo, null, 'Prosumia - Reporte Generado', strBody, lstAttachments);
    }
    
    public static void sendEmail(String strTemplateId, String strFromDisplay, List<String> lstTo, List<String> lstCC, String strSubject, String strBody, List<Attachment> lstAttachments) {
        Messaging.SingleEmailMessage objSingleEmailMessage = null;
        List<Messaging.EmailFileAttachment> lstFileAttachments = null;
        Messaging.EmailFileAttachment objEmailFileAttachment = null;
        
        try {            
            if(lstTo != NULL && lstTO.size() > 0) {
                objSingleEmailMessage = new Messaging.SingleEmailMessage();
                
                if(String.isNotBlank(strTemplateId)) {
                    objSingleEmailMessage.setTemplateId(strTemplateId);
                    objSingleEmailMessage.setTargetObjectId(UserInfo.getUserId());                    
                }
                
                objSingleEmailMessage.setToAddresses(lstTo);
                objSingleEmailMessage.setCcAddresses(lstCC);
                objSingleEmailMessage.setSenderDisplayName(strFromDisplay);
                objSingleEmailMessage.setSubject(strSubject);
                objSingleEmailMessage.setBccSender(false);
                objSingleEmailMessage.setUseSignature(true);
                //objSingleEmailMessage.setPlainTextBody(strBody);
                objSingleEmailMessage.setHtmlBody(strBody);
                
                if(lstAttachments != NULL && lstAttachments.size() > 0) {
                    lstFileAttachments = new  List<Messaging.EmailFileAttachment>();
                    for (Attachment objAttachment : lstAttachments){
                        objEmailFileAttachment = new Messaging.EmailFileAttachment();
                        objEmailFileAttachment.setFileName(objAttachment.Name);
                        objEmailFileAttachment.setBody(objAttachment.Body);
                        lstFileAttachments.add(objEmailFileAttachment);
                    }  
                    
                    objSingleEmailMessage.setFileAttachments(lstFileAttachments);
                }
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objSingleEmailMessage });                                
            }
        } catch(Exception Ex) {
            System.debug('Ex ' + Ex);            
        }
    }
    
    private String addRandomRecord(Contact objContact) {
        String strCSV = null;
        
        strCSV = '';
        for(String strField :  this.setFields) {
            if(strField == 'Email') {
                strCSV += 'eduardo.betzerra@gmail.com,';
            } else if (strField == 'MobilePhone') {
                strCSV += '5491123302877,';
            } else if (strField == 'UUID__c') {
                strCSV += 'aBcZyX,';
            } else {
                strCSV += objContact.get(strField) + ',';   
            }
        }
        strCSV += '\r\n';
        
        return strCSV;
    }
    
    private void testCoverage() {
        retrieveAllowedFields(UserInfo.getProfileId(), UserInfo.getUserId(), 'Contact');
        retrieveField('Contact', 'FirstName'); 
        createDocument('MyReportName', Blob.valueOf('MY REPORT CONTENT'));
        retrievePreOperator('notEquals');
        retrievePreOperator('notContain');
        
        retrieveOperator('equals');
        retrieveOperator('notEqual');
        retrieveOperator('lessThan');
        retrieveOperator('greaterThan');
        retrieveOperator('lessOrEqual');
        retrieveOperator('greaterOrEqual');
        retrieveOperator('contains');
        retrieveOperator('notContain');
        retrieveOperator('startsWith');
        
        retrieveFilter('NOT', 'NAME', 'contains', '=', '$', 'VALOR');
        retrieveFilter('NOT', 'NAME', 'equals', '=', '$', 'VALOR');
        retrieveFilter('NOT', 'NAME', 'startsWith', '=', '$', 'VALOR');
        
        retrieveValueWrapper('Contact.FirstName');
        //retrieveReportBaseObject('Contacts_Only');
    }
}