global class Typeform_PushCampaignMembers implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Id campid;
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'select id, campaign.blast_id__c, campaignid, contactid from campaignmember where campaignid = \'' + campid + '\'';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<campaignmember> cmlist) 
    {
        List<CampMemWrapper> cmwraplist = new List<CampMemWrapper>();
        for(CampaignMember cm : cmlist){
            cmwraplist.add(new CampMemWrapper(cm));
        }
		String jsonString = JSON.serialize(cmwraplist);
		system.debug('jsonString = ' + jsonString);
		
		Http m_http = new Http(); 
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://mailer.arg.to/api.push.members.php');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');        
        req.setMethod('POST');
        String strBody = jsonString;
        req.setBody(strBody);
        
        HttpResponse response;
        if(!Test.isRunningTest()){
           response = m_http.send(req);    
        }
        		
    }

    global void finish(Database.BatchableContext BC) {
        
    }
    
}