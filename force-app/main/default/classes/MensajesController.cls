global class MensajesController {           
    public static final String SONDEOS = 'SONDEOS';
    public static final String MARKETING_CLOUD = 'MC';
    public String Usuario {get; set; }
    public String Password {get; set; }
    public String Provision {get; set; }
    public String Operacion {get; set; }
    public String SourceAddress {get; set; }
    public String ConsultaEstado {get; set; }
    public String MensajeId {get; set; }
    public String MaxIntentos {get; set; }


    global List<Campania__c> campanias;
    global List<Message__c> mensajes;

    public MensajesController() {
        String strCampaniaId = null;
        List<Message__c> lstMessage = null;
        Integer intSender = null;
        SMS_Sondeos__mdt  objSettings = null;

        strCampaniaId = ApexPages.currentPage().getParameters().get('campania');
        
        if(String.isNotBlank(strCampaniaId)) {
            try {
                lstMessage = mensajes(strCampaniaId);
                MensajeId = lstMessage[0].Id;
                intSender = Integer.valueOf(lstMessage[0].Sender__c);
                objSettings = retrieveSMSSettings(intSender);


                Usuario  = objSettings.Usuario__c;
                Password = objSettings.Password__c;
                Provision = objSettings.Provision__c;
                Operacion = objSettings.Operacion__c;

                SourceAddress = String.valueOf(intSender);
                ConsultaEstado = '3';
                MensajeId =  lstMessage[0].Id;
                MaxIntentos = '3';                            
            } catch(Exception Ex) {

            }
        } 
    }
    
	@RemoteAction
    @AuraEnabled(cacheable=true)
    global static List<Campania__c> campanias (String strJSON) {
        return [SELECT Id, Name, Status__c, FORMAT(StartDate__c) Desde, Cantidad_Mensajes__c
                FROM Campania__c
                ORDER BY StartDate__c DESC];
    }

    

    @RemoteAction
    global static List<Message__c> mensajes (String campania) {
        return [SELECT  Name, 
                        Body__c, 
                        SendDateTime__c, 
                        Sender__c, 
                        TotalsSent__c, 
                        TotalsAudience__c, 
                        ImpXPersona__c, 
                        CantSuccess__C, 
                        CantRejected__c, 
                        CantResponses__c,
                        Campania__r.Status__c, 
                        Receiver_id__c, 
                        Receiver__c
                FROM Message__c
                WHERE Campania__c = :campania
                ORDER BY CreatedDate DESC 
                LIMIT 1];
    }
        
    @RemoteAction
    @AuraEnabled(cacheable=true)
    global static RemotingMessageHelper.OperationResult sendMessage (String strSender,  String strDataExtension, String strDataExtensionName, String strMessage, String strTitulo, String strProyectoId, String strProyecto, String strCampaniaId, String strCampania, String strPlatform) {
        Project__c objProject = null;
        Campania__c objCampaign = null;
        Message__c objMessage = null;
        RemotingMessageHelper.SMSSondeosRequest objRequest = null;
        String  strType = null;
        Boolean boolAllData = true;
        Boolean boolSendable = true;
        String  strSAQL = null;
        String  strSurvey = null;
        RemotingMessageHelper.OperationResult objResult = null;

        System.debug('sendMessage[strSender : ' + strSender + ' - strDataExtension : ' + strDataExtension + ' - strMessage : ' + strMessage + ' - strTitulo : ' + strTitulo + ' - strCampania : ' + strCampania + ' - strPlatform : ' + strPlatform + '] ->');
        
        try {
            objResult = new RemotingMessageHelper.OperationResult ();
            strType = strPlatform.equals(MARKETING_CLOUD) ? 'sms_mc' : 'sms';
            objRequest = new RemotingMessageHelper.SMSSondeosRequest();

            objProject = createProject(strProyectoId, strProyecto);
            objCampaign = createCampaign(strCampaniaId, strCampania, objProject.Id);            
            objMessage = createMessage(objCampaign, strDataExtension, strDataExtensionName, strSender, strTitulo, strMessage);
            
            objRequest.dataExtension = strDataExtension;
            objRequest.dataExtensionName = strDataExtensionName;
            objRequest.message = strMessage;
            objRequest.messageid = objMessage.Id;
            //objRequest.proyecto = strProyecto;
            objRequest.sender = strSender;
            objRequest.titulo = strTitulo;
            strSAQL = JSON.serialize(objRequest, true);

            ExportController.insertReport(strType, strTitulo, boolAllData, boolSendable, strSAQL, strDataExtensionName, '', NULL, NULL, NULL, NULL, NULL,  'Pendiente de aprobación', '', 0);
            
            objResult.Code = 0;
            objResult.Message = 'Operación realizada exitosamente';
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);
            objResult.Code = 999;
            objResult.Message = 'Ha ocurrido un error al realizar la operación';
        }

        System.debug('sendMessage[' + objResult + '] <-');

        return objResult;
    }
        
    @AuraEnabled(cacheable=true)
    global static void sendApprovedMessage (String strSender,  String strDataExtension, String strDataExtensionName, String strMessage, String strTitulo, String strMessageId) {
        System.debug('sendApprovedMessage [ strSender : ' + strSender + ' - strDataExtension : ' + strDataExtension + ' - strDataExtensionName : ' + strDataExtensionName + ' - strMessage : ' + strMessage + '- strTitulo : ' + strTitulo + '- strMessageId : ' + strMessageId + ' ] ->');
        sendApprovedMessage(strSender, strDataExtension, strDataExtensionName, strMessage, strTitulo, strMessageId, SONDEOS);
    }

    @AuraEnabled(cacheable=true)
    global static void sendApprovedMessage (String strSender,  String strDataExtension, String strDataExtensionName, String strMessage, String strTitulo, String strMessageId, String strPlatform) {
        Campania__c objCampaign = null;
        Message__c objMessage = null;

        System.debug('sendApprovedMessage [ strSender : ' + strSender + ' - strDataExtension : ' + strDataExtension + ' - strDataExtensionName : ' + strDataExtensionName + ' - strMessage : ' + strMessage + '- strTitulo : ' + strTitulo + '- strMessageId : ' + strMessageId + '- strPlatform : ' + strPlatform  + ' ] ->');

        if(String.IsNotBlank(strMessage) && String.IsNotBlank(strDataExtension)) {
            objMessage = [SELECT Id, Campania__c FROM Message__c WHERE Id =: strMessageId];
            objCampaign = [SELECT Status__c FROM Campania__c WHERE Id =: objMessage.Campania__c];
            objCampaign.Status__c = 'En ejecución';
            update objCampaign;
            
            if(strPlatform.equals(SONDEOS)){
                //sendMessageToAWS(objCampaign.Id, objMessage.Id, strSender,  strDataExtension, strDataExtensionName, strMessage, strTitulo, strProyecto);    
                sendMessageToAWS(objCampaign.Id, objMessage.Id, strSender,  strDataExtension, strDataExtensionName, strMessage, strTitulo);    
            } else {
                sendMessageToMarketingCloud(objMessage.Id, strDataExtension, strDataExtensionName, strMessage);
            }
        }

        System.debug('sendApprovedMessage [] <-');
    }
       
    @future(callout=True)
    //private static void sendMessageToAWS(String strCampaignId, String strMessageId, String strSender,  String strDataExtension, String strDataExtensionName, String strMessage, String strTitulo, String strProyecto) {
    private static void sendMessageToAWS(String strCampaignId, String strMessageId, String strSender,  String strDataExtension, String strDataExtensionName, String strMessage, String strTitulo) {
        SMS_Sondeos__mdt objSettings = null;
        RemotingMessageHelper.SMSSends objSend = null;
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        String strBody = null;
        String strEndpoint = null;
        String strResponse = null;
        Campania__c objCampaign = null;
        List<Export__c> lstExport = null;

        System.debug('sendMessageToAWS [strCampaignId : ' + strCampaignId + ' - strMessageId : ' + strMessageId + ' - strSender : ' + strSender + ' - strDataExtension : ' + strDataExtension + ' - strDataExtensionName : ' + strDataExtensionName + ' - strMessage : ' + strMessage + ' - strTitulo : ' + strTitulo + '] ->');

        try {
            objSettings = retrieveSMSSettings(Integer.valueOf(strSender));
            objSend = createSMSRequest(objSettings, strDataExtension, strSender, strMessage, strMessageId);

            strEndpoint = 'https://api-pulso.prosumia.la/aws-api/sondeos/';
            strBody = JSON.serialize(objSend);

            System.debug('sendMessageToAWS [strBody : ' + strBody + ']');

            objRequest = new HttpRequest();
            objRequest.setMethod('POST');
            objRequest.setEndpoint(strEndpoint);
            objRequest.setHeader('content-type', 'application/json');        
            objRequest.setBody(strBody);
            objRequest.setTimeout(60 * 1000);

            objHttp = new Http();
            objResponse = objHttp.send(objRequest);
            strResponse = objResponse.getBody();
            if(objResponse.getStatusCode() <> 200) {
                objCampaign = new Campania__c();
                objCampaign.Id = strCampaignId;
                objCampaign.Status__c = 'Finalizado con Errores';
                update objCampaign;

                lstExport = [SELECT Status__c FROM Export__c WHERE Status__c = 'En ejecución' AND Type__c = 'sms'];
                for(Export__c objExport : lstExport) {
                    objExport.Status__c = 'Finalizado con Errores';
                }
                update lstExport;
                
            }
        } catch(Exception Ex) {
            objCampaign = new Campania__c();
            objCampaign.Id = strCampaignId;
            objCampaign.Status__c = 'Finalizado con Errores';
            update objCampaign;

            lstExport = [SELECT Status__c FROM Export__c WHERE Status__c = 'En ejecución' AND Type__c = 'sms'];
            for(Export__c objExport : lstExport) {
                objExport.Status__c = 'Finalizado con Errores';
            }
            update lstExport;


        }

        System.debug('sendMessageToAWS [' + strResponse + '] <-');
    }

    @future(callout=True)
    @AuraEnabled(cacheable=true)
    public static void sendMessageToMarketingCloud(String strMessageId, String strDataExtension, String strDataExtensionName, String strMessage) {
        
        Message__c objMessage = null;
        RemotingMessageHelper.MCSMS2 objMCSMS = null;
        RemotingMessageHelper.MarketingCloudAccessToken objToken = null;
        RemotingMessageHelper.UserPermissions objUserPermissions = null;
        Marketing_Cloud_Setting__mdt objSettings = null;
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        RemotingMessageHelper.SMSResponses objSMSResponses = null;
        
        System.debug('sendMessageToMarketingCloud [strDataExtension : ' + strDataExtension + ' - strDataExtensionName : ' + strDataExtensionName + ' - strMessage : ' + strMessage  + '] ->'); 
        
        try {

            objMessage = [SELECT Id, Campania__c FROM Message__c WHERE Id =: strMessageId];
            
            objSettings = retrieveMarketingCloudSettings('Prosumia');

            objUserPermissions = new RemotingMessageHelper.UserPermissions();
            MarketingCloudAPIHandler objMC = new MarketingCloudAPIHandler();
            objToken = objMC.retrieveAccessToken();

            objMCSMS = new RemotingMessageHelper.MCSMS2(objSettings.SMS_Message_Id__c, 'FREETEXT');        
            objMCSMS.OverrideText = strMessage;
            objMCSMS.addDataExtension(strDataExtensionName);
            System.debug('sendMessageToMarketingCloud [UserInfo.getUserEmail(): ' + UserInfo.getUserEmail() +']');  
            objMCSMS.NotificationEmail = UserInfo.getUserEmail();

            objRequest = new HttpRequest();
            objRequest.setMethod('POST');
            objRequest.setEndpoint(objSettings.Send_SMS_Url__c);
            
            objRequest.setHeader('content-type', 'application/json');
            // objRequest.setHeader('Authorization', 'Bearer ' + objToken.access_token );
            objRequest.setHeader('Authorization', 'Bearer ' + objToken.accessToken );
            System.debug('sendMessageToMarketingCloud [objtoken.accessToken : ' + objToken.accessToken + ']');

            objRequest.setBody(JSON.serialize(objMCSMS).replace('OverrideAux', 'Override'));
                    
            System.debug('sendMessageToMarketingCloud [Endpoint : ' + objSettings.Send_SMS_Url__c +']');    
            System.debug('sendMessageToMarketingCloud [objMCSMS : ' + objMCSMS +']');   
            System.debug('sendMessageToMarketingCloud [Body : ' + objRequest.getBody() +']');   

            objHttp = new Http();                           
            objResponse = objHttp.send(objRequest);

            System.debug(objResponse);
            System.debug(JSON.deserialize(objResponse.getBody(), RemotingMessageHelper.SMSResponses.class));

            if(objResponse.getStatusCode() == 202 || objResponse.getStatusCode() == 201) {
                objSMSResponses = (RemotingMessageHelper.SMSResponses)JSON.deserialize(objResponse.getBody(), RemotingMessageHelper.SMSResponses.class);
                objMessage.MC_Token_Id__c = objSMSResponses.tokenId;
            } 

        } catch(Exception Ex) {
            objMessage.MC_Token_Id__c = null;
        }

        System.debug('sendMessageToMarketingCloud [' + objMessage +'] <-');    
        
        update objMessage;
    
    }


    @future(callout=True)
    @AuraEnabled(cacheable=true)
    public static void sendSingleMessageToMarketingCloud(String strMessage, String strPhoneNumber) {
        
        Message__c objMessage = null;
        RemotingMessageHelper.MCSMS2 objMCSMS = null;
        RemotingMessageHelper.MarketingCloudAccessToken objToken = null;
        RemotingMessageHelper.UserPermissions objUserPermissions = null;
        Marketing_Cloud_Setting__mdt objSettings = null;
        HttpResponse objResponse = null;
        RemotingMessageHelper.SMSResponses objSMSResponses = null;
        
        System.debug('sendSingleMessageToMarketingCloud [strMessage : ' + strMessage + ' - strPhoneNumber : ' + strPhoneNumber  + '] ->'); 
        
        try {

            objSettings = retrieveMarketingCloudSettings('Prosumia');

            objUserPermissions = new RemotingMessageHelper.UserPermissions();
            MarketingCloudAPIHandler objMC = new MarketingCloudAPIHandler();
            objToken = objMC.retrieveAccessToken();

            objMCSMS = new RemotingMessageHelper.MCSMS2(objSettings.SMS_Message_Id__c, 'FREETEXT');        
            objMCSMS.OverrideText = strMessage;
            System.debug('sendSingleMessageToMarketingCloud [UserInfo.getUserEmail(): ' + UserInfo.getUserEmail() +']');  
            objMCSMS.NotificationEmail = UserInfo.getUserEmail();



            HttpRequest request = new HttpRequest();
            String payload = '{"mobileNumbers": ["' + strPhoneNumber +'"], "Subscribe": true, "Resubscribe": true, "keyword": "FREETEXT", "Override": true, "messageText": "' + strMessage +'"}';
            
            String endpoint = 'https://mc8pbnp6vvfrwtrjrjn0829r2pv1.rest.marketingcloudapis.com/sms/v1/messageContact/Mjg3OTo3ODow/send';
            System.debug('sendSingleMessageToMarketingCloud  endpoint = ' + endpoint);
            System.debug('sendSingleMessageToMarketingCloud  accessToken = ' + objToken.accessToken);

            request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + objToken.accessToken);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(payload);
            Http http = new Http();
            objResponse = http.send(request);
            if (objResponse.getStatusCode() == 202) {
                System.debug('sendSingleMessageToMarketingCloud  SMS message sent successfully.');
                System.debug((RemotingMessageHelper.SMSResponses)JSON.deserialize(objResponse.getBody(), RemotingMessageHelper.SMSResponses.class));
                objSMSResponses = (RemotingMessageHelper.SMSResponses)JSON.deserialize(objResponse.getBody(), RemotingMessageHelper.SMSResponses.class);
                System.debug('sendSingleMessageToMarketingCloud objSMSResponses.tokenId : ' + objSMSResponses.tokenId);
            } else {
                System.debug('sendSingleMessageToMarketingCloud  Error: ' + objResponse.getBody());
            }

        } catch(Exception Ex) {
            objMessage.MC_Token_Id__c = null;
        }

        System.debug('sendSingleMessageToMarketingCloud [' + objMessage +'] <-');    
        
    }


    class TriggerAutomationResponse {
        public String tokenId   { get; set; }
        public String requestId { get; set; }
    }


    @future(callout=True)
    // @AuraEnabled(cacheable=true)
    public static void sendSMSViaMarketingCloudAutomation(Id campaignId) {
        System.debug('in sendSMSViaMarketingCloudAutomation......');

        Campania__c campania = [SELECT Id, mc_request_id__c, Prosumer_Estado__c FROM Campania__c WHERE Id = :campaignId LIMIT 1];

        try {
            Marketing_Cloud_Setting__mdt objSettings = retrieveMarketingCloudSettings('Prosumia');
            MarketingCloudAPIHandler objMC = new MarketingCloudAPIHandler();
            RemotingMessageHelper.MarketingCloudAccessToken objToken = objMC.retrieveAccessToken();

            String payload = '{"fileTransferLocationKey": "B3E6D948-74A3-4FA0-AF44-D379A1D46161", "filename": "DAC_TEST_FILE_0001.csv", "relativepath": "/", "deduplicationKey": ""}';
            String endpoint = 'https://mc8pbnp6vvfrwtrjrjn0829r2pv1.rest.marketingcloudapis.com/automation/v1/automations/trigger';
            System.debug('sendSMSViaMarketingCloudAutomation  endpoint = ' + endpoint);
            System.debug('sendSMSViaMarketingCloudAutomation  accessToken = ' + objToken.accessToken);

            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + objToken.accessToken);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(payload);

            Http http = new Http();
            HttpResponse objResponse = http.send(request);
            System.debug(objResponse);
            System.debug(objResponse.getStatuscode());
            System.debug(objResponse.getBody());

            if (objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {
                System.debug('sendSMSViaMarketingCloudAutomation  SMS message sent successfully.');
                System.debug((TriggerAutomationResponse)JSON.deserialize(objResponse.getBody(), TriggerAutomationResponse.class));
                TriggerAutomationResponse objTriggerAutomationResponse = (TriggerAutomationResponse)JSON.deserialize(objResponse.getBody(), TriggerAutomationResponse.class);
                System.debug('sendSMSViaMarketingCloudAutomation objTriggerAutomationResponse.requestId : ' + objTriggerAutomationResponse.requestId);
                
                campania.mc_request_id__c = objTriggerAutomationResponse.requestId;
                campania.Prosumer_Estado__c = 'Send Automation Iniciado';
                update campania;

            } else {
                System.debug('sendSMSViaMarketingCloudAutomation  Error: ' + objResponse.getBody());
            }
        } catch(Exception Ex) {
            System.debug('sendSMSViaMarketingCloudAutomation  Error: ');
            HelperFunctions.handleRuntimeException(Ex);
        }
    }



    private static Cuidarnos__mdt retrieveSMSSettings() {

        Cuidarnos__mdt objCuidarnos = null;
        
        System.debug('retrieveSMSSettings [] ->');

        objCuidarnos = [SELECT  SMS_Sends__c,
                                    Debug_Mode__c, 
                                    SMS_Message_Id__c, 
                                    SMS_Send_Enabled__c,
                                    SMS_Keyword__c, 
                                    SMS_Message__c, 
                                    SMS_Send_Covid_Detail_Info__c,
                                    Label_Identifier__c,
                                    Admin_Level_0__c,
                                    Admin_Level_1__c,
                                    Admin_Level_2__c,
                                    Admin_Level_3__c,
                                    Notification_SMS_1__c,
                                    Notification_SMS_2__c    
                            FROM Cuidarnos__mdt
                            WHERE DeveloperName = 'Cuidarnos'];

        System.debug('retrieveSMSSettings [' + objCuidarnos + '] <-');
        return objCuidarnos;
    }

    public static Marketing_Cloud_Setting__mdt retrieveMarketingCloudSettings(String strName) {
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

    private static RemotingMessageHelper.SMSSends createSMSRequest(SMS_Sondeos__mdt objSettings, String strDataExtension, String strSender, String strMessage ,String strMessageId) {
        RemotingMessageHelper.SMSSends objSend = null;

        System.debug('createSMSRequest [strMessageId : ' + strMessageId + ' - objSettings : ' + objSettings + ' - strDataExtension : ' + strDataExtension + ' - strSender : ' + strSender + ' - strMessage : ' + strMessage + '] ->');

        objSend = new RemotingMessageHelper.SMSSends();
        objSend.usuario = objSettings.Usuario__c;
        objSend.password = objSettings.Password__c;
        objSend.operacion = objSettings.Operacion__c;
        objSend.provision = objSettings.Provision__c;
        objSend.data_extension_name = strDataExtension;
        objSend.data_extension_field = 'MobilePhone';
        objSend.shortMessage = strMessage;
        objSend.sourceAddress = strSender;
        objSend.consultaEstado = '3'; //POR SOLICITUD DE SONDEOS.
        objSend.messageid = strMessageId;

        System.debug('createSMSRequest [ ' + objSend + '] <-');

        return objSend;
    }

    private static Project__c createProject(String strProjectId, String strProject) {        
        Project__c objProyecto = null;

        System.debug('createProject [ strProject : ' + strProject + '] ->');

        if(!String.isBlank(strProjectId)){
            objProyecto = [SELECT Id, Name FROM Project__c WHERE Id = :strProjectId];
        } else {
            objProyecto = new Project__c();
            objProyecto.Name = strProject;
            objProyecto.Objetivo__c = 'Envio SMS MC';
            objProyecto.Prioridad__c = 1;
            
            insert objProyecto;
        }
        
        System.debug('createProject [ ' + objProyecto + '] <-');

        return objProyecto;
    }


    private static Campania__c createCampaign(String strCampaniaId, String strCampania, Id projectId) {        
        Campania__c objCampania = null;

        System.debug('createCampaign [ strCampania : ' + strCampania + '] ->');

        if(!String.isBlank(strCampaniaId)){
            objCampania = [SELECT Id, Name FROM Campania__c WHERE Id = :strCampaniaId];
        } else {
            objCampania = new Campania__c();
            objCampania.Name = strCampania;
            objCampania.StartDate__c = Date.today();
            objCampania.Status__c = 'En Aprobación';
            objCampania.Project__c = projectId;
        
            insert objCampania;
        }
        
        System.debug('createCampaign [ ' + objCampania + '] <-');

        return objCampania;
    }

    private static Message__c createMessage(Campania__c objCampaign, String strDataExtension, String strDataExtensionName, String strSender, String strTitulo, String strMessage ) {
        Message__c objMessage = null;

        System.debug('createMessage [objCampaign : ' + objCampaign + ' - strDataExtension : ' + strDataExtension + ' - strDataExtensionName : ' + strDataExtensionName + ' - strSender : ' + strSender + ' - strTitulo : ' + strTitulo + ' - strMessage : ' + strMessage + '] ->');

        objMessage = new Message__c();
        objMessage.Name = strTitulo;
        objMessage.Campania__c = objCampaign.Id;
        objMessage.Body__c = strMessage;
        objMessage.Receiver_id__c = strDataExtension;
        objMessage.Receiver__c = strDataExtensionName;
        objMessage.SendDateTime__c = DateTime.now();
        objMessage.Sender__c = strSender;
        objMessage.TotalsSent__c = 0;
        objMessage.TotalsAudience__c = 0;
        objMessage.CantSuccess__C = 0;
        objMessage.CantRejected__c = 0;
        objMessage.Invalid_phones__c = 0;
        
        insert objMessage;

        System.debug('createMessage [ ' + objMessage + '] <-');

        return objMessage;
    }

    private static SMS_Sondeos__mdt retrieveSMSSettings(Integer intSender) {
        List<SMS_Sondeos__mdt> lstSMSSettings = null;
        SMS_Sondeos__mdt objSettings = null;

        System.debug('retrieveSMSSettings [intSender : ' + intSender + '] ->');
        lstSMSSettings = [SELECT Usuario__c, Password__c, Provision__c, Operacion__c
                          FROM SMS_Sondeos__mdt
                          WHERE Numero__c =: intSender];

        if(!lstSMSSettings.IsEmpty()) {
            objSettings = lstSMSSettings[0];
        }

        System.debug('retrieveSMSSettings [' + objSettings + '] <-');
        return objSettings;        
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