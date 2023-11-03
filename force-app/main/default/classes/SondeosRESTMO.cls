@RestResource(urlMapping='/sondeos/mo/*')
global  class SondeosRESTMO {
    @HttpGet 
    global static String isAlive() {
        return 'isAlive!';
    }

    @HttpPost
    global static void updateResponse() {
        RemotingMessageHelper.SondeosMO objRequest = null;
        
        System.debug('updateResponse [RestContext.request.requestBody : ' + RestContext.request.requestBody + '] ->');
        
        if(RestContext.request.requestBody != NULL) {
            objRequest = (RemotingMessageHelper.SondeosMO) JSON.deserialize(RestContext.request.requestBody.toString(), RemotingMessageHelper.SondeosMO.class);
            System.debug('updateResponse [RestContext.request.requestBody.toString() : ' + RestContext.request.requestBody.toString() + ' ]');        
            System.debug('updateResponse [objRequest : ' + objRequest + ' ]');        


            if(objRequest != NULL && objRequest.parameters != NULL) {
                updateResponse(objRequest.parameters.origen, objRequest.parameters.origenRotativo, objRequest.parameters.destino, objRequest.parameters.telco, objRequest.parameters.fecha, objRequest.parameters.mensaje, objRequest.parameters.customerId);
            }
        } else {
            System.debug('updateResponse [REQUEST IS NULL]');        
        }

        System.debug('updateResponse [] <-');
    }

    global static void updateResponse(Long origen, Long origenRotativo, Long destino, String telco, String fecha, String mensaje, String customerId ) {
        RemotingMessageHelper.Sondeos objSondeos = null;
        SMS_Response__c objSMSResponse = null;
        Response__c objResponse = null;
        RestResponse objRESTResponse = null;
        RemotingMessageHelper.OperationResult objResult = null;

        System.debug('updateResponse[origen : ' + origen + ' - origenRotativo : ' + origenRotativo + ' - destino : ' + destino + ' - telco : ' + telco + ' - fecha : ' + fecha + ' - mensaje : ' + mensaje + ' - customerId : ' + customerId + ' ] ->');

        try {
            objResult = new RemotingMessageHelper.OperationResult();
            objRESTResponse = RestContext.response;

            objSMSResponse = new SMS_Response__c();
            objSMSResponse.origen__c = String.valueOf(origen);
            objSMSResponse.origenRotativo__c = String.valueOf(origenRotativo);
            objSMSResponse.destino__c = String.valueOf(destino);
            objSMSResponse.telco__c = telco;
            objSMSResponse.fecha__c = fecha;
            objSMSResponse.mensaje__c = mensaje;
            
            insert objSMSResponse;

            objResponse = new Response__c();
            objResponse.Message__c = customerId;
            objResponse.Response__c = mensaje;

            insert objResponse;

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

        System.debug('updateResponse [ statusCode : ' + objRESTResponse.statusCode + ' ]');
        System.debug('updateResponse [ responseBody : ' + objRESTResponse.responseBody + ' ]');
        System.debug('updateResponse [] <- ');

    }

    @HttpPut
    global static void updateStatistics(String strStatType, String strCampaingId, Integer intSends) {
        Message__c objMessage = null;
        RestResponse objRESTResponse = null;
        RemotingMessageHelper.OperationResult objResult = null;

        System.debug('updateStatistics[strStatType : ' + strStatType + ' - strCampaingId : ' + strCampaingId + ' - intSends : ' + intSends + ' ] ->');

        try {
            objResult = new RemotingMessageHelper.OperationResult();
            objRESTResponse = RestContext.response;

            objMessage = [SELECT TotalsSent__c FROM Message__c WHERE Id =: strCampaingId];
            objMessage.TotalsSent__c = intSends;

            update objMessage;

            objResult.Code = 0;
            objResult.Message = 'OK';

            objRESTResponse.statusCode = 200;
            objRESTResponse.responseBody = Blob.valueOf(JSON.serialize(objResult)); 
        } catch (Exception Ex) {
            objResult.Code = 999;
            objResult.Message = Ex.getMessage();

            objRESTResponse.statusCode = 500;
            objRESTResponse.responseBody = Blob.valueOf(JSON.serialize(objResult)); 

        }
        System.debug('updateStatistics[] <-');
    }
}