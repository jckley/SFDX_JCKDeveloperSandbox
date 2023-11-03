global class Facebook_UpdateFanPage_Info_Batch {}
/*
global class Facebook_UpdateFanPage_Info_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {  
    private String strQuery = null;
    private Survey_Setting__mdt objSurveySettings = null;
	private List<String> lstFieldsToRetrieve = null;
    private List<Facebook_Page__c> lstFacebookPageInfo = null;
            
    global Facebook_UpdateFanPage_Info_Batch() {
        objSurveySettings =  HelperFunctions.retrieveSurveySettings('Pulso_CRM');
       
        strQuery = 'SELECT Id, FacebookId__c FROM Facebook_Page__c';
        lstFieldsToRetrieve = retrieveFieldsToRetrieve(); 
        lstFacebookPageInfo =  new List<Facebook_Page__c>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext objBatchableContext) {
        Database.QueryLocator objQueryLocator = null;
        
        System.debug('start [ objBatchableContext : ' + objBatchableContext + '] ->');    
        
        objQueryLocator = Database.getQueryLocator(strQuery);            
        
        System.debug('start [' + objQueryLocator + '] <-');   
        return objQueryLocator;
    }
    
     global void execute(Database.BatchableContext objBatchableContext, List<Facebook_Page__c> lstFacebookPages) {                
         HttpRequest objRequest = null;
         Http objHttp = null;
         HttpResponse objResponse = null;
         RemotingMessageHelper.FacebookPageInfo objFacebookPageInfo = null;
         String strEndpoint = null;

         System.debug('execute [ objBatchableContext : ' + objBatchableContext + ' : lstFacebookPages : ' + lstFacebookPages + '] ->');  

         for(Facebook_Page__c objFacebookPage : lstFacebookPages) {                
             strEndpoint = String.format('{0}{1}?fields={2}&access_token={3}|{4}', new String[] { objSurveySettings.Facebook_Graph_Url__c, objFacebookPage.FacebookId__c.toPlainString(), String.join(lstFieldsToRetrieve, ','), objSurveySettings.Facebook_Graph_Client_Id__c, objSurveySettings.Facebook_Graph_Client_Secret__c } );
             objRequest = new HttpRequest();
             objRequest.setMethod('GET');
             objRequest.setEndpoint(strEndpoint);
             objRequest.setTimeout(60 * 1000);
 
             System.debug('execute [ strEndpoint : ' + strEndpoint + ']');  

             objHttp = new Http();
             objResponse = objHttp.send(objRequest);
              
             if(objResponse != NULL && objResponse.getStatusCode() == 200) {
                 try {
                     System.debug('execute [ page : ' + objResponse.getBody() + ']');  

                     objFacebookPageInfo = (RemotingMessageHelper.FacebookPageInfo)JSON.deserialize(objResponse.getBody(), RemotingMessageHelper.FacebookPageInfo.class);
                     lstFacebookPageInfo.add(objFacebookPageInfo.toFacebookPage()); 
                 } catch(Exception Ex) {
                     HelperFunctions.handleRuntimeException(Ex);
                 }                 
             } else {
                 System.debug('Ex : ' + objResponse.getBody());
             }             
         }
         
         if(lstFacebookPageInfo != NULL && !lstFacebookPageInfo.isEmpty()) {
             upsert lstFacebookPageInfo FacebookId__c;
         }

         System.debug('execute [] <-');  
    }  
    
    global void finish(Database.BatchableContext objBatchableContext) {        
        System.debug('finish [ objBatchableContext : ' + objBatchableContext + '] ->');  
                                    
        System.debug('finish [] <-');  
    }
    
    private List<String> retrieveFieldsToRetrieve() {
        List<String> lstFieldsToRetrieve = null;

        System.debug('retrieveFieldsToRetrieve [] ->');  
        
        lstFieldsToRetrieve = new List<String>();
        lstFieldsToRetrieve.add('name');
        lstFieldsToRetrieve.add('about');
        lstFieldsToRetrieve.add('category');
        lstFieldsToRetrieve.add('link');
        lstFieldsToRetrieve.add('picture');
        lstFieldsToRetrieve.add('fan_count');
        
        System.debug('retrieveFieldsToRetrieve [' + lstFieldsToRetrieve + '] <-');  

        return lstFieldsToRetrieve;
    }
}
*/