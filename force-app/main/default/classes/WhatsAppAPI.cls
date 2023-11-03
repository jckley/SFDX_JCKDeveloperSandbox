public class WhatsAppAPI {    
    public class AuthenticationExceptionException extends Exception {}
    /*
    public static void sendCustomMessage(List<RemotingMessageHelper.Subscriber> lstSubscribers) {
        RemotingMessageHelper.SMSRequest objSMSRequest = null;
        Set<String> setSubscribersKeys = null;
                
        System.debug('sendCustomMessage [lstSubscribers : ' + lstSubscribers + ' ] ->');
        
        if(lstSubscribers != NULL && !lstSubscribers.isEmpty()) {
            for(RemotingMessageHelper.Subscriber objSubscriber : lstSubscribers) {                    
                sendMessage(objSubscriber.MobileNumber, objSubscriber.Attributes.get('Message') );                
            }             
        } else {            
	        System.debug('sendCustomMessage [Subscribers cannot be null]');
        }
        
        System.debug('sendCustomMessage [] <-');        
    }
*/
    public static void sendCustomImage(List<RemotingMessageHelper.Subscriber> lstSubscribers) {
        RemotingMessageHelper.SMSRequest objSMSRequest = null;
        Set<String> setSubscribersKeys = null;
                
        System.debug('sendCustomMessage [lstSubscribers : ' + lstSubscribers + ' ] ->');
        
        if(lstSubscribers != NULL && !lstSubscribers.isEmpty()) {
            for(RemotingMessageHelper.Subscriber objSubscriber : lstSubscribers) {                    
                sendImage(objSubscriber.MobileNumber, objSubscriber.Attributes.get('ImageUrl') );   
                sendMessage(objSubscriber.MobileNumber, objSubscriber.Attributes.get('Message')  );                                
            }             
        } else {            
	        System.debug('sendCustomMessage [Subscribers cannot be null]');
        }
        
        System.debug('sendCustomMessage [] <-');        
    }
    
    public static void sendMessages(List<RemotingMessageHelper.Subscriber> lstSubscribers) {
        RemotingMessageHelper.SMSRequest objSMSRequest = null;
        Set<String> setSubscribersKeys = null;
        String strMethod = null;
        String strEndpoint = null;
        String strBody = null;
        Map<String, String> mapHeader = null;
                
        System.debug('sendMessages [lstSubscribers : ' + lstSubscribers + ' ] ->');
        
        if(lstSubscribers != NULL && !lstSubscribers.isEmpty()) {
            for(RemotingMessageHelper.Subscriber objSubscriber : lstSubscribers) {                    
                sendMessage(objSubscriber.MobileNumber, String.format('Hola {0}, detectamos que ha twiteado desde la cuenta {1} el siguiente mensaje: {2}', new String[] {objSubscriber.Attributes.get('Nombre'), objSubscriber.Attributes.get('twitterHandle'), objSubscriber.Attributes.get('Tema')} ));                
            }             
        } else {            
	        System.debug('sendMessages [Subscribers cannot be null]');
        }
        
        System.debug('sendMessages [] <-');
    }
    @future(callout=true)
    public static void sendMessage(String strTo, String strMessage) {
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        List<WhatsAPPAPI__mdt> lstWhatsApp = null;
        WhatsAPPAPI__mdt objWhatsApp = null;
        RemotingMessageHelper.WhatsAppMessage objMessage = null;
        String strEndPoint = null;
        String strUUID = null;
        
        System.debug('sendMessage [ strTo : ' + strTo + ' - strMessage : ' + strMessage + '] ->');
        
        if(String.isNotBlank(strTo) && String.isNotBlank(strMessage) ) {
            lstWhatsApp = [SELECT Id, Sender__c, Token__c 
                           FROM WhatsAPPAPI__mdt 
                           LIMIT 1];
            
            if(!lstWhatsApp.isEmpty()) {
                objWhatsApp = lstWhatsApp[0];
                System.debug('sendMessage [ objWhatsApp : ' + objWhatsApp + ']');
                
                if(objWhatsApp == NULL || objWhatsApp.Sender__c == NULL || String.isNotBlank(objWhatsApp.Token__c)) {
                    strEndPoint = String.format('callout:WhatsAppAPI/sendMessage?token={0}', new String[] { objWhatsApp.Token__c , String.valueOf(objWhatsApp.Sender__c)});
                    System.debug('sendMessage [ strEndPoint : ' + strEndPoint + ']');

                    objMessage = new RemotingMessageHelper.WhatsAppMessage();
                    objMessage.body = strMessage;
                    objMessage.phone = strTo;
                    
                    objRequest = new HttpRequest();
                    objRequest.setMethod('POST');
                    objRequest.setHeader('Content-Type', 'application/json');
                    objRequest.setEndpoint(strEndPoint);
                    objRequest.setBody(JSON.serializePretty(objMessage, true));
                    
                    System.debug('sendMessage [ Body : ' + objRequest.getBody() + ']');
                    
                    objHttp = new Http();               
                    objResponse = objHttp.send(objRequest);
                    
                    System.debug('sendMessage [ Code : ' + objResponse.getStatusCode() + ']');
                    System.debug('sendMessage [ Body : ' + objResponse.getBody() + ']');
                    
                    if (objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {            

                    } else {
                        throw new AuthenticationExceptionException('Error en el envio');
                    }
                } else {
                    throw new AuthenticationExceptionException('Empty parameters');
                }
            }
        }
    }
    
    
    @future(callout=true)
    public static void sendImage(String strTo, String strImageUrl) {
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        List<WhatsAPPAPI__mdt> lstWhatsApp = null;
        WhatsAPPAPI__mdt objWhatsApp = null;
        RemotingMessageHelper.WhatsAppMessage objMessage = null;
        String strEndPoint = null;
        String strUUID = null;
        
        System.debug('sendMessage [ strTo : ' + strTo + ' - strMessage : ' + strImageUrl + '] ->');
        
        if(String.isNotBlank(strTo) && String.isNotBlank(strImageUrl) ) {
            lstWhatsApp = [SELECT Id, Sender__c, Token__c 
                           FROM WhatsAPPAPI__mdt 
                           LIMIT 1];
            
            if(!lstWhatsApp.isEmpty()) {
                objWhatsApp = lstWhatsApp[0];
                System.debug('sendMessage [ objWhatsApp : ' + objWhatsApp + ']');
                
                if(objWhatsApp == NULL || objWhatsApp.Sender__c == NULL || String.isNotBlank(objWhatsApp.Token__c)) {
                    strEndPoint = String.format('callout:WhatsAppAPI/sendFile?token={0}', new String[] { objWhatsApp.Token__c , String.valueOf(objWhatsApp.Sender__c)});
                    System.debug('sendMessage [ strEndPoint : ' + strEndPoint + ']');

                    objMessage = new RemotingMessageHelper.WhatsAppMessage();
                    objMessage.fileName = 'todosJuntos.jpg';
                    objMessage.phone = strTo;
                    objMessage.body = strImageUrl;
        
                    objRequest = new HttpRequest();
                    objRequest.setMethod('POST');
                    objRequest.setHeader('Content-Type', 'application/json');
                    objRequest.setEndpoint(strEndPoint);
                    objRequest.setBody(JSON.serializePretty(objMessage, true));
                    
                    System.debug('sendMessage [ Body : ' + objRequest.getBody() + ']');
                    
                    objHttp = new Http();               
                    objResponse = objHttp.send(objRequest);
                    
                    System.debug('sendMessage [ Code : ' + objResponse.getStatusCode() + ']');
                    System.debug('sendMessage [ Body : ' + objResponse.getBody() + ']');
                    
                    if (objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {            

                    } else {
                        throw new AuthenticationExceptionException('Error en el envio');
                    }
                } else {
                    throw new AuthenticationExceptionException('Empty parameters');
                }
            }
        }
    }
    /*
    private static String generateUUID() {
        Blob objKey = NULL;
        String objKeyHex = NULL;
        String strUUID = NULL;
        
        objKey = Crypto.GenerateAESKey(128);
        objKeyHex = EncodingUtil.ConvertTohex(objKey);
        strUUID = objKeyHex.SubString(0,8)+ '-' + objKeyHex.SubString(8,12) + '-' + objKeyHex.SubString(12,16) + '-' + objKeyHex.SubString(16,20) + '-' + objKeyHex.substring(20);
        
        return strUUID;
    } */                          
}