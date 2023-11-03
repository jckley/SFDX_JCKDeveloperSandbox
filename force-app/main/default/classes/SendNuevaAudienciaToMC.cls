public class SendNuevaAudienciaToMC implements Queueable, Database.AllowsCallouts {
    private String dataExtension;
    private String surveyId;
    private Set<User_Survey__c> surveyUsers;
    private List<String> fields;
    
    public SendNuevaAudienciaToMC(String dataExtension, String surveyId, Set<User_Survey__c> surveyUsers, List<String> fields) {
        this.dataExtension = dataExtension;
        this.surveyId = surveyId;
        this.surveyUsers = surveyUsers;
        this.fields = fields;
        System.debug('DAC: constructor SendNuevaAudienciaToMC for ' + this.dataExtension);
    }
    
    public void execute(QueueableContext context) {
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        RemotingMessageHelper.PulsoNuevaAudienciaWrapper objBody = null;
        
        System.debug('DAC: execute SendNuevaAudienciaToMC for ' + dataExtension);
        
        if(String.isNotBlank(dataExtension) && surveyUsers.size()>0) {
            objBody = new RemotingMessageHelper.PulsoNuevaAudienciaWrapper(dataExtension, surveyId, surveyUsers, fields);
            
            System.debug('DAC: (objBody) = ' + objBody);
            System.debug('DAC: (JSON Serialized objBody) = ' + JSON.serialize(objBody));
            
            objRequest = new HttpRequest();
            objRequest.setMethod('POST');
            objRequest.setEndpoint('callout:HerokuAPI/pulso_audiencia');
            objRequest.setHeader('content-type', 'application/json; charset=UTF-8');
            objRequest.setBody(JSON.serialize(objBody));

            objHttp = new Http();
            objResponse = objHttp.send(objRequest);

            if(objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {
                System.debug('BODY: ' + objResponse.getBody());
            } else {
                System.debug('BODY: ' + objResponse.getBody());
            }
        }
    }
}