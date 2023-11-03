@RestResource(urlMapping='/sondeos/dr/*')
global class SondeosRESTDR {
    @HttpGet 
    global static String isAlive() {
        return 'isAlive!';
    }

    @HttpPost
    global static void saveDeliveryReport() {
        RemotingMessageHelper.SondeosDR objRequest = null;
        
        System.debug('saveDeliveryReport [RestContext.request.requestBody : ' + RestContext.request.requestBody + '] ->');
        
        if(RestContext.request.requestBody != NULL) {
            objRequest = (RemotingMessageHelper.SondeosDR) JSON.deserialize(RestContext.request.requestBody.toString(), RemotingMessageHelper.SondeosDR.class);
            if(objRequest != NULL && objRequest.parameters != NULL) {
                saveDeliveryReport(objRequest.parameters.origen, objRequest.parameters.origenRotativo, objRequest.parameters.destino, objRequest.parameters.id_mensaje, objRequest.parameters.celco, objRequest.parameters.estado, objRequest.parameters.customerId);
            }
        } else {
            System.debug('saveDeliveryReport [REQUEST IS NULL]');        
        }

        System.debug('saveDeliveryReport [] <-');
    }

    global static void saveDeliveryReport(Long origen, Long origenRotativo, Long destino, String id_mensaje , String celco, Integer estado, String customerId) {
        SMS_Delivery_Report__c objResponse = null;    
        RestResponse objRESTResponse = null;
        RemotingMessageHelper.OperationResult objResult = null;

        System.debug('saveDeliveryReport [ origen : ' + origen + ' - origenRotativo : ' + origenRotativo + ' - destino : ' + destino + ' - id_mensaje : ' + id_mensaje + ' - celco : ' + celco + ' - estado : ' + estado + ' - customerId : ' + customerId + ' ] -> ');

        try {
            objResult = new RemotingMessageHelper.OperationResult();
            objRESTResponse = RestContext.response;

            objResponse = new SMS_Delivery_Report__c();
            objResponse.celco__c = celco;
            objResponse.customerId__c = customerId;
            objResponse.destino__c = String.valueOf(destino);
            objResponse.estado__c = String.valueOf(estado);
            objResponse.id_mensaje__c = id_mensaje;
            objResponse.origen__c = String.valueOf(origen);
            objResponse.origenRotativo__c = String.valueOf(origenRotativo);

            insert objResponse;

            updateMessageStats(customerId, destino, estado);

            objResult.Code = 0;
            objResult.Message = 'OK';

            objRESTResponse.statusCode = 200;
            objRESTResponse.responseBody = Blob.valueOf(JSON.serialize(objResult));                
        } catch(Exception Ex) {
            objResult.Code = 999;
            objResult.Message = Ex.getMessage();

            objRESTResponse.statusCode = 500;
            objRESTResponse.responseBody = Blob.valueOf(JSON.serialize(objResult));                
        }

        System.debug('saveDeliveryReport [ statusCode : ' + objRESTResponse.statusCode + ' ]');
        System.debug('saveDeliveryReport [ responseBody : ' + objRESTResponse.responseBody + ' ]');
        System.debug('saveDeliveryReport [] <- ');
    }
	
    private static void updateMessageStats(String strMessageId, Long lngDestino, Integer intEstado) {
        List<Message__c> lstMessages = null;

        System.debug('updateMessageStats [strMessageId : ' + strMessageId + ' - intEstado : ' + intEstado + '] -> ');

        lstMessages = [  SELECT Id ,CantSuccess__c, CantRejected__c 
                        FROM Message__c
                        WHERE Id =: strMessageId];

        for(Message__c objMessage : lstMessages) {
            if(intEstado == 1) {
                if(objMessage.CantRejected__c != NULL) {
                    objMessage.CantRejected__c = objMessage.CantRejected__c + 1;
                } else {
                    objMessage.CantRejected__c = 1;
                }
            } else if(intEstado == 2) {
                if(objMessage.CantSuccess__c != NULL) {
                    objMessage.CantSuccess__c = objMessage.CantSuccess__c + 1;
                } else {
                    objMessage.CantSuccess__c = 1;
                }
            }  

            sendStatusINAWS(strMessageId, lngDestino, intEstado);
        }

        update lstMessages;

        System.debug('updateMessageStats [] <- ');
    }

    @future(callout=True)
    private static void sendStatusINAWS(String strMessageId, Long destino, Integer estado) {
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        String strBody = null;
        String strEndpoint = null;
        String strResponse = null;

        System.debug('sendStatusINAWS [ strMessageId : ' + strMessageId + ' - destino : ' + destino + ' - estado : ' + estado + '] ->');

        strEndpoint = 'https://api-pulso.prosumia.la/aws-api/sondeos/sync';
        strBody = '{ "messageid" : "' +  strMessageId + '" , "destino"  : ' +  destino + ' , "estado" : ' +  estado + ' }';

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
        System.debug('sendStatusINAWS [' + strResponse + '] <-');
    }

}