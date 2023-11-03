public class HelperFunctions {
    public enum CommunitySite { SALESFORCE, PROSUMIA, CUIDARNOS, ADFI, HURLINGHAM, UCR, PUNTOCASH, MENTA, KITURBANO, HACEMOSPORCORDOBA }  
    
    public static CommunitySite retrieveSite() {
        List<Network> lstNetwork = NULL;
        CommunitySite objCommunitySite = null;
        
        lstNetwork = [SELECT NAME 
                      FROM NETWORK 
                      WHERE ID =: Network.getNetworkId()];
        
        if(lstNetwork.isEmpty()) {
            objCommunitySite = CommunitySite.SALESFORCE; 
        } else {
            if(lstNetwork[0].Name.toUpperCase() == 'PROSUMIA') {
                objCommunitySite = CommunitySite.PROSUMIA;
            } else if(lstNetwork[0].Name.toUpperCase() == 'ADFI') {
                objCommunitySite = CommunitySite.ADFI;
            } else if(lstNetwork[0].Name.toUpperCase() == 'HURLINGHAM' || lstNetwork[0].Name.toUpperCase() == 'MUNICIPIO') {
                objCommunitySite = CommunitySite.HURLINGHAM;
            } else if(lstNetwork[0].Name.toUpperCase() == 'UCR') {
                objCommunitySite = CommunitySite.UCR;
            } else if(lstNetwork[0].Name.toUpperCase() == 'PUNTOCASH') {
                objCommunitySite = CommunitySite.PUNTOCASH;
            } else if(lstNetwork[0].Name.toUpperCase() == 'MENTA') {
                objCommunitySite = CommunitySite.MENTA;
            } else if(lstNetwork[0].Name.toUpperCase() == 'KITURBANO') {
                objCommunitySite = CommunitySite.KITURBANO;
            } else if(lstNetwork[0].Name.toUpperCase() == 'HACEMOSPORCORDOBA') {  
                objCommunitySite = CommunitySite.HACEMOSPORCORDOBA;
            } else if(lstNetwork[0].Name.toUpperCase() == 'CUIDARNOS') {  
                objCommunitySite = CommunitySite.CUIDARNOS;
            } 
        }

        return objCommunitySite;
    }
    
    public static void sendEmail(String strTO, String strSubject, String strBody) {
        List<String> lstTO = null;
        
        lstTO = new List<String>();
        lstTO.add(strTO);
        
        sendEmail(lstTO, null, strSubject, strBody, null, null, null);
    }   
    
    public static void sendEmail(String strTO, String strSubject, String strBody, String strAttachmentName, String strAttachmentContentType, Blob objAttachment) {
        List<String> lstTO = null;
        
        System.debug('HelperFunctions.sendEmail: ' + strAttachmentName);
        
        lstTO = new List<String>();
        lstTO.add(strTO);
        
        sendEmail(lstTO, null, strSubject, strBody, strAttachmentName, strAttachmentContentType, objAttachment);
    }    
    
    public static void sendEmail(List<String> lstTO, List<String> lstCC, String strSubject, String strBody, String strAttachmentName, String strAttachmentContentType, Blob objAttachment) {
        Messaging.SingleEmailMessage objEmailMessage = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment objEmailFileAttachment = null;
        
        System.debug('Entering sendMail.....');
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'salesforce@prosumia.la'];
        if (owea.size() > 0) {
            objEmailMessage.setOrgWideEmailAddressId(owea.get(0).Id);
        }        

        if(lstTO != NULL && !lstTO.isEmpty()) {
            objEmailMessage.setToAddresses(lstTO);
        }
        
        if(lstCC != NULL && !lstCC.isEmpty()) {
            objEmailMessage.setCcAddresses(lstCC);
        }
        
        if(String.isNotBlank(strSubject)) {
            objEmailMessage.setSubject(strSubject);            
        }
        
        if(String.isNotBlank(strBody)) {
            objEmailMessage.setHtmlBody(strBody);            
        }
        
        if(objAttachment != null && String.isNotBlank(strAttachmentName)) {
            Messaging.EmailFileAttachment[] arrEmailFileAttachments = new Messaging.EmailFileAttachment[]{};
            objEmailFileAttachment = new Messaging.EmailFileAttachment();
            objEmailFileAttachment.setFileName(strAttachmentName);
            objEmailFileAttachment.setBody(objAttachment);
            
            System.debug('HelperFunction.sendEmail (with attachment):' + strAttachmentName);
            
            if(String.isNotBlank(strAttachmentContentType)) {
                objEmailFileAttachment.setContentType(strAttachmentContentType);
            }
            arrEmailFileAttachments.add(objEmailFileAttachment);
            objEmailMessage.setFileAttachments(arrEmailFileAttachments);
        }
        
        try {
            System.debug('HelperFunction.sendEmail (with attachment):' + objEmailMessage);
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { objEmailMessage });
        } catch(Exception Ex){
            System.debug('Ex : ' + Ex.getMessage());
        }         
    }


    public static void sendEmail(String strTO, String strSubject, String strBody, List<Attachment> objAttachmentArr, String strAttachmentContentType) {
        List<String> lstTO = null;
        
        lstTO = new List<String>();
        lstTO.add(strTO);
        
        sendEmail(lstTO, null, strSubject, strBody, objAttachmentArr, strAttachmentContentType);
    }    
    
    
    public static void sendEmail(List<String> lstTO, List<String> lstCC, String strSubject, String strBody, List<Attachment> objAttachmentArr, String strAttachmentContentType) {
        Messaging.SingleEmailMessage objEmailMessage = new Messaging.SingleEmailMessage();
        
        System.debug('Entering sendMail.....');
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'salesforce@prosumia.la'];
        if (owea.size() > 0) {
            objEmailMessage.setOrgWideEmailAddressId(owea.get(0).Id);
        }        

        if(lstTO != NULL && !lstTO.isEmpty()) {
            objEmailMessage.setToAddresses(lstTO);
        }
        
        if(lstCC != NULL && !lstCC.isEmpty()) {
            objEmailMessage.setCcAddresses(lstCC);
        }
        
        if(String.isNotBlank(strSubject)) {
            objEmailMessage.setSubject(strSubject);            
        }
        
        if(String.isNotBlank(strBody)) {
            objEmailMessage.setHtmlBody(strBody);            
        }
        
        if(!objAttachmentArr.isEmpty()) {
	        Messaging.EmailFileAttachment objEmailFileAttachment = null;
            Messaging.EmailFileAttachment[] arrEmailFileAttachments = new Messaging.EmailFileAttachment[]{};
            for (Attachment obj : objAttachmentArr) {
                objEmailFileAttachment = new Messaging.EmailFileAttachment();
                objEmailFileAttachment.setFileName(obj.Name);
                objEmailFileAttachment.setBody(obj.Body);
	            arrEmailFileAttachments.add(objEmailFileAttachment);
	            System.debug('HelperFunction.sendEmail (with attachment):' + obj.Name);
            }
            
            if(String.isNotBlank(strAttachmentContentType)) {
                objEmailFileAttachment.setContentType(strAttachmentContentType);
            }

            objEmailMessage.setFileAttachments(arrEmailFileAttachments);
        }
        
        try {
            System.debug('HelperFunction.sendEmail (with attachment):' + objEmailMessage);
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { objEmailMessage });
        } catch(Exception Ex){
            System.debug('Ex : ' + Ex.getMessage());
        }         
    }

    
    
    public Static Set<String> capitalizeList(Set<String> setFieldList) {
        Set<String> setResult = null;
        String[] arrFields = null;
        String strWordResult = null;
        Boolean boolFirst = true;
        
        setResult = new Set<String>();
        for(String strField : setFieldList){	
            arrFields = strField.split(' ');
            strWordResult = '';
            for(String strWord : arrFields) {
                if(boolFirst) {
                    boolFirst = false;
                } else {
                    strWordResult += ' ';
                }
                strWordResult += strWord.toLowerCase().capitalize();
            }
            setResult.add(strWordResult);
        }
        return setResult;
    }
    
    
    public Static List<String> capitalizeList(List<String> setFieldList) {
        List<String> setResult = null;
        String[] arrFields = null;
        String strWordResult = null;
        Boolean boolFirst = true;
        
        setResult = new List<String>();
        for(String strField : setFieldList){	
            arrFields = strField.split(' ');
            strWordResult = '';
            for(String strWord : arrFields) {
                if(boolFirst) {
                    boolFirst = false;
                } else {
                    strWordResult += ' ';
                }
                strWordResult += strWord.toLowerCase().capitalize();
            }
            setResult.add(strWordResult);
        }
        return setResult;
    }
    
    public Static Set<String> trimList(Set<String> setFieldList) {
        Set<String> setResult = null;
        
        setResult = new Set<String>();
        for(String strField : setFieldList){	            
            setResult.add(strField.trim());
        }
        return setResult;
    }
    
    public static Date convertStringToDate(String strDate, String strFormat, String strSeparator) {
        Date datDate = null;
        String[] arrDate = null;
        try {
            arrDate = strDate.split(strSeparator);
            if(strFormat == 'MMDDYYYY') {
                datDate = Date.newInstance(Integer.valueOf(arrDate[2]), Integer.valueOf(arrDate[0]), Integer.valueOf(arrDate[1]));
            }            
        } catch (Exception Ex) {
            System.debug('Ex : ' + Ex);
        }
        return datDate;
    }    

    public static String convertDateToString(Date datDate) {
        String strDate = null;
        List<String> lstMonth = null;
        
        if(datDate != NULL) {
            lstMonth = new String[] {'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'};
              
			strDate = String.format('{0} de {1} de {2}', new Object[] { String.valueOf(datDate.day()).leftPad(2,'0'),  lstMonth[datDate.month() - 1], datDate.year() });
        }
        
        return strDate;
    }    
    
    public static String formatCUIT(String strCUIT) {
        List<String> lstCUITParts = null;
        String strCUITFormatted = null;
        
        lstCUITParts = new List<String>();
        if(String.isNotBlank(strCUIT) && strCUIT.length() >= 8) {
            lstCUITParts.add(strCUIT.substring(0,2));
            lstCUITParts.add(strCUIT.substring(2, strCUIT.length() - 1));
            lstCUITParts.add(strCUIT.substring(strCUIT.length() - 1, strCUIT.length()));        
            
            strCUITFormatted = String.join(lstCUITParts, '-');
        }
                             
        return strCUITFormatted;
    }
    
    public static String formatNumberString(String strNumber){
        String strFormattedNumber = null;
        Integer intNumber = null;

        System.debug('formatNumberString [strNumber : '  + strNumber + '] ->');

        if(String.isNotBlank(strNumber) && strNumber.isNumeric()) {
            intNumber = Integer.valueOf(strNumber);
            strFormattedNumber = String.valueOf(intNumber);
            
            if(intNumber / 1000000 >= 1) {
                strFormattedNumber = strFormattedNumber.substring(0, strNumber.length() - 6) + '.' + strFormattedNumber.substring(strFormattedNumber.length() - 6, strFormattedNumber.length() - 3) + '.' + strFormattedNumber.substring(strFormattedNumber.length() - 3, strFormattedNumber.length());
            } else if(intNumber / 1000 >= 1){
                strFormattedNumber = strFormattedNumber.substring(0, strNumber.length() - 3) + '.' + strFormattedNumber.substring(strFormattedNumber.length() - 3, strFormattedNumber.length());
            }
        } else {
            System.debug('formatNumberString [Yo no soy numerico : '  + strNumber + ']');
        }
        
        System.debug('formatNumberString ['  + strFormattedNumber + '] <>');

        return strFormattedNumber;
    }
    
    public static String formatNumber(Decimal dblNumber){
        String strFormattedNumber = null;
        String strNumber = null;
        Integer intNumber = NULL;
    
        if(dblNumber != null) {
            intNumber = dblNumber.intValue();
            strFormattedNumber = String.valueOf(intNumber);
            strNumber = strFormattedNumber;
            
            if(intNumber / 1000000 >= 1) {
                strFormattedNumber = strFormattedNumber.substring(0, strNumber.length() - 6) + '.' + strFormattedNumber.substring(strFormattedNumber.length() - 6, strFormattedNumber.length() - 3) + '.' + strFormattedNumber.substring(strFormattedNumber.length() - 3, strFormattedNumber.length());
            } else if(intNumber / 1000 >= 1){
                strFormattedNumber = strFormattedNumber.substring(0, strNumber.length() - 3) + '.' + strFormattedNumber.substring(strFormattedNumber.length() - 3, strFormattedNumber.length());
            }
        } else {
            strFormattedNumber = '0';
        }
        
        return strFormattedNumber;
    }
    
    public static String retrieveStaticResourceBaseUrl(String strResource) {
        List<StaticResource> lstResources = null;
        String strResourceUrl = null;
        Id strSiteId = null;
        
        if(String.isNotBlank(strResource)) {
            lstResources = [ SELECT ID, LastModifiedDate 
                            FROM StaticResource 
                            WHERE Name = :strResource];
            
            if(!lstResources.isEmpty()) {
                strSiteId = Site.getSiteId(); 
                if(String.isNotBlank(strSiteId)) {
                    strResourceUrl = String.format('/prosumia/resource/{0}/{1}', new Object[] { Math.abs(Integer.valueOf(lstResources[0].LastModifiedDate.getTime())), strResource});	
                } else {
                    strResourceUrl = String.format('/resource/{0}/{1}', new Object[] { Math.abs(Integer.valueOf(lstResources[0].LastModifiedDate.getTime())), strResource});	
                }
            }
        }
		
        return strResourceUrl;
    }    
    
    public static String getThousandSeparatedByDot(Integer intNumber){
        String strNumber = null;
        
        strNumber = String.valueOf(intNumber);
        
        if(intNumber / 1000000 >= 1) {
            strNumber = strNumber.substring(0, strNumber.length() - 6) + '.' + strNumber.substring(strNumber.length() - 6, strNumber.length() - 3) + '.' + strNumber.substring(strNumber.length() - 3, strNumber.length());
        } else if(intNumber / 1000 >= 1){
            strNumber = strNumber.substring(0, strNumber.length() - 3) + '.' + strNumber.substring(strNumber.length() - 3, strNumber.length());
        }
        
        return strNumber;
    }
    
    public static String removeAccents(String strBaseString) {        
        List<String> lstVowelsWithAccents = new List<String> {'á','é','í','ó','ú','Á','É','Í','Ó','Ú'};
        List<String> lstVowelsWithoutAccents = new List<String> {'a','e','i','o','u','A','E','I','O','U'};            
		String strResult = strBaseString;
        
        for (Integer intIndex = 0; intIndex < lstVowelsWithAccents.size(); intIndex++) {
            strResult = strResult.replace(lstVowelsWithAccents[intIndex], lstVowelsWithoutAccents[intIndex]);
        }
        
        return strResult;
    }     
        
    public static Survey_Setting__mdt retrieveSurveySettings(String strSurveyName) {
        List<Survey_Setting__mdt> lstSurveySettings = null;
        Survey_Setting__mdt objSurveySettings = null;
        
        System.debug('retrieveSurveySettings [ strSurveyName : ' + strSurveyName + ' ] ->');
         
        if(String.isNotBlank(strSurveyName)) { 
            lstSurveySettings = [SELECT Id, DeveloperName, Facebook_Application_Id__c, Facebook_API_Version__c, Facebook_Url__c, Facebook_Pixel_Id__c,Facebook_Graph_Url__c,Facebook_Graph_Client_Id__c,Facebook_Graph_Client_Secret__c, Twitter_Url__c, TypeForm_Url__c, Instagram_Url__c, Survey_Domain__c, UrlRewriterPath__c, UrlRewriterVF__c, Crypto_Message_Public_Key__c, Crypto_Message_Secret_Key__c 
                                 FROM Survey_Setting__mdt
                                 WHERE DeveloperName =: strSurveyName];
            
            if(!lstSurveySettings.isEmpty()) {
                objSurveySettings = lstSurveySettings[0]; 
            }
        }
        
        System.debug('retrieveSurveySettings [' + objSurveySettings + '] <-');        
        
        return objSurveySettings;
    }
    
    public static Community_Config__mdt retrieveCommunitySettings() {
        Community_Config__mdt objSetting = null;
        List<Community_Config__mdt> lstSettings = null;
        String strSite = null;        
        
        System.debug('retrieveCommunitySettings [] ->');

        strSite = 'Prosumia';
        
        if(!Test.isRunningTest()) {
            if(Network.getNetworkId() != NULL && Network.getNetworkId() != UserInfo.getOrganizationId()) {
                strSite = [SELECT Id, Name 
                           FROM Network 
                           WHERE Id =: Network.getNetworkId()].Name;
            }
        }
        
        System.debug('retrieveCommunitySettings [ strSite : ' + strSite + ']');
        
        lstSettings = [SELECT Id, DeveloperName, LEX_Domain__c, VF_Domain__c,
                                Citizen_Edit_Layout__c, RootTerritory__c, Root_Admin_Level__c, 
                                Label, Login_Tab_Title__c, Static_Resourse_Name_FavIcon__c,
                                Static_Resourse_Name_ZipBundle__c, Login_Footer_Title__c
                       FROM Community_Config__mdt 
                       WHERE Label = : strSite];
        
        System.debug('retrieveCommunitySettings [ lstSettings : ' + lstSettings + ']');
        
        if(!lstSettings.isEmpty()) {
            objSetting = lstSettings[0];
        }
        
        System.debug('retrieveCommunitySettings [' + objSetting + '] <-');
        return  objSetting;        
    }
    
    public static void handleRuntimeException(Exception Ex) {
        System.debug('Ex: [MESSAGE]' + Ex.getMessage());
        System.debug('Ex: [STACKTRACE]' + Ex.getStackTraceString()); 
    }
    
    public static String getValuesFromMultiPickList (List<String> lstSelectedOptions) {
        String strResult = NULL;
        
        strResult = '';
        if(lstSelectedOptions != NULL && !lstSelectedOptions.isEmpty()) {
            strResult = String.join(lstSelectedOptions,';');
        }
        return strResult;
    }
    
    public static String getValuesFromMultiPickList (String strSObject, String strField, List<String> lstSelectedOptions) {
        String strResult = NULL;
        List<String> lstTranslatedOptions = null;
        
        strResult = '';
        if(lstSelectedOptions != NULL && !lstSelectedOptions.isEmpty()) {
            lstTranslatedOptions = new List<String>();
            for(String strOption : lstSelectedOptions) {                
                strResult = retrievePicklistValue(strSObject,strField, strOption);
                lstTranslatedOptions.add(strResult);
            } 
            strResult = String.join(lstTranslatedOptions,';');
        }
        return strResult;
    }
        
    public static Boolean hasSObjectField(String strFieldName, String strSObjectName){
        Schema.SObjectType objObjectType = null;        
        Schema.DescribeSObjectResult objSObjectResult = null;
        Boolean boolHasField = false;
        
        objObjectType = Schema.getGlobalDescribe().get(strSObjectName);        
        objSObjectResult = objObjectType.getDescribe();
        boolHasField = objSObjectResult.fields.getMap().keySet().contains(strFieldName.toLowerCase());
        
        return boolHasField;
    }
    
    public static String getFieldLabel(String strFieldName, String strSObjectName){
        Schema.SObjectType objObjectType = null;        
        Schema.DescribeSObjectResult objSObjectResult = null;
        Schema.DescribeFieldResult objFieldResult = null;
        
        objObjectType = Schema.getGlobalDescribe().get(strSObjectName);        
        objSObjectResult = objObjectType.getDescribe();
        objFieldResult = objSObjectResult.fields.getMap().get(strFieldName).getDescribe();
        
        return String.valueOf(objFieldResult.getLabel());
    }
    
    public static String getFieldType(String strFieldName, String strSObjectName){
        Schema.SObjectType objObjectType = null;        
        Schema.DescribeSObjectResult objSObjectResult = null;
        Schema.DescribeFieldResult objFieldResult = null;
        
        objObjectType = Schema.getGlobalDescribe().get(strSObjectName);        
        objSObjectResult = objObjectType.getDescribe();
        objFieldResult = objSObjectResult.fields.getMap().get(strFieldName).getDescribe();
        
        return String.valueOf(objFieldResult.getType());
    }
              
    public static String retrievePicklistValue(String strSObject, String strField, String strValue) {
        Schema.sObjectType objType = null; 
        Schema.DescribeSObjectResult objDescribe = null;       
        Map<String, Schema.SObjectField> mapFieldMap = null; 
        List<Schema.PicklistEntry> lstPicklistValues = null;
        String strDeveloperName = null;
        
        System.debug('retrievePicklistValues [ strSObject : ' + strSObject + ' - strField : ' + strField + '] ->');
        
        objType = Schema.getGlobalDescribe().get(strSObject);
        objDescribe = objType.getDescribe();       
        mapFieldMap = objDescribe.fields.getMap(); 
        lstPicklistValues = mapFieldMap.get(strField).getDescribe().getPickListValues();
        
        for(Schema.PicklistEntry objPicklist : lstPicklistValues) {
            if(objPicklist.getLabel() == strValue) {
                strDeveloperName = objPicklist.getValue(); 
            }            
        }
        System.debug('retrievePicklistValues [' + lstPicklistValues + '] <-');
        
        return strDeveloperName;
    }

    public static List<Schema.PicklistEntry> retrievePicklistValues(String strSObject, String strField) {
        Schema.sObjectType objType = null; 
        Schema.DescribeSObjectResult objDescribe = null;       
        Map<String, Schema.SObjectField> mapFieldMap = null; 
        List<Schema.PicklistEntry> lstPicklistValues = null;
        
        System.debug('retrievePicklistValues [ strSObject : ' + strSObject + ' - strField : ' + strField + '] ->');
        
        objType = Schema.getGlobalDescribe().get(strSObject);
        objDescribe = objType.getDescribe();       
        mapFieldMap = objDescribe.fields.getMap(); 
        lstPicklistValues = mapFieldMap.get(strField).getDescribe().getPickListValues();
        
        System.debug('retrievePicklistValues [' + lstPicklistValues + '] <-');
        
        return lstPicklistValues;
    }


    public static List<String> retrievePicklistValuesToStringList(String strSObject, String strField) {
        List<String> lstOptionsValues = new List<String>{};

        System.debug('retrievePicklistValuesToStringList [strSObject : ' + strSObject + ' - strField : ' + strField + '] ->');
        List<Schema.PicklistEntry> lstValues = retrievePicklistValues(strSObject, strField);
        if(!lstValues.isEmpty()) {
            for(Schema.PicklistEntry objOption : lstValues) {
                lstOptionsValues.add(objOption.getValue());
            }
        }
        System.debug('retrievePicklistValuesToStringList [' + lstOptionsValues + '] <-');

        return lstOptionsValues;
    }


    public static List<SelectOption> buildPickListOptions (List<Schema.PicklistEntry> lstPickiListEntries) {
        List<SelectOption> lstOptions = null;
        
        lstOptions = new List<SelectOption>();
        for (Schema.PicklistEntry objPickListEntry : lstPickiListEntries) {
            lstOptions.add(new SelectOption(objPickListEntry.getLabel(), objPickListEntry.getValue()));
        }
        
        return lstOptions;
    }

    public static List<RemotingMessageHelper.CustomSelectOptions> buildPickListCustomOptions (List<Schema.PicklistEntry> lstPickiListEntries) {
        List<RemotingMessageHelper.CustomSelectOptions> lstOptions = null;
        
        lstOptions = new List<RemotingMessageHelper.CustomSelectOptions>();
        for (Schema.PicklistEntry objPickListEntry : lstPickiListEntries) {
            lstOptions.add(new RemotingMessageHelper.CustomSelectOptions(objPickListEntry.getLabel(), objPickListEntry.getValue()));
        }
        
        return lstOptions;
    }

    public static List<MetadataService.SaveResult> addValueToPickList (String strSObject, String strName, Boolean boolIsMultipicklist, String strNewValue) {        
        MetadataService.MetadataPort objService = null;
        MetadataService.CustomField objCustomField = null;
        MetadataService.CustomValue objCustomValue = null;
        MetadataService.ValueSet objValueSet = null;
        MetadataService.ValueSetValuesDefinition objValuesSetDefinition = null;
        List<MetadataService.CustomValue> lstCustomValues = null;
        List<Schema.PicklistEntry> lstPicklistValues = null;
        List<MetadataService.SaveResult> lstResult = null;
                            
        System.debug('addValueToPickList [strSObject : ' + strSObject + ' - strName : ' + strName + ' - boolIsMultipicklist : ' + boolIsMultipicklist + ' - strNewValue : ' + strNewValue + '] ->');
        lstCustomValues = new List<MetadataService.CustomValue>();
        
        objCustomValue = new MetadataService.CustomValue();        
        objCustomValue.fullName = strNewValue;
        objCustomValue.default_x = false;
        objCustomValue.isActive = true;
        lstCustomValues.add(objCustomValue);
        System.debug('addValueToPickList [lstCustomValues : ' + lstCustomValues + ']');

        lstPicklistValues = retrievePicklistValues(strSObject, strName);
        for (Schema.PicklistEntry objPicklistEntry : lstPicklistValues) {
            objCustomValue = new MetadataService.CustomValue();
            objCustomValue.fullName = objPicklistEntry.getValue(); //API name of picklist value
            objCustomValue.default_x = objPicklistEntry.isDefaultValue();
            objCustomValue.isActive = objPicklistEntry.isActive();
            objCustomValue.label = objPicklistEntry.getLabel();
            lstCustomValues.add(objCustomValue);
        }
        System.debug('addValueToPickList [lstCustomValues : ' + lstCustomValues + ']');

        objValuesSetDefinition = new MetadataService.ValueSetValuesDefinition();
        objValuesSetDefinition.value = lstCustomValues;
        objValuesSetDefinition.sorted = false;
        System.debug('addValueToPickList [objValuesSetDefinition : ' + objValuesSetDefinition + ']');

        objValueSet = new MetadataService.ValueSet();
        objValueSet.valueSetDefinition = objValuesSetDefinition;
        
        objCustomField = new MetadataService.CustomField();
        objCustomField.fullName = strSObject + '.' + strName;
        objCustomField.label = getFieldLabel(strName, strSObject);
        objCustomField.type_x = boolIsMultipicklist? 'MultiselectPicklist' : 'Picklist';
        objCustomField.valueSet = objValueSet;
        if(boolIsMultipicklist){
        	objCustomField.visibleLines = 4;   
        }
        System.debug('addValueToPickList [objCustomField : ' + objCustomField + ']');

        objService = new MetadataService.MetadataPort();        
        objService.SessionHeader = new MetadataService.SessionHeader_element();
        objService.SessionHeader.sessionId = UserInfo.getSessionId();
        if(!Test.isRunningTest()) {
            System.debug('addValueToPickList [Before updating metadata]');

            lstResult = objService.updateMetadata(new MetadataService.Metadata[] { objCustomField });
            System.debug('addValueToPickList [result : ' + lstResult + ']');

        }
        
        
        return lstResult;
    }
}