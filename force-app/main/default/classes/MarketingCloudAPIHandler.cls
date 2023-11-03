public class MarketingCloudAPIHandler {
    public class AuthenticationException extends Exception {}
    public class OperationException extends Exception {}
    public class Field {
        public String Name { get; set; }
        public String Description { get; set; }
        public Integer MaxLength { get; set; }
        public Boolean IsNillable { get; set; }
        public Boolean IsPrimaryKey { get; set; }  
        public String FieldType { get; set; }  
        public String DefaultValue { get; set; }  
        
        public String toXML() {
            String strXML = null;
            
            if(this.FieldType.toUpperCase() == 'TEXT') {
                strXML = String.format('<Field><Name>{0}</Name><Description>{1}</Description><MaxLength>{2}</MaxLength><IsNillable>{3}</IsNillable><IsPrimaryKey>{4}</IsPrimaryKey><FieldType>{5}</FieldType><DefaultValue>{6}</DefaultValue></Field>', new String[] { this.Name, this.Description, String.valueOf(this.MaxLength), (this.IsNillable)?'true':'false', (this.IsPrimaryKey)?'true':'false', this.FieldType, this.DefaultValue });                
            } else if(this.FieldType.toUpperCase() == 'NUMBER') {
                strXML = String.format('<Field><Name>{0}</Name><Description>{1}</Description><IsNillable>{2}</IsNillable><IsPrimaryKey>{3}</IsPrimaryKey><FieldType>{4}</FieldType><DefaultValue>{5}</DefaultValue></Field>', new String[] { this.Name, this.Description, (this.IsNillable)?'true':'false', (this.IsPrimaryKey)?'true':'false', this.FieldType, this.DefaultValue });                                
            }
        	
            return strXML;
        }
    }
    
    private static final String SOAP_URL = 'Service.asmx';

    public RemotingMessageHelper.MarketingCloudAccessToken retrieveAccessToken() {
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        Marketing_Cloud_Settings__c objMarketingCloudSettings = null;
        RemotingMessageHelper.MarketingCloudAccessToken objAccessToken = null;
        String strBody = null;
        DateTime datTokenExpires = null;
        
        System.debug('retrieveAccessToken [] ->');
        
        objMarketingCloudSettings = Marketing_Cloud_Settings__c.getInstance(UserInfo.getUserId());
        System.debug('retrieveAccessToken [ objMarketingCloudSettings : ' + objMarketingCloudSettings + ']');
        
        if(objMarketingCloudSettings == NULL || objMarketingCloudSettings.AccessToken__c == NULL || objMarketingCloudSettings.TokenExpires__c < DateTime.now()) {
            strBody = String.format('clientId={0}&clientSecret={1}', new String[] { objMarketingCloudSettings.ClientId__c, objMarketingCloudSettings.ClientSecret__c });
            
            objRequest = new HttpRequest();
            objRequest.setMethod('POST');
            objRequest.setEndpoint('callout:Marketing_Cloud_Auth_API/v1/requestToken');
            objRequest.setHeader('content-type', 'application/x-www-form-urlencoded');
            objRequest.setBody(strBody);
            
            objHttp = new Http();               
            objResponse = objHttp.send(objRequest);
            
            if (objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {            
                objAccessToken = (RemotingMessageHelper.MarketingCloudAccessToken)JSON.deserialize(objResponse.getBody(), RemotingMessageHelper.MarketingCloudAccessToken.class);
                
                datTokenExpires = DateTime.now();
                datTokenExpires = datTokenExpires.addSeconds(objAccessToken.expiresIn);
                objMarketingCloudSettings = retrieveCurrentAccessToken();     
                objMarketingCloudSettings.AccessToken__c = JSON.serialize(objAccessToken);
                objMarketingCloudSettings.TokenExpires__c = datTokenExpires;
            } else {
                throw new AuthenticationException();
            }
        } else {
            objAccessToken = (RemotingMessageHelper.MarketingCloudAccessToken)JSON.deserialize(objMarketingCloudSettings.AccessToken__c, RemotingMessageHelper.MarketingCloudAccessToken.class);
            System.debug('retrieveAccessToken [Saved Access Token : ' + objAccessToken + ' ]');
        }
        System.debug('retrieveAccessToken [' + objAccessToken + '] <-');
        return objAccessToken;
    }
    
    public void updateAccessToken() {
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        Marketing_Cloud_Settings__c objMarketingCloudSettings = null;
        RemotingMessageHelper.MarketingCloudAccessToken objAccessToken = null;
        String strBody = null;
        DateTime datTokenExpires = null;
        
        System.debug('updateAccessToken [] ->');
        
        objMarketingCloudSettings = Marketing_Cloud_Settings__c.getInstance(UserInfo.getUserId());
        System.debug('updateAccessToken [objMarketingCloudSettings : ' + objMarketingCloudSettings + ']');
        
        if(objMarketingCloudSettings == NULL || objMarketingCloudSettings.AccessToken__c == NULL || objMarketingCloudSettings.TokenExpires__c < DateTime.now()) {
            strBody = String.format('clientId={0}&clientSecret={1}', new String[] { objMarketingCloudSettings.ClientId__c, objMarketingCloudSettings.ClientSecret__c });
            
            objRequest = new HttpRequest();
            objRequest.setMethod('POST');
            objRequest.setEndpoint('callout:Marketing_Cloud_Auth_API/v1/requestToken');
            objRequest.setHeader('content-type', 'application/x-www-form-urlencoded');
            objRequest.setBody(strBody);
            
            objHttp = new Http();               
            objResponse = objHttp.send(objRequest);
            
            if (objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {            
                objAccessToken = (RemotingMessageHelper.MarketingCloudAccessToken)JSON.deserialize(objResponse.getBody(), RemotingMessageHelper.MarketingCloudAccessToken.class);
                
                datTokenExpires = DateTime.now();
                datTokenExpires = datTokenExpires.addSeconds(objAccessToken.expiresIn);
                objMarketingCloudSettings = retrieveCurrentAccessToken();     
                objMarketingCloudSettings.AccessToken__c = JSON.serialize(objAccessToken);
                objMarketingCloudSettings.TokenExpires__c = datTokenExpires;
                
                update objMarketingCloudSettings;
            } else {
                throw new AuthenticationException();
            }
        } 
        
        System.debug('updateAccessToken [] <-');
    }
            
    private static Marketing_Cloud_Settings__c retrieveCurrentAccessToken() {
        Marketing_Cloud_Settings__c objMarketingCloudSettings = null;
        List<Marketing_Cloud_Settings__c> lstMarketingCloudSettingsAux = null;
        
        System.debug('retrieveCurrentAccessToken [] ->'); 
        
        lstMarketingCloudSettingsAux = [SELECT Id, Name, SetupOwnerId, TokenExpires__c, AccessToken__c, ClientId__c, ClientSecret__c, Email_Sender_Address__c, Email_Sender_Name__c, ShortCode__c, SMSKeyword__c, SMSMessageId__c, EmailMessageId__c 
                                        FROM Marketing_Cloud_Settings__c
                                        WHERE SetupOwnerId =: UserInfo.getUserId()];
        
        if(lstMarketingCloudSettingsAux.isEmpty()) {
            lstMarketingCloudSettingsAux = [SELECT Id, Name, SetupOwnerId, TokenExpires__c, AccessToken__c, ClientId__c, ClientSecret__c, Email_Sender_Address__c, Email_Sender_Name__c, ShortCode__c, SMSKeyword__c, SMSMessageId__c, EmailMessageId__c 
                                            FROM Marketing_Cloud_Settings__c
                                            WHERE SetupOwnerId =: UserInfo.getOrganizationId()];
            
            System.debug('retrieveCurrentAccessToken [lstMarketingCloudSettingsAux : ' + lstMarketingCloudSettingsAux + ' - OrganizationId : ' + UserInfo.getOrganizationId() + ' ]');             
        } 
        
        objMarketingCloudSettings = lstMarketingCloudSettingsAux[0];
        
        System.debug('retrieveCurrentAccessToken [' + objMarketingCloudSettings + '] <-'); 
        
        return objMarketingCloudSettings;
    }
    
    public String retrieveDataExtension(RemotingMessageHelper.MarketingCloudAccessToken objAccessToken, String strDataExtensionName) {
        String strMethod = null;
        String strEndpoint = null;
        String strBody = null;
        Map<String, String> mapHeader = null;
		HttpResponse objResponse = null;
        String strObjectId = null;
        String strMessage = null;
        
        System.debug('retrieveDataExtension [ objAccessToken : ' + objAccessToken + ' - strDataExtensionName : ' + strDataExtensionName + '] ->');
        
        if(String.isNotBlank(strDataExtensionName)) { 
            strMethod = 'POST';
            strEndPoint = 'callout:Marketing_Cloud_SOAP_API/' + SOAP_URL; 
                
            mapHeader = new Map<String, String>();
            mapHeader.put('Content-Type', 'text/xml');
            mapHeader.put('SOAPAction', 'Retrieve');

            strBody = retrieveDataExtensionSOAPMessage(objAccessToken.AccessToken, strDataExtensionName);

            objResponse = sendRequest(strMethod, strEndpoint, mapHeader, strBody);
            strBody = objResponse.getBody(); 
            if(objResponse.getStatusCode() == 200) {
                if(strBody.indexOf('ObjectID') > 0) {
                    strObjectId = strBody.substring(strBody.indexOf('<ObjectID>') + 10, strBody.indexOf('</ObjectID>'));
                } else if(strBody.indexOf('<ErrorMessage>')  > 0) {
                    strMessage = strBody.substring(strBody.indexOf('<ErrorMessage>') + 14, strBody.indexOf('</ErrorMessage>'));
                	System.debug('retrieveDataExtension [ strMessage : ' + strMessage + ']');
                }
            } else {                
                System.debug('retrieveDataExtension [ StatusCode : ' + objResponse.getStatusCode() + ']');                
                System.debug('retrieveDataExtension [ strBody : ' + strBody + ']');                                System.debug('retrieveDataExtension [ strMessage : ' + strMessage + ']');                
            }
        } else {            
            throw new OperationException('El nombre de la data extension no puede ser nulo.');
        }
        
        System.debug('retrieveDataExtension [' + strObjectId + '] <-');
        
        return strObjectId;
    }
    
    public String createDataExtension(RemotingMessageHelper.MarketingCloudAccessToken objAccessToken, String strDataExtensionName, List<Field> lstFields) {
        Marketing_Cloud_Settings__c objMarketingCloudSettings = null;
        Set<String> setSubscribersKeys = null;
        String strMethod = null;
        String strEndpoint = null;
        String strBody = null;
        Map<String, String> mapHeader = null;
		HttpResponse objResponse = null;
        String strObjectId = null;
        String strMessage = null;
        
        System.debug('createDataExtension [ objAccessToken : ' + objAccessToken + ' - strDataExtensionName : ' + strDataExtensionName + ' ] ->');
        
        if(String.isNotBlank(strDataExtensionName)) { 
            strMethod = 'POST';
            strEndPoint = 'callout:Marketing_Cloud_SOAP_API/' + SOAP_URL; 
                
            mapHeader = new Map<String, String>();
            mapHeader.put('Content-Type', 'text/xml');
            mapHeader.put('SOAPAction', 'Create');
            
            strBody = createDataExtensionSOAPMessage(objAccessToken.AccessToken, strDataExtensionName, strDataExtensionName, lstFields );

            objResponse = sendRequest(strMethod, strEndpoint, mapHeader, strBody);
            strBody = objResponse.getBody(); 
            if(objResponse.getStatusCode() == 200) {         
                if(strBody.indexOf('<OverallStatus>OK</OverallStatus>') > 0) {
                    if(strBody.indexOf('ObjectID') > 0) {
                        strObjectId = strBody.substring(strBody.indexOf('<ObjectID>') + 10, strBody.indexOf('</ObjectID>'));
                    } else if(strBody.indexOf('<ErrorMessage>') > 0){
                        strMessage = strBody.substring(strBody.indexOf('<ErrorMessage>') + 14, strBody.indexOf('</ErrorMessage>'));
                        throw new OperationException(strMessage);
                    } else {                        
                        throw new OperationException('No se ha podido crear la Data Extension.');
                    }
                } else if(strBody.indexOf('<OverallStatus>Error</OverallStatus>') > 0 && strBody.indexOf('<ErrorMessage>') > 0 ) {
                    strMessage = strBody.substring(strBody.indexOf('<ErrorMessage>') + 14, strBody.indexOf('</ErrorMessage>'));
                    throw new OperationException(strMessage);                    
                } else {
                    throw new OperationException('Ha ocurrido un error al crear la data extension.');
                }
            } else {
                throw new OperationException('Ha ocurrido un error [ ' + strBody + '].');                
            }
        } else {            
            throw new OperationException('El ID de la data extension no puede ser nulo.');
        }
        
        System.debug('createDataExtension [' + strObjectId + '] <-');
        
        return strObjectId;
    }
    
    public String fillDataExtension(RemotingMessageHelper.MarketingCloudAccessToken objAccessToken, String strObjectId, List<Field> lstColumns, List<String> lstRecords) {
        String strMethod = null;
        String strEndpoint = null;
        String strBody = null;
        Map<String, String> mapHeader = null;
		HttpResponse objResponse = null;
        
        System.debug('fillDataExtension [ objAccessToken : ' + objAccessToken + ' - strObjectId : ' + strObjectId + ' - lstColumns ' + lstColumns + ' - lstRecords : ' + lstRecords +  '  ] ->');
        
        if(String.isNotBlank(strObjectId)) { 
            strMethod = 'POST';
            strEndPoint = 'callout:Marketing_Cloud_SOAP_API/' + SOAP_URL; 
                
            mapHeader = new Map<String, String>();
            mapHeader.put('Content-Type', 'text/xml');
            mapHeader.put('SOAPAction', 'Create');

            strBody = addContactsToDataExtensionSOAPMessage(objAccessToken.AccessToken, strObjectId, lstColumns, lstRecords );

            objResponse = sendRequest(strMethod, strEndpoint, mapHeader, strBody);
            strBody = objResponse.getBody();
            
            if(objResponse.getStatusCode() == 200) {
                 
            } else {
                throw new OperationException('Ha ocurrido un error [ ' + strBody + '].');                
            }
        } else {            
            throw new OperationException('El ID de la data extension no puede ser nulo.');
        }
        
        System.debug('fillDataExtension [' + strObjectId + '] <-');
        
        return strObjectId;
    }
    
    private static HttpResponse sendRequest(String strMethod, String strEndpoint, Map<String, string> mapHeader, String strJSON) {
        HttpRequest objRequest = null;
        Http objHttp = null;               
        HttpResponse objResponse = null;
        
        System.debug('sendRequest [ strMethod : ' + strMethod + ' - strEndpoint : ' + strEndpoint + ' - mapHeader : ' + mapHeader +' - strJSON : ' + strJSON + '] ->');
        objRequest = new HttpRequest();
        objRequest.setMethod(strMethod); 
        objRequest.setEndpoint(strEndpoint);
        
        for(String strHeader : mapHeader.keySet()) {            
            objRequest.setHeader(strHeader, mapHeader.get(strHeader));
        }
        objRequest.setBody(strJSON);
        
        objHttp = new Http();               
        objResponse = objHttp.send(objRequest);
        
        System.debug('sendRequest [ Code : ' + objResponse.getStatusCode() + ']');
        System.debug('sendRequest [ Body : ' + objResponse.getBody() + ']');
                
        System.debug('sendRequest [] <-');
        
        return objResponse;
    }
    
    private String retrieveDataExtensionSOAPMessage(String strAccessToken, String strDataExtensionName) {
        String strSOAP = null;
        
        System.debug('retrieveDataExtensionSOAPMessage [ strAccessToken : ' + strAccessToken + ' - strDataExtensionName : ' + strDataExtensionName + ' ] ->');

        strSOAP = '';
        strSOAP += '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        strSOAP += '	<Header>';
        strSOAP += '	    <fueloauth xmlns="http://exacttarget.com">' + strAccessToken + '</fueloauth>';
        strSOAP += '	</Header>';
        strSOAP += '    <Body>';
        strSOAP += '		<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">';
        strSOAP += '			<RetrieveRequest>';
        strSOAP += '				<ObjectType>DataExtension</ObjectType>';
        strSOAP += '				<Properties>ObjectID</Properties>';
        strSOAP += ' 				<Properties>CustomerKey</Properties>';
        strSOAP += '				<Filter xsi:type="SimpleFilterPart">';
        strSOAP += '					<Property>CustomerKey</Property>';
        strSOAP += '					<SimpleOperator>equals</SimpleOperator>';
        strSOAP += '					<Value>' + strDataExtensionName + '</Value>';        
        strSOAP += '				</Filter>';
        strSOAP += '			</RetrieveRequest>';
        strSOAP += '		</RetrieveRequestMsg>';
        strSOAP += '	</Body>';
        strSOAP += '</Envelope>';
               
        System.debug('retrieveDataExtensionSOAPMessage [' + strSOAP + '] <-');
        
		return strSOAP;             
    }
    
    private String createDataExtensionSOAPMessage(String strAccessToken, String strDataExtensionName, String strCustomerKey, List<Field> lstFields) {
        String strSOAP = null;
        
        System.debug('createDataExtensionSOAPMessage [ strAccessToken : ' + strAccessToken + ' - strDataExtensionName : ' + strDataExtensionName + ' - strCustomerKey : ' + strCustomerKey +  ' - lstFields : ' + lstFields + ' ] ->');
        
        strSOAP = '';
        strSOAP += '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        strSOAP += '	<Header>';
        strSOAP += '	    <fueloauth xmlns="http://exacttarget.com">' + strAccessToken + '</fueloauth>';
        strSOAP += '	</Header>';
        strSOAP += '    <Body>';
        strSOAP += '         <CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">';
        strSOAP += '			<Options>';
        strSOAP += '		    	<SaveOptions/>';
        strSOAP += '    		</Options>';
        strSOAP += '			<Objects xsi:type="DataExtension">';
        strSOAP += '				<PartnerKey xsi:nil="true"/>';
        strSOAP += '				<ObjectID xsi:nil="true"/>';      
        strSOAP += '				<CustomerKey>' + strCustomerKey + '</CustomerKey>';                
        strSOAP += '				<Name>' + strDataExtensionName + '</Name>';     
        strSOAP += '				<Description>Salesforce Analytics Data</Description>';  
        strSOAP += '				<IsSendable>true</IsSendable>';  
        strSOAP += '				<DataRetentionPeriodLength>360</DataRetentionPeriodLength>';  
        strSOAP += '				<DataRetentionPeriod>Days</DataRetentionPeriod>';  
        strSOAP += '				<RowBasedRetention>false</RowBasedRetention>';  
        strSOAP += '				<ResetRetentionPeriodOnImport>true</ResetRetentionPeriodOnImport>';  
        strSOAP += '				<DeleteAtEndOfRetentionPeriod>false</DeleteAtEndOfRetentionPeriod>';  
        strSOAP += '				<Fields>';
        for(Field objField : lstFields) {
            strSOAP += objField.toXML();
        }
        strSOAP += '				</Fields>';
        strSOAP += '				<SendableDataExtensionField>';        
        strSOAP += '    				<PartnerKey xsi:nil="true"/>';
        strSOAP += '        			<ObjectID xsi:nil="true"/>';
        strSOAP += '            		<Name>Subscriber Id</Name>';
        strSOAP += '          		</SendableDataExtensionField>';
        strSOAP += '           		<SendableSubscriberField>';
        strSOAP += '          			<Name>Subscriber Id</Name>';
        strSOAP += '         		</SendableSubscriberField>';
        strSOAP += '			</Objects>';
        strSOAP += '		</CreateRequest>';
        strSOAP += '	</Body>';
        strSOAP += '</Envelope>';
               
        System.debug('createDataExtensionSOAPMessage [' + strSOAP + '] <-');
        
		return strSOAP;                                                                                              
    }       
    
    private String addContactsToDataExtensionSOAPMessage(String strAccessToken, String strObjectId, List<Field> lstColumns, List<String> lstContacts) {
        String strSOAP = null;
		String[] arrFields = null;      
        Integer intFieldIndex = null;
        Integer intRecordIndex = null;
        System.debug('addContactsToDataExtensionSOAPMessage [ strAccessToken : ' + strAccessToken + ' - strObjectId : ' + strObjectId + ' - lstContacts : ' + lstContacts +  '] ->');
        
        intRecordIndex = 0;
        System.debug('addContactsToDataExtensionSOAPMessage [ Contacts Size : ' + lstContacts.size() + ']');
        strSOAP = '';
        strSOAP += '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        strSOAP += '	<Header>';
        strSOAP += '	    <fueloauth xmlns="http://exacttarget.com">' + strAccessToken + '</fueloauth>';
        strSOAP += '	</Header>';
        strSOAP += '    <Body>';
        strSOAP += '         <CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">';
        strSOAP += '			<Options>';
        strSOAP += '			<Options>';
        strSOAP += '		    	<SaveOptions>UpdateAdd</SaveOptions>';
        strSOAP += '    		</Options>';
        strSOAP += '    		</Options>';
        for(String strContact : lstContacts) {
            strSOAP += '			<Objects xsi:type="DataExtensionObject">';
            strSOAP += '				<PartnerKey xsi:nil="true"/>';
            strSOAP += '				<ObjectID>' + strObjectId + '</ObjectID>';
            strSOAP += '				<Properties>';
            
            arrFields = strContact.split(';');
            intFieldIndex = 0;
            /*
            if((arrFields.size() + 1) == lstColumns.size() ) {
                for(Field objField : lstColumns) {
                    strSOAP += '<Property>';
                    strSOAP += '	<Name>' + objField.Name + '</Name>';
                    if(intFieldIndex == 0) {
                        strSOAP += '	<Value>' + intRecordIndex + '</Value>';               
                    } else {                    
                        strSOAP += '	<Value>' + arrFields[intFieldIndex - 1] + '</Value>';
                    }
                    strSOAP += '</Property>';
                    intFieldIndex++;
                }
                intRecordIndex++;
            }
*/
            strSOAP += '    			</Properties>';  
            strSOAP += '    		</Objects>';   
        }
        strSOAP += '		</CreateRequest>';
        strSOAP += '	</Body>';
        strSOAP += '</Envelope>';
        
        System.debug('addContactsToDataExtensionSOAPMessage [' + strSOAP + '] <-');
        
        return strSOAP;
    }
}