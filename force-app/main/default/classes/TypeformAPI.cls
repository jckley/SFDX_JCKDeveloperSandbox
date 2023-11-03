public class TypeformAPI {
    public class TypeformException extends Exception {}
    
    public static String retrieveAuthorizationUrl() {
        RemotingMessageHelper.TypeformCredentials objCredentials = null;
        
        System.debug('retrieveAuthorizationUrl [] ->');
        
        objCredentials = retrieveCredentials();
        
        System.debug('retrieveAuthorizationUrl [' + objCredentials.toAuthorizationUrl() + '] <-');
        
        return objCredentials.toAuthorizationUrl();
    } 
    
    public static Boolean retrieveIsAuthenticated() {
        RemotingMessageHelper.TypeformCredentials objCredentials = null;
        
        System.debug('retrieveIsAuthenticated [] ->');
        
        objCredentials = retrieveCredentials();
        
        System.debug('retrieveAuthorizationUrl [' + objCredentials.IsAuthenticated + '] <-');
        
        return objCredentials.IsAuthenticated;
    } 
    
    
    public static String retrieveToken() { 
        RemotingMessageHelper.TypeformCredentials objCredentials = null;
        RemotingMessageHelper.TypeformTokenResponse objTokenResponse = null;
        String strToken = null;
        TypeformSettings__c objTypeformSettings = null;
        List<TypeformSettings__c> lstConfig = null;
        
        objCredentials = retrieveCredentials();
        
        System.debug('retrieveToken [] ->');
        
        if(objCredentials.IsAuthenticated) {
            if(String.isBlank(objCredentials.RefreshToken)) {
                objTokenResponse = retrieveAccessToken(objCredentials);     
                strToken = objTokenResponse.access_token;
                
                lstConfig = [SELECT Id, Code__c, Refresh_Token__c
                             FROM TypeformSettings__c 
                             WHERE SetupOwnerId =: UserInfo.getOrganizationId()];
                
                if(!lstConfig.isEmpty()) {
                    objTypeformSettings = lstConfig[0];  
                    objTypeformSettings.Access_Token__c = objTokenResponse.access_token;
                    objTypeformSettings.Refresh_Token__c = objTokenResponse.refresh_token;
                    objTypeformSettings.Expires__c = (DateTime.now()).addSeconds(objTokenResponse.expires_in);
                    update objTypeformSettings;                
                } else {
                    throw new TypeformException('Debe crear una Custom Setting para guardar la información de conexion a Typeform');
                }
            } else {
                System.debug('refreshing token ?');
                
                if(objCredentials.IsValid) {
                    strToken = objCredentials.AccessToken;
                } else {
                    System.debug('Yes... token expired');
                    objTokenResponse = refreshToken(objCredentials);
                    strToken = objTokenResponse.access_token;
                    
                    
                    lstConfig = [SELECT Id,Access_Token__c, Expires__c
                                 FROM TypeformSettings__c 
                                 WHERE SetupOwnerId =: UserInfo.getOrganizationId()];
                    if(!lstConfig.isEmpty()) {
                        objTypeformSettings = lstConfig[0];  
                        objTypeformSettings.Access_Token__c = objTokenResponse.access_token;
                        objTypeformSettings.Expires__c = DateTime.now().addSeconds(objTokenResponse.expires_in);
                        update objTypeformSettings;
                    } else {
                        throw new TypeformException('Debe crear una Custom Setting para guardar la información de conexion a Typeform');
                    }
                }
            }
        } else {
            throw new TypeformException('Debe autenticar la conexión a Typeform en la pagina de administración');
        }
        System.debug('retrieveToken [' + strToken + '] <-');
        return strToken;  
    }

    @future(callout=true)
    public static void refreshToken() {
         RemotingMessageHelper.TypeformCredentials objCredentials = null;
        RemotingMessageHelper.TypeformTokenResponse objTokenResponse = null;
        String strToken = null;
        TypeformSettings__c objTypeformSettings = null;
        List<TypeformSettings__c> lstConfig = null;
        
        objCredentials = retrieveCredentials();
        
        System.debug('retrieveToken [] ->');
        
        if(objCredentials.IsAuthenticated) {
            if(String.isBlank(objCredentials.RefreshToken)) {
                objTokenResponse = retrieveAccessToken(objCredentials);     
                strToken = objTokenResponse.access_token;
                
                lstConfig = [SELECT Id, Code__c, Refresh_Token__c
                             FROM TypeformSettings__c 
                             WHERE SetupOwnerId =: UserInfo.getOrganizationId()];
                
                if(!lstConfig.isEmpty()) {
                    objTypeformSettings = lstConfig[0];  
                    objTypeformSettings.Access_Token__c = objTokenResponse.access_token;
                    objTypeformSettings.Refresh_Token__c = objTokenResponse.refresh_token;
                    objTypeformSettings.Expires__c = (DateTime.now()).addSeconds(objTokenResponse.expires_in);
                    update objTypeformSettings;                
                } else {
                    throw new TypeformException('Debe crear una Custom Setting para guardar la información de conexion a Typeform');
                }
            } else {
                System.debug('refreshing token ?');
                
                if(objCredentials.IsValid) {
                    strToken = objCredentials.AccessToken;
                } else {
                    System.debug('Yes... token expired');
                    objTokenResponse = refreshToken(objCredentials);
                    strToken = objTokenResponse.access_token;
                    
                    
                    lstConfig = [SELECT Id,Access_Token__c, Expires__c
                                 FROM TypeformSettings__c 
                                 WHERE SetupOwnerId =: UserInfo.getOrganizationId()];
                    if(!lstConfig.isEmpty()) {
                        objTypeformSettings = lstConfig[0];  
                        objTypeformSettings.Access_Token__c = objTokenResponse.access_token;
                        objTypeformSettings.Expires__c = DateTime.now().addSeconds(objTokenResponse.expires_in);
                        update objTypeformSettings;
                    } else {
                        throw new TypeformException('Debe crear una Custom Setting para guardar la información de conexion a Typeform');
                    }
                }
            }
        } else {
            throw new TypeformException('Debe autenticar la conexión a Typeform en la pagina de administración');
        }
    }

    @future(callout=true)
    public static void retrieveTypeformSurvey(String strTypeformId) {
        retrieveTypeformQuestions(strTypeformId);
    }
    
  
    @future(callout=true)
    public static void retrieveTypeformAnswers(String strTypeformId) {
        String strToken = null;
        
        strToken = retrieveToken();
        
        retrieveTypeformAnswers(strToken, strTypeformId);
    }
    
    public static RemotingMessageHelper.TypeformCredentials retrieveCredentials() {
        List<Typeform__mdt> lstSettings = null;
        RemotingMessageHelper.TypeformCredentials objCredentials = null;
        TypeformSettings__c objTypeformSettings = null;
        String strEnvironment = null;
        
        System.debug('retrieveCredentials [] ->');
        
        strEnvironment = 'PulsoCRM';
        lstSettings = [SELECT 	Id, 
                       DeveloperName, 
                       Scope__c, 
                       Callback_Url__c, 
                       ClientId__c,
                       ClientSecret__c,
                       AuthURL__c,
                       TokenUrl__c,
                       FormsUrl__c,
                       Page_Size__c
                       FROM Typeform__mdt
                       WHERE DeveloperName =: strEnvironment];
        
        if(!lstSettings.isEmpty()) {
            objCredentials = new RemotingMessageHelper.TypeformCredentials(lstSettings[0]);
            
            objTypeformSettings = TypeformSettings__c.getInstance();      
            System.debug('Credentials ?');
            if(objTypeformSettings != NULL && String.isNotBlank(objTypeformSettings.Code__c)) {
                System.debug('Yes!');
                System.debug('Code : ' + objTypeformSettings.Code__c);
                System.debug('Access Token : ' + objTypeformSettings.Access_Token__c);
                System.debug('Refresh Token : ' + objTypeformSettings.Refresh_Token__c);
                System.debug('Expires : ' + objTypeformSettings.Expires__c);
                
                objCredentials.Code = objTypeformSettings.Code__c;
                objCredentials.AccessToken = objTypeformSettings.Access_Token__c;
                objCredentials.RefreshToken = objTypeformSettings.Refresh_Token__c;
                objCredentials.ExpiresIn = objTypeformSettings.Expires__c;
            } else {
                System.debug('No. we must authorize');
            }
        }
        
        System.debug('retrieveCredentials [' + objCredentials + '] <-');
        return objCredentials;
    } 
    
    private static RemotingMessageHelper.TypeformTokenResponse retrieveAccessToken(RemotingMessageHelper.TypeformCredentials objCredentials) {
        RemotingMessageHelper.TypeformTokenResponse objTokenResponse = null;
        String strBody = null;
        String strEndpoint = null;
        String strResponse = null;
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        JSONParser objParser = null;
        String strFieldName = null;
        
        
        System.debug('retrieveAccessToken [objCredentials : ' + objCredentials + '] ->');
        objTokenResponse = new RemotingMessageHelper.TypeformTokenResponse();
        
        if(objCredentials.IsAuthenticated) {
            strEndpoint = objCredentials.TokenUrl;
            strBody = String.format('code={0}&client_id={1}&client_secret={2}&redirect_uri={3}&grant_type=authorization_code', new String[] { objCredentials.Code, objCredentials.ClientId, objCredentials.ClientSecret, objCredentials.CallbackUrl });
            
            System.debug('retrieveAccessToken [strEndpoint : ' + strEndpoint + ']');
            System.debug('retrieveAccessToken [strBody : ' + strBody + ']');
            
            objRequest = new HttpRequest();
            objRequest.setMethod('POST');
            objRequest.setEndpoint(strEndpoint);
            objRequest.setHeader('content-type', 'application/x-www-form-urlencoded');        
            objRequest.setHeader('Content-length', String.valueOf(strBody.length()));
            objRequest.setBody(strBody);
            objRequest.setTimeout(60 * 1000);
            
            objHttp = new Http();
            objResponse = objHttp.send(objRequest);
            strResponse = objResponse.getBody();
            
            if(objResponse.getStatusCode() == 200) {               
                System.debug('retrieveAccessToken [strResponse : ' + strResponse + ']');
                objTokenResponse = (RemotingMessageHelper.TypeformTokenResponse)JSON.deserialize(strResponse, RemotingMessageHelper.TypeformTokenResponse.class);           
            } else {
                throw new TypeformException('Ha ocurrido un error al obtener el token [' + strResponse + ']');
            }
        } 
                
        System.debug('retrieveAccessToken [' + objTokenResponse + '] <-');
        
        return objTokenResponse;
    }
    
    private static RemotingMessageHelper.TypeformTokenResponse  refreshToken(RemotingMessageHelper.TypeformCredentials objCredentials ) {
        RemotingMessageHelper.TypeformTokenResponse objTokenResponse = null;
        String strBody = null;
        String strEndpoint = null;
        String strResponse = null;
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        JSONParser objParser = null;
        String strFieldName = null;
        String strAccessToken = null;
        String strTokenType = null;
        Integer intExpiresIn = null;
        
        System.debug('refreshToken [objCredentials : ' + objCredentials + '] ->');
        
        objCredentials = retrieveCredentials();
        if(objCredentials.IsAuthenticated) {
            strEndpoint = objCredentials.TokenUrl;
            strBody = String.format('client_id={0}&client_secret={1}&refresh_token={2}&grant_type=refresh_token', new String[] { objCredentials.ClientId, objCredentials.ClientSecret, objCredentials.RefreshToken});
            
            System.debug('refreshToken [strEndpoint : ' + strEndpoint + ']');
            System.debug('refreshToken [strBody : ' + strBody + ']');
            
            objRequest = new HttpRequest();
            objRequest.setMethod('POST');
            objRequest.setEndpoint(strEndpoint);
            objRequest.setHeader('content-type', 'application/x-www-form-urlencoded');        
            objRequest.setHeader('Content-length', String.valueOf(strBody.length()));
            objRequest.setBody(strBody);
            objRequest.setTimeout(60 * 1000);
            
            objHttp = new Http();
            objResponse = objHttp.send(objRequest);
            
            strResponse = objResponse.getBody();
            System.debug('refreshToken [strResponse : ' + strResponse + ']');
            objTokenResponse = (RemotingMessageHelper.TypeformTokenResponse)JSON.deserialize(strResponse, RemotingMessageHelper.TypeformTokenResponse.class);           

        } 
        
        System.debug('refreshToken [' + objTokenResponse + '] <-');
        
        return objTokenResponse;
    }        
    
    private static void retrieveTypeformQuestions(String strTypeformID) {
        RemotingMessageHelper.TypeformCredentials objCredentials = null;
        RemotingMessageHelper.TypeformSurvey objTypeformSurvey = null;
        String strBody = null;
        String strEndpoint = null;
        String strResponse = null;
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        
        System.debug('retrieveTypeformQuestions [strTypeformID : ' + strTypeformID + '] ->');
        
        try {
            if(String.isNotBlank(strTypeformID)) {
                objCredentials = retrieveCredentials();
                strEndpoint = String.format('{0}{1}', new String[] {objCredentials.FormsUrl, strTypeformID } );
                
                System.debug('retrieveTypeformQuestions [strEndpoint : ' + strEndpoint + ']');
                
                objRequest = new HttpRequest();
                objRequest.setMethod('GET');
                objRequest.setEndpoint(strEndpoint);
                objRequest.setTimeout(60 * 1000);
                
                objHttp = new Http();
                objResponse = objHttp.send(objRequest);
                
                if(objResponse != NULL && objResponse.getStatusCode() == 200) {
                    objTypeformSurvey = (RemotingMessageHelper.TypeformSurvey)JSON.deserialize(objResponse.getBody(), RemotingMessageHelper.TypeformSurvey.class);
                    
                    upsertSurvey(objTypeformSurvey);
                } else if(objResponse.getStatusCode() == 404) {
                    throw new TypeformException('No se ha encontrado la encuesta con el ID : ' + strTypeformID);
                } else {
                    throw new TypeformException('Ha ocurrido un error al obtener la encuesta en Typeform');
                }
            } else {
                throw new TypeformException('Debe proporcionar el identificador de la encuesta en Typeform');
            }
        } catch(Exception Ex) {
            throw new TypeformException('Ha ocurrido un error al intentar obtener la información de la encuesta [ ' + Ex.getMessage() +  ' ]');
        }
        System.debug('retrieveTypeformQuestions [] <-');
    }
    
    private static Encuesta__c upsertSurvey(RemotingMessageHelper.TypeformSurvey objTypeformSurvey) {
        Encuesta__c objSurvey = null;
        
        System.debug('updateSurvey [objTypeformSurvey : ' + objTypeformSurvey + ']');

        if(objTypeformSurvey != NULL && String.isNotBlank(objTypeformSurvey.id) ) {
            objSurvey = new Encuesta__c();
            objSurvey.TypeformId__c = objTypeformSurvey.id;
            //objSurvey.TituloEncuesta__c = objTypeformSurvey.title;
            
            upsert objSurvey TypeformId__c;
            
            upsertQuestions(objSurvey, objTypeformSurvey);
        }
        
        System.debug('updateSurvey [] <-');

        return objSurvey;
    }
    
    private static void upsertQuestions(Encuesta__c objSurvey, RemotingMessageHelper.TypeformSurvey objTypeformSurvey) {
		List<Survey_Question__c> lstSurveyQuestions = null;
        Survey_Question__c objQuestionC = null;
        Integer intIndex = null;
        System.debug('upsertQuestions [objSurvey : ' + objSurvey + ' - objTypeformSurvey : ' + objTypeformSurvey + ']');
        
        if(objTypeformSurvey.fields != NULL && objTypeformSurvey.fields.size() > 0) {
        	lstSurveyQuestions = new List<Survey_Question__c>();
            
            intIndex = 1;
            for(RemotingMessageHelper.TypeformSurveyFields objQuestion : objTypeformSurvey.fields) {
                if(String.isNotBlank(objQuestion.id) && String.isNotBlank(objQuestion.title)) {
                    objQuestionC = new Survey_Question__c();
                    objQuestionC.Survey__c = objSurvey.Id;
                    objQuestionC.Title__c = objQuestion.title;
                    objQuestionC.TypeformId__c = objQuestion.id;
                    objQuestionC.Question_Type__c = objQuestion.type;
                    objQuestionC.Order__c = intIndex;  
                    lstSurveyQuestions.add(objQuestionC);
                    
                    intIndex++;
                }
            }
            
            upsert lstSurveyQuestions TypeformId__c;
            
            upsertOptions(objTypeformSurvey);  
        }
        System.debug('upsertQuestions [] <-');
    }
    
    private static void upsertOptions(RemotingMessageHelper.TypeformSurvey objTypeformSurvey) { 
        List<Survey_Available_Option__c> lstChoicesC = null;
        List<Survey_Available_Option__c> lstChoicesAuxC = null;
        
        System.debug('upsertOptions [ objTypeformSurvey : ' + objTypeformSurvey + ']');
        
        if(objTypeformSurvey.fields != NULL && objTypeformSurvey.fields.size() > 0) {
            lstChoicesC = new List<Survey_Available_Option__c>();
            
            for(RemotingMessageHelper.TypeformSurveyFields objQuestion : objTypeformSurvey.fields) {
                System.debug('upsertOptions [ objQuestion.type : ' + objQuestion.type + ']');
                System.debug('upsertOptions [ objQuestion : ' + objQuestion + ']');
                
                if(objQuestion.properties != NULL) {
                    if(objQuestion.type == 'dropdown') {
                        lstChoicesAuxC = retrieveDropdownChoice(objQuestion.id, objQuestion.properties.choices);
                        lstChoicesC.addAll(lstChoicesAuxC);
                    } else if (objQuestion.type == 'opinion_scale') {
                        lstChoicesAuxC = retrieveOpinionScaleChoice(objQuestion.id, objQuestion.properties);
                        lstChoicesC.addAll(lstChoicesAuxC);       
                    } else if (objQuestion.type == 'picture_choice') {
                        lstChoicesAuxC = retrieveChoicesOptions(objQuestion.id, objQuestion.properties.choices);
                        lstChoicesC.addAll(lstChoicesAuxC);                   
                    } else if (objQuestion.type == 'multiple_choice') { 
                        lstChoicesAuxC = retrieveChoicesOptions(objQuestion.id, objQuestion.properties.choices);
                        lstChoicesC.addAll(lstChoicesAuxC);
                    } 
                } else if (objQuestion.type == 'yes_no') {  
                    lstChoicesAuxC = retrieveYesNoOptions(objQuestion.id);
                    lstChoicesC.addAll(lstChoicesAuxC);
                }
            } 
            System.debug('lstChoicesC : ' + lstChoicesC);
            upsert lstChoicesC TypeformId__c;
        }
        System.debug('upsertOptions [] <-');        
    }
    
    private static List<Survey_Available_Option__c> retrieveChoicesOptions(String strParentTypeformId, List<RemotingMessageHelper.TypeformSurveyFieldsChoices> lstChoices) {
        List<Survey_Available_Option__c> lstChoicesC = null;
        Survey_Available_Option__c objChoiceC = null;
        System.debug('retrieveChoicesOptions [ strParentTypeformId : ' + strParentTypeformId + ' - lstChoices : ' + lstChoices + '] ->');

        lstChoicesC = new List<Survey_Available_Option__c>();
        if(String.isNotBlank(strParentTypeformId) && lstChoices != NULL && !lstChoices.isEmpty()) {
            for(RemotingMessageHelper.TypeformSurveyFieldsChoices objChoice : lstChoices) {
                if(String.isNotBlank(objChoice.Id)) {
                    objChoiceC = new Survey_Available_Option__c();
                    objChoiceC.Survey_Question__r = new Survey_Question__c(TypeformId__c = strParentTypeformId);
                    //objChoiceC.TypeformId__c = objChoice.Id;
                    objChoiceC.TypeformId__c = String.format('{0}{1}', new String[] {strParentTypeformId, objChoice.label });
                    if(objChoice.label.length() > 255) {
                        objChoiceC.Survey_Option__c = objChoice.label.substring(0,255);
                    } else {
                        objChoiceC.Survey_Option__c = objChoice.label;                        
                    }
                    lstChoicesC.add(objChoiceC);
                } else {
                    System.debug('objChoice.label  : ' + objChoice.label);
                }
            }
        }        
            
        System.debug('retrieveChoicesOptions [' + lstChoicesC + '] <-');
        return lstChoicesC;
    }
    
    private static List<Survey_Available_Option__c> retrieveOpinionScaleChoice(String strParentTypeformId, RemotingMessageHelper.TypeformSurveyProperty objOpinionScale) {
        List<Survey_Available_Option__c> lstChoicesC = null;
        Survey_Available_Option__c objChoiceC = null;
        Integer intInitialValue = 0;
        Integer intEndValue = 0;

        System.debug('retrieveChoicesOptions [ strParentTypeformId : ' + strParentTypeformId + ' - objOpinionScale : ' + objOpinionScale + '] ->');

        lstChoicesC = new List<Survey_Available_Option__c>();
        if(String.isNotBlank(strParentTypeformId) && objOpinionScale != NULL && objOpinionScale.steps != NULL) {
            intInitialValue = (objOpinionScale.start_at_one)?1:0;
            intEndValue = (objOpinionScale.start_at_one)?objOpinionScale.steps + 1:objOpinionScale.steps;

            for(Integer intIndex = intInitialValue; intIndex < intEndValue; intIndex++) {
                objChoiceC = new Survey_Available_Option__c();
                objChoiceC.Survey_Question__r = new Survey_Question__c(TypeformId__c = strParentTypeformId);
                objChoiceC.Survey_Option__c = String.valueOf(intIndex);
                
                objChoiceC.TypeformId__c = String.format('{0}{1}', new String[] {strParentTypeformId, String.valueOf(intIndex) });

                lstChoicesC.add(objChoiceC);
            }
        }        
            
        System.debug('retrieveChoicesOptions [' + lstChoicesC + '] <-');
        return lstChoicesC;
    }
    
    private static List<Survey_Available_Option__c> retrieveDropdownChoice(String strParentTypeformId, List<RemotingMessageHelper.TypeformSurveyFieldsChoices> lstChoices) {
        List<Survey_Available_Option__c> lstChoicesC = null;
        Survey_Available_Option__c objChoiceC = null;
        System.debug('retrieveDropdownChoice [ strParentTypeformId : ' + strParentTypeformId + ' - lstChoices : ' + lstChoices + '] ->');
        
        lstChoicesC = new List<Survey_Available_Option__c>();
        if(String.isNotBlank(strParentTypeformId) && lstChoices != NULL && !lstChoices.isEmpty()) {
            for(RemotingMessageHelper.TypeformSurveyFieldsChoices objChoice : lstChoices) {
                objChoiceC = new Survey_Available_Option__c();
                objChoiceC.Survey_Question__r = new Survey_Question__c(TypeformId__c = strParentTypeformId);
                objChoiceC.TypeformId__c = String.format('{0}{1}', new String[] {strParentTypeformId, objChoice.label });
                if(objChoice.label.length() > 255) {
                    objChoiceC.Survey_Option__c = objChoice.label.substring(0,255);
                } else {
                    objChoiceC.Survey_Option__c = objChoice.label;                        
                }
                
                lstChoicesC.add(objChoiceC);                
            }
        }        
        
        System.debug('retrieveDropdownChoice [' + lstChoicesC + '] <-');
        return lstChoicesC;
    }

    private static List<Survey_Available_Option__c> retrieveYesNoOptions(String strParentTypeformId) {
        List<Survey_Available_Option__c> lstChoicesC = null;
        Survey_Available_Option__c objChoiceC = null;
        System.debug('retrieveYesNoOptions [ strParentTypeformId : ' + strParentTypeformId + '] ->');
        
        lstChoicesC = new List<Survey_Available_Option__c>();
        if(String.isNotBlank(strParentTypeformId)) {
            objChoiceC = new Survey_Available_Option__c();
            objChoiceC.Survey_Option__c = 'Yes';
            objChoiceC.Survey_Question__r = new Survey_Question__c(TypeformId__c = strParentTypeformId);
            objChoiceC.TypeformId__c = String.format('{0}{1}', new String[] {strParentTypeformId, 'Yes' });
            lstChoicesC.add(objChoiceC);                
            
            objChoiceC = new Survey_Available_Option__c();
            objChoiceC.Survey_Option__c = 'No';
            objChoiceC.Survey_Question__r = new Survey_Question__c(TypeformId__c = strParentTypeformId);
            objChoiceC.TypeformId__c = String.format('{0}{1}', new String[] {strParentTypeformId, 'No' });            
            lstChoicesC.add(objChoiceC);                
        }        
        
        System.debug('retrieveYesNoOptions [' + lstChoicesC + '] <-');
        return lstChoicesC;
    }
    
    public static void retrieveTypeformAnswers(String strToken, String strTypeformID) {
        retrieveTypeformAnswers(strToken, strTypeformID, NULL, NULL, NULL, NULL);
    }
    //2017-07-09T00:00:00
    //since until after
    //@future(callout=true)
    public static void retrieveTypeformAnswers(String strToken, String strTypeformID, String strDateSince, String strDateUntil) {
        retrieveTypeformAnswers(strToken, strTypeformID, strDateSince, strDateUntil, NULL, NULL);
    }
       
    public static void retrieveTypeformAnswers(String strToken, String strTypeformID, String strTokenAfter) {
        retrieveTypeformAnswers(strToken, strTypeformID, NULL, NULL, strTokenAfter, NULL);
    }
    
    private static void retrieveTypeformAnswers(String strToken, String strTypeformID, String strDateSince, String strDateUntil, String strTokenAfter, String strTokenBefore) {
        RemotingMessageHelper.TypeformSurveyReponses objTypeformSurveyReponses = null;
        RemotingMessageHelper.TypeFormCredentials objCredentials = null;
        String strEndpoint = null;
        String strResponse = null;
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        Lead objLead = null;
        Map<Long, List<RemotingMessageHelper.TypeformSurveyReponseItem>>  mapSurveysByUser = null;
        
        System.debug('retrieveTypeformAnswers [strTypeformID : ' + strTypeformID + '] ->');
        
        objCredentials = retrieveCredentials();
         
        if(objCredentials.IsAuthenticated) {
            if(String.isNotBlank(strDateSince) && String.isNotBlank(strDateUntil)) {
                strEndpoint = String.format('{0}{1}/responses?page_size={2}&since={3}&until={4}', new String[] {objCredentials.FormsUrl, strTypeformID, String.valueOf(objCredentials.PageSize), strDateSince, strDateUntil } );                                
            } else if(String.isNotBlank(strTokenAfter)) {
                strEndpoint = String.format('{0}{1}/responses?page_size={2}&after={3}', new String[] {objCredentials.FormsUrl, strTypeformID, String.valueOf(objCredentials.PageSize), strTokenAfter } );                                
            } else {
                strEndpoint = String.format('{0}{1}/responses?page_size={2}', new String[] {objCredentials.FormsUrl, strTypeformID, String.valueOf(objCredentials.PageSize)} );                
            }
            
            System.debug('retrieveTypeformAnswers [strEndpoint : ' + strEndpoint + ']');
            
            objRequest = new HttpRequest();
            objRequest.setMethod('GET');
            objRequest.setEndpoint(strEndpoint);
            objRequest.setHeader('Authorization', 'Bearer ' + strToken); 
            objRequest.setHeader('content-type', 'application/x-www-form-urlencoded');        
            objRequest.setTimeout(60 * 1000);
            
            objHttp = new Http();
            objResponse = objHttp.send(objRequest);        
            if(objResponse.getStatusCode() == 200) {    
                strResponse = objResponse.getBody();
                strResponse = replaceSpecialFieldName(strResponse); 
                
                objTypeformSurveyReponses = (RemotingMessageHelper.TypeformSurveyReponses)JSON.deserialize(strResponse,RemotingMessageHelper.TypeformSurveyReponses.class);

                if(objTypeformSurveyReponses != NULL && objTypeformSurveyReponses.items != NULL && objTypeformSurveyReponses.items.size() > 0) {
                    //creo o actualizo leads. 
                    //upsertAllLeads(objTypeformSurveyReponses.items);
                    mapSurveysByUser = retrieveSurverAnsweredByUser(objTypeformSurveyReponses.items);
                    
                    //si un usuario puede contestar varias veces la misma encuesta, 
                    //entonces, crear un mapa<id,list de respiestas>

                    upsertAllUserSurveys(strTypeformID, mapSurveysByUser);
                    upsertAllAnswers(strTypeformID, mapSurveysByUser);
                }    
            } else if(objResponse.getStatusCode() == 404) {
                throw new TypeformException('No se encontró la encuesta.');
            }       
        } else {
            throw new TypeformException('Debe autorizar la aplicacion en Typeform.');
        }
        
        System.debug('retrieveTypeformAnswers [] <-');
    }
    
    private static Map<Long, List<RemotingMessageHelper.TypeformSurveyReponseItem>> retrieveSurverAnsweredByUser(List<RemotingMessageHelper.TypeformSurveyReponseItem> lstItems) {
        Map<Long, List<RemotingMessageHelper.TypeformSurveyReponseItem>> mapSurveysByUser = null;
        Long lngFacebookId = NULL;
        Survey_Setting__mdt objSurveySettings = null;
        List<Lead> lstLeads = NULL;
        Set<Long> setLeadId = NULL;

        System.debug('retrieveSurverAnsweredByUser [lstItems : ' + lstItems + '] ->');
        
        mapSurveysByUser = new Map<Long, List<RemotingMessageHelper.TypeformSurveyReponseItem>>();
        objSurveySettings = HelperFunctions.retrieveSurveySettings('Pulso_CRM');
        lstLeads = [SELECT Id, FacebookId__c FROM Lead WHERE RecordType.DeveloperName = 'PulsoCRM' ORDER BY LastModifiedDate DESC LIMIT 40000];
        setLeadId = new Set<Long>();
        for(Lead objLead : lstLeads) {
            setLeadId.add( (Long)objLead.FacebookId__c);
        }

        for(RemotingMessageHelper.TypeformSurveyReponseItem objItem : lstItems) {
            try {
                if(validateItem(objItem, objSurveySettings)) {
                    lngFacebookId = Long.valueOf(objItem.hidden.fbid);
                    
                    if(setLeadId.contains(lngFacebookId)) {
                        if(!mapSurveysByUser.containsKey(lngFacebookId)) {
                            mapSurveysByUser.put(lngFacebookId, new List<RemotingMessageHelper.TypeformSurveyReponseItem>());  
                        } 
                        
                        mapSurveysByUser.get(lngFacebookId).add(objItem);
                    }
                }
            } catch(Exception Ex) {
                HelperFunctions.handleRuntimeException(Ex);
            }
        }
        
        System.debug('retrieveSurverAnsweredByUser [' + mapSurveysByUser + '] <-');

        return mapSurveysByUser;
    }
    
    private static void upsertAllLeads(List<RemotingMessageHelper.TypeformSurveyReponseItem> lstItems) {
        List<Lead> lstLeads = null;
        Lead objLead = null;
        Set<Long> setFacebookId = null;
        Survey_Setting__mdt objSurveySettings = null;
        Long lngFacebookId = null;
        
        System.debug('upsertAllLeads [lstItems : ' + lstItems + '] ->');

        lstLeads = new List<Lead>();
        setFacebookId = new Set<Long>();
        objSurveySettings = HelperFunctions.retrieveSurveySettings('Pulso_CRM');
        
        for(RemotingMessageHelper.TypeformSurveyReponseItem objItem : lstItems) {
            if(validateItem(objItem, objSurveySettings)) {
                lngFacebookId = Long.valueOf(objItem.hidden.fbid);
                if(!setFacebookId.contains(lngFacebookId)) {
                    objLead = new Lead();
                    objLead.Company = 'PulsoCRM';
                    objLead.LastName = objItem.hidden.fbid;
                    objLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PulsoCRM').getRecordTypeId();
                    objLead.FacebookId__c = lngFacebookId;
                    lstLeads.add(objLead);
                    
                    setFacebookId.add(lngFacebookId);
                }                
            }
        }
        
        upsert lstLeads FacebookId__c;
        
        System.debug('upsertAllLeads [] <-');
    }
    
    private static void upsertAllUserSurveys(String strTypeformId, Map<Long, List<RemotingMessageHelper.TypeformSurveyReponseItem>>  mapSurveysByUser) {
        List<RemotingMessageHelper.TypeformSurveyReponseItem> lstSurveysByUser = null;
        RemotingMessageHelper.TypeformSurveyReponseItem objItem = null;
        List<User_Survey__c> lstUserSurvey = null;
        User_Survey__c objUserSurvey = null;
        Survey_Setting__mdt objSurveySettings = null;
        Id objSurveyId = null;
        Set<String> setUsers = null;
        System.debug('upsertAllUserSurveys [mapSurveysByUser : ' + mapSurveysByUser + '] ->');

        lstUserSurvey = new List<User_Survey__c>();
        objSurveySettings = HelperFunctions.retrieveSurveySettings('Pulso_CRM');
        objSurveyId = [SELECT Id FROM Encuesta__c WHERE TypeformId__c =: strTypeformId].Id;
        
        setUsers = new Set<String>();

        for(Long lngFacebookId : mapSurveysByUser.keySet() ) {
            lstSurveysByUser = mapSurveysByUser.get(lngFacebookId);
            
            for(Integer intIndex = 0; intIndex < lstSurveysByUser.size(); intIndex++ ) {
                if(intIndex == 0) {
                    objItem = lstSurveysByUser[0];
                    if(validateItem(objItem, objSurveySettings)) {
                        objUserSurvey = new User_Survey__c();
                        objUserSurvey.Lead__r = new Lead(FacebookId__c = Long.valueOf(objItem.hidden.fbid));
                        objUserSurvey.Survey__c = objSurveyId;
                        objUserSurvey.IP__c = (String.isNotBlank(objItem.hidden.d))?objItem.hidden.d:NULL;
                        objUserSurvey.ExternalId__c = String.format('{0}{1}', new String[] {objItem.hidden.fbid, strTypeformId});
                        if(objItem.metadata != NULL && objItem.metadata.referer != NULL && String.isNotBlank(objItem.metadata.referer) && objItem.metadata.referer.length() > 255 ) {
                            objUserSurvey.Referer__c = objItem.metadata.referer.substring(0,255);                            
                        } else {
                            objUserSurvey.Referer__c = (objItem.metadata != NULL && String.isNotBlank(objItem.metadata.referer))?objItem.metadata.referer:NULL;
                        }

                        if(!setUsers.contains(objUserSurvey.ExternalId__c)) {
                            setUsers.add(objUserSurvey.ExternalId__c);
                            lstUserSurvey.add(objUserSurvey);
                        }
                    }
                }
            }
        }
                    
        upsert lstUserSurvey ExternalId__c;
        
        System.debug('upsertAllUserSurveys [] <-');
    }
    
    private static void upsertAllAnswers(String strTypeformId, Map<Long, List<RemotingMessageHelper.TypeformSurveyReponseItem>>  mapSurveysByUser) {
        List<RemotingMessageHelper.TypeformSurveyReponseItem> lstSurveysByUser = null;
        RemotingMessageHelper.TypeformSurveyReponseItem objItem = null;
        List<User_Survey_Answers__c> lstAnswers = null;
        User_Survey_Answers__c objAnswerC = null;
        
        System.debug('upsertAllAnswers [mapSurveysByUser : ' + mapSurveysByUser + '] ->');

        lstAnswers = new List<User_Survey_Answers__c>();

        for(Long lngFacebookId : mapSurveysByUser.keySet() ) {
            lstSurveysByUser = mapSurveysByUser.get(lngFacebookId);
            
            for(Integer intIndex = 0; intIndex < lstSurveysByUser.size(); intIndex++ ) {
                if(intIndex == 0) { 
                    objItem = lstSurveysByUser[0];
                    
                    if(objItem.hidden != NULL && objItem.hidden.fbid != NULL && String.isNotBlank(objItem.hidden.fbid) && objItem.answers != NULL && objItem.answers.size() > 0) {                
                        for(RemotingMessageHelper.TypeformSurveyReponseItemAnswer objAnswer : objItem.answers) {
                            if(String.isNotBlank(objItem.hidden.fbid) && String.isNotBlank(strTypeformId) && String.isNotBlank(objAnswer.field.id)) {
                                if(objAnswer.field.type == 'dropdown') {
                                    if(String.isNotBlank(objAnswer.text)) {
                                        objAnswerC = new User_Survey_Answers__c();
                                        objAnswerC.User_Survey__r = new User_Survey__c( ExternalId__c = String.format('{0}{1}', new String[] {objItem.hidden.fbid, strTypeformId} ) );
                                        objAnswerC.Survey_Available_Option__r = new Survey_Available_Option__c(TypeformId__c = String.format('{0}{1}', new String[] {objAnswer.field.id, objAnswer.text }));                
                                        objAnswerC.TypeformId__c = String.format('{0}{1}{2}{3}', new String[] {objItem.hidden.fbid, strTypeformId, objAnswer.field.id, objAnswer.text});
                                        
                                        lstAnswers.add(objAnswerC);            
                                    }
                                } else if (objAnswer.field.type == 'opinion_scale') {
                                    if(objAnswer.number_x != NULL) {                                        
                                        objAnswerC = new User_Survey_Answers__c();
                                        objAnswerC.User_Survey__r = new User_Survey__c( ExternalId__c = String.format('{0}{1}', new String[] {objItem.hidden.fbid, strTypeformId} ) );
                                        objAnswerC.Survey_Available_Option__r = new Survey_Available_Option__c(TypeformId__c = String.format('{0}{1}', new String[] {objAnswer.field.id, String.valueOf(objAnswer.number_x) }));                
                                        objAnswerC.TypeformId__c = String.format('{0}{1}{2}{3}', new String[] {objItem.hidden.fbid, strTypeformId, objAnswer.field.id, String.valueOf(objAnswer.number_x)});
                                        lstAnswers.add(objAnswerC);         
                                    }
                                } else if (objAnswer.field.type == 'picture_choice') {
                                    if(String.isNotBlank(objAnswer.choice.label)) {                                                                                
                                        objAnswerC = new User_Survey_Answers__c();
                                        objAnswerC.User_Survey__r = new User_Survey__c( ExternalId__c = String.format('{0}{1}', new String[] {objItem.hidden.fbid, strTypeformId} ) );
                                        objAnswerC.Survey_Available_Option__r = new Survey_Available_Option__c(TypeformId__c = String.format('{0}{1}', new String[] {objAnswer.field.id, objAnswer.choice.label }));                                    
                                        objAnswerC.TypeformId__c = String.format('{0}{1}{2}{3}', new String[] {objItem.hidden.fbid, strTypeformId, objAnswer.field.id, objAnswer.choice.label});
                                        lstAnswers.add(objAnswerC);
                                    }
                                } else if (objAnswer.field.type == 'multiple_choice') { 
                                    if(String.isNotBlank(objAnswer.choice.label)) {                                                                                
                                        objAnswerC = new User_Survey_Answers__c();
                                        objAnswerC.User_Survey__r = new User_Survey__c( ExternalId__c = String.format('{0}{1}', new String[] {objItem.hidden.fbid, strTypeformId} ) );
                                        objAnswerC.Survey_Available_Option__r = new Survey_Available_Option__c(TypeformId__c = String.format('{0}{1}', new String[] {objAnswer.field.id, objAnswer.choice.label }));                                    
                                        objAnswerC.TypeformId__c = String.format('{0}{1}{2}{3}', new String[] {objItem.hidden.fbid, strTypeformId, objAnswer.field.id, objAnswer.choice.label});
                                        lstAnswers.add(objAnswerC);
                                    }
                                } else if(objAnswer.field.type == 'yes_no') { 
                                    if(objAnswer.boolean_x != NULL) {                                                                                
                                        objAnswerC = new User_Survey_Answers__c();
                                        objAnswerC.User_Survey__r = new User_Survey__c( ExternalId__c = String.format('{0}{1}', new String[] {objItem.hidden.fbid, strTypeformId} ) );
                                        if(objAnswer.boolean_x == True) {
                                            objAnswerC.Survey_Available_Option__r = new Survey_Available_Option__c(TypeformId__c = String.format('{0}{1}', new String[] {objAnswer.field.id, 'Yes' }));                                                                                
                                        } else {
                                            objAnswerC.Survey_Available_Option__r = new Survey_Available_Option__c(TypeformId__c = String.format('{0}{1}', new String[] {objAnswer.field.id, 'No' }));                                                                                
                                        }
                                        objAnswerC.TypeformId__c = String.format('{0}{1}{2}', new String[] {objItem.hidden.fbid, strTypeformId, objAnswer.field.id});
                                        lstAnswers.add(objAnswerC);
                                    }
                                }                                
                            } 
                        }
                    }
                } 
            } 
        }
        
        upsert lstAnswers TypeformId__c;
        
        System.debug('upsertAllAnswers [] <-');
    }
    
    private static string replaceSpecialFieldName(String strResponse) {
        System.debug('replaceSpecialFieldName [strResponse : ' + strResponse + '] ->');
        
        strResponse = strResponse.replaceAll('number', 'number_x');
        strResponse = strResponse.replaceAll('boolean', 'boolean_x');
        
        System.debug('replaceSpecialFieldName [' + strResponse + '] <-');
        
        return strResponse;
    }
    
    private static Boolean validateItem(RemotingMessageHelper.TypeformSurveyReponseItem objItem,  Survey_Setting__mdt objSurveySettings ) {
        String strPlainText = null;
        Blob blbEncrypted = null;
        Long lngFacebookId = null;
        Boolean boolIsValid = false;
        
        System.debug('validateItem [objItem : ' + objItem + ' - objSurveySettings : ' + objSurveySettings + '] ->');
        
        if(objItem.hidden != NULL && objItem.hidden.fbid != NULL && String.isNotBlank(objItem.hidden.fbid) && objItem.hidden.fbid.isNumeric() && objItem.hidden.pulsohash != NULL && String.isNotBlank(objItem.hidden.pulsohash) ) {                 
            strPlainText = String.format('{0}{1}', new String[] { objItem.hidden.fbid, objSurveySettings.Crypto_Message_Public_Key__c } );
            blbEncrypted = Crypto.encrypt('AES128', Blob.valueOf(objSurveySettings.Crypto_Message_Secret_Key__c), Blob.valueOf(objSurveySettings.Crypto_Message_Public_Key__c), Blob.valueOf(strPlainText));
            
            if(blbEncrypted != NULL && EncodingUtil.base64Encode(blbEncrypted).replace('+',' ') == objItem.hidden.pulsohash) { 
                boolIsValid = true;
            } 
        }
        
        System.debug('validateItem [' + boolIsValid + '] <-');

        return boolIsValid;
    }
}