@RestResource(urlMapping='/sondeos/stats/*')
global class SondeosREST {
    @HttpGet 
    global static String isAlive() {
        return 'isAlive!';
    }

    @HttpPut
    global static void updateStats(String strStatType, String strMessageId, Integer intSends) {
        Campania__c objCampaign = null;
        List<Message__c> lstMessages = null;
        RestResponse objRESTResponse = null;
        RemotingMessageHelper.OperationResult objResult = null;
        List<Campania__c> lstCampaign = null;

        System.debug('updateStats [strStatType : ' + strStatType + ' - strMessageId : ' + strMessageId + ' - intSends : ' + intSends  + '] ->');
        try {
            objResult = new RemotingMessageHelper.OperationResult();
            objRESTResponse = RestContext.response;

            lstMessages = [ SELECT TotalsSent__c,TotalsAudience__c, Campania__c
                            FROM Message__c
                            WHERE Id =: strMessageId];

            lstCampaign = new List<Campania__c>();
            for(Message__c objMessage : lstMessages) {
                objMessage.TotalsSent__c = intSends;
                objMessage.TotalsAudience__c = intSends;
                
                objCampaign = new Campania__c();
                objCampaign.Id = objMessage.Campania__c;
                objCampaign.Status__c = 'FINALIZADA';
                lstCampaign.add(objCampaign);
            }

            update lstMessages;
            update lstCampaign;

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


        System.debug('updateStats [ statusCode : ' + objRESTResponse.statusCode + ' ]');
        System.debug('updateStats [ responseBody : ' + objRESTResponse.responseBody + ' ]');
        System.debug('updateStats [] <-');
    }
}