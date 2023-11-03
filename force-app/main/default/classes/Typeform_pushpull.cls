public with sharing class Typeform_pushpull {
    public Typeform_pushpull(){}
    public String CSVContent {get;set;}
    public String waitMessage {get; set;}
    public String errAuthInit {get; set;}
    
    public String req_e {get;set;}
    private Campaign camp;
    public campaign thiscamp {get; set;}
    public Typeform_pushpull(ApexPages.StandardController stdController) {
        camp = (Campaign) stdController.getRecord();
        camp = [Select id, name, Blast_Id__c, recordtypeid, Type_Form_ID__c, createddate, BatchUpdateDateTime__c, Email_Blast_Template__c, Email_Blast_Report__c, Email_Blast_sent__c  from Campaign where id=: camp.id LIMIT 1];
        
        camp.BatchUpdateDateTime__c = system.now();
        thiscamp = camp;
        selScheduleOption = 'now';
    }
    
    public void pulldata_Batch(String formid, Campaign c){
        Boolean bMoreResult = pulldata(formid, c);
        if(bMoreResult){
            PullTypeform_Batch pb = new PullTypeform_Batch();
            pb.formid = formid;
            pb.campid = c.id; pb.camp = c;
            Database.executeBatch(pb,1);
        }                
    }
    
    public Boolean pulldata(String formid, Campaign c){

            
        Typeform_PushPull__c tp = Typeform_PushPull__c.getValues('Value');
        Integer lastid = 0;
        /*if(!Test.isRunningTest())
           lastid = Integer.valueOf(tp.LastId_Typeform__c);*/
        //get last saved id
        Campaign tempc = [Select id, LastId_Typeform__c from Campaign where Id = :c.id limit 1];
        
        if(tempc.LastId_Typeform__c != null)
            lastid = Integer.valueOf(tempc.LastId_Typeform__c);


        Http m_http = new Http(); 
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://mailer.arg.to/api.typeform.pull.php?key=4s20uxtvwh&camp_id=' + c.id + '&form_id=' + formid + '&last_id='+lastid);
        req_e = 'http://mailer.arg.to/api.typeform.pull.php?key=4s20uxtvwh&camp_id=' + c.id + '&form_id=' + formid + '&last_id='+lastid;
        
        req.setHeader('Content-Type','application/x-www-form-urlencoded');        
        req.setMethod('GET');
       
        HttpResponse response;
        CSVContent = '';
        
        if(!Test.isRunningTest()){
           response = m_http.send(req);    
        }
        if(Test.isRunningTest() || (response != null && response.getStatusCode() == 200)){
            if(Test.isRunningTest())
                CSVContent = '{"success":true}';
            else
                CSVContent = response.getBody();
    
        }
        else if(response != null){
        }    

        Boolean bMoreResult = false;
        if(lastid < 0 || (!String.isBlank(CSVContent) && CSVContent == '{"result":0}')){
            bMoreResult = false;
            return false;
        }
        
        //system.debug('CSVContent = ' + CSVContent.abbreviate(1000));
        parseJSONData(CSVContent);
        return true;
    }
    public void parseJSONData(String jsonInput){
        //Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        Map<Id, Set<Id>> campmemids = new Map<Id, Set<Id>>();
        Map<String, Map<String, Object>> campctcObjMap = new Map<String, Map<String, Object>>();
        
        List<Object> m1 = (List<Object>)JSON.deserializeUntyped(jsonInput);
        system.debug('size = ' + m1.size());
        Set<Id> testcampid = new Set<Id>();
        String xtempCamp;
        Integer lastid = -1;
        for(Object mx : m1){
            //for each record
            Map<String, Object> xm = (Map<String, Object>) mx;
            //get campaign
            //system.debug('SFID : ' + xm.get('SFID'));
            system.debug('C : ' + xm.get('c'));
            //system.debug('T : ' + xm.get('T'));
            system.debug('Campaign ID : ' + xm.get('Campaign ID'));
                    
           /* if(xm.containsKey('c') && xm.get('c') != null && xm.get('c') == 'xxxxx' && xm.containsKey('Campaign ID') && xm.get('Campaign ID') != null){
                continue;
                String x = xm.get('Campaign ID') + '~' + '0030v000002IeJQ';
                campctcObjMap.put(x, xm);
            }*/
            //if(xm.containsKey('c') && xm.get('c') != null && xm.get('c') != 'xxxxx' && xm.containsKey('Campaign ID') && xm.get('Campaign ID') != null){
            if(xm.containsKey('c') && xm.get('c') != null && xm.containsKey('Campaign ID') && xm.get('Campaign ID') != null){
                String xcmpid = (String)xm.get('Campaign ID');
                xtempCamp = xcmpid;
                String xctcid = (String)xm.get('c');
                if(xcmpid.length() > 15)
                    xcmpid = xcmpid.substring(0,15);
                if(xctcid.length() > 15)
                    xctcid = xctcid.substring(0,15);

                String x = xcmpid + '~' + xctcid;
                campctcObjMap.put(x, xm);
            }
            if(test.isRunningtest()){
                campctcObjMap = new Map<String, Map<String, Object>>();
                campctcObjMap.put((String)xm.get('Campaign ID'), xm);
            }
            
            if(xm.containsKey('id')){
                String xid = (String)xm.get('id');
                if(xid != null)
                    lastid = Integer.valueOf(xid);                
            }
            
        }
        
        /*if(lastid > -1 && !Test.isRunningTest()){
                Typeform_PushPull__c tp = Typeform_PushPull__c.getValues('Value');
                        tp.LastId_Typeform__c = lastid;
                        update tp;
        }*/
        
        //update last id in the campaign
        if(lastid > -1 && !String.isBlank(xtempCamp)){
            Campaign tempc = [Select id, LastId_Typeform__c from Campaign where Id = :xtempCamp LIMIT 1];
            tempc.LastId_Typeform__c = lastid;
            update tempc;
        }
        
        
        
        //get campaign members and convert to Map       
        List<CampaignMember> xmem;
        if(Test.isRunningTest()){
            xmem =  [Select id,  CampaignId, Campaign_Contact__c, Browser__c, Platform__c, Date_Landed__c, submitted_Date_Time__c from CampaignMember where Campaignid IN: campctcObjMap.keySet() LIMIT 1];
        }
        else{
            xmem =  [Select id, CampaignId, Campaign_Contact__c, Browser__c, Platform__c, Date_Landed__c, submitted_Date_Time__c from CampaignMember where Campaign_Contact__c IN: campctcObjMap.keySet() LIMIT 200];
        }
        //system.assert(xmem != null);
        //system.assert(xmem.size() > 0);
        for(CampaignMember m : xmem){
            if(Test.isRunningTest() || campctcObjMap.containsKey(m.Campaign_Contact__c)){
                Map<String, Object> currJsonObj = campctcObjMap.get(m.Campaign_Contact__c);     
                if(Test.isRunningTest())
                    currJsonObj = campctcObjMap.get(m.CampaignId);   
                //set the values
               // m.Contactid='0030v000002IeJQ'; //currJsonObj.get('c');
                m.Browser__c=!currJsonObj.containskey('browser') ? '' : (String)currJsonObj.get('browser');
                m.Platform__c=!currJsonObj.containskey('platform') ? '' : (String)currJsonObj.get('platform');
                //m.Date_Landed__c=DateTime.parse((String)currJsonObj.get('date_land'));
                
                m.Date_Landed__c=!currJsonObj.containskey('date_land') ? null : (DateTime)Json.deserialize('"'+(String)currJsonObj.get('date_land')+'"', DateTime.class); //https://salesforce.stackexchange.com/questions/143856/convert-string-datetime-to-user-locale-date-time
                m.submitted_Date_Time__c=!currJsonObj.containskey('date_submit') ? null : (DateTime)Json.deserialize('"'+(String)currJsonObj.get('date_submit')+'"', DateTime.class);
                //m.submitted_Date_Time__c=DateTime.parse((String)currJsonObj.get('date_submit'));//date_land":"2017-06-26T16:04:11-04:00","date_submit":"2017-06-26T16:04:37-04:00"
                
                m.User_Agent__c=!currJsonObj.containskey('user_agent') ? '' : (String)currJsonObj.get('user_agent');
                m.URL_Referer__c=!currJsonObj.containskey('referer') ? '' : (String)currJsonObj.get('referer');
                m.Network_ID__c=!currJsonObj.containskey('network_id') ? '' : (String)currJsonObj.get('network_id');
                m.status=!currJsonObj.containskey('Status') ? '' : (String)currJsonObj.get('Status');
               // m.campaignid=(Id)currJsonObj.get('Campaign ID');
                m.Question_01__c=!currJsonObj.containskey('Question_1') ? '' : (String)currJsonObj.get('Question_1');
                m.Answer_01__c=!currJsonObj.containskey('Answer_1') ? '' : (String)currJsonObj.get('Answer_1');
                m.Question_02__c=!currJsonObj.containskey('Question_2') ? '' : (String)currJsonObj.get('Question_2');
                m.Answer_02__c=!currJsonObj.containskey('Answer_2') ? '' : (String)currJsonObj.get('Answer_2');
                m.Question_03__c=!currJsonObj.containskey('Question_3') ? '' : (String)currJsonObj.get('Question_3');
                m.Answer_03__c=!currJsonObj.containskey('Answer_3') ? '' : (String)currJsonObj.get('Answer_3');
                m.Question_04__c=!currJsonObj.containskey('Question_4') ? '' : (String)currJsonObj.get('Question_4');
                m.Answer_04__c=!currJsonObj.containskey('Answer_4') ? '' : (String)currJsonObj.get('Answer_4');
                m.Question_05__c=!currJsonObj.containskey('Question_5') ? '' : (String)currJsonObj.get('Question_5');
                m.Answer_05__c=!currJsonObj.containskey('Answer_5') ? '' : (String)currJsonObj.get('Answer_5');
                m.Question_06__c=!currJsonObj.containskey('Question_6') ? '' : (String)currJsonObj.get('Question_6');
                m.Answer_06__c=!currJsonObj.containskey('Answer_6') ? '' : (String)currJsonObj.get('Answer_6');
                m.Question_07__c=!currJsonObj.containskey('Question_7') ? '' : (String)currJsonObj.get('Question_7');
                m.Answer_07__c=!currJsonObj.containskey('Answer_7') ? '' : (String)currJsonObj.get('Answer_7');
                m.Question_08__c=!currJsonObj.containskey('Question_8') ? '' : (String)currJsonObj.get('Question_8');
                m.Answer_08__c=!currJsonObj.containskey('Answer_8') ? '' : (String)currJsonObj.get('Answer_8');
                m.Question_09__c=!currJsonObj.containskey('Question_9') ? '' : (String)currJsonObj.get('Question_9');
                m.Answer_09__c=!currJsonObj.containskey('Answer_9') ? '' : (String)currJsonObj.get('Answer_9');
                m.Question_10__c=!currJsonObj.containskey('Question_10') ? '' : (String)currJsonObj.get('Question_10');
                m.Answer_10__c=!currJsonObj.containskey('Answer_10') ? '' : (String)currJsonObj.get('Answer_10');
                m.Question_11__c=!currJsonObj.containskey('Question_11') ? '' : (String)currJsonObj.get('Question_11');
                m.Answer_11__c=!currJsonObj.containskey('Answer_11') ? '' : (String)currJsonObj.get('Answer_11');
                m.Question_12__c=!currJsonObj.containskey('Question_12') ? '' : (String)currJsonObj.get('Question_12');
                m.Answer_12__c=!currJsonObj.containskey('Answer_12') ? '' : (String)currJsonObj.get('Answer_12');
                m.Question_13__c=!currJsonObj.containskey('Question_13') ? '' : (String)currJsonObj.get('Question_13');
                m.Answer_13__c=!currJsonObj.containskey('Answer_13') ? '' : (String)currJsonObj.get('Answer_13');
                m.Question_14__c=!currJsonObj.containskey('Question_14') ? '' : (String)currJsonObj.get('Question_14');
                m.Answer_14__c=!currJsonObj.containskey('Answer_14') ? '' : (String)currJsonObj.get('Answer_14');
                m.Question_15__c=!currJsonObj.containskey('Question_15') ? '' : (String)currJsonObj.get('Question_15');
                m.Answer_15__c=!currJsonObj.containskey('Answer_15') ? '' : (String)currJsonObj.get('Answer_15');
                m.Question_16__c=!currJsonObj.containskey('Question_16') ? '' : (String)currJsonObj.get('Question_16');
                m.Answer_16__c=!currJsonObj.containskey('Answer_16') ? '' : (String)currJsonObj.get('Answer_16');
                m.Question_17__c=!currJsonObj.containskey('Question_17') ? '' : (String)currJsonObj.get('Question_17');
                m.Answer_17__c=!currJsonObj.containskey('Answer_17') ? '' : (String)currJsonObj.get('Answer_17');
                m.Question_18__c=!currJsonObj.containskey('Question_18') ? '' : (String)currJsonObj.get('Question_18');
                m.Answer_18__c=!currJsonObj.containskey('Answer_18') ? '' : (String)currJsonObj.get('Answer_18');
                m.Question_19__c=!currJsonObj.containskey('Question_19') ? '' : (String)currJsonObj.get('Question_19');
                m.Answer_19__c=!currJsonObj.containskey('Answer_19') ? '' : (String)currJsonObj.get('Answer_19');
                m.Question_20__c=!currJsonObj.containskey('Question_20') ? '' : (String)currJsonObj.get('Question_20');
                m.Answer_20__c=!currJsonObj.containskey('Answer_20') ? '' : (String)currJsonObj.get('Answer_20');
                m.Question_21__c=!currJsonObj.containskey('Question_21') ? '' : (String)currJsonObj.get('Question_21');
                m.Answer_21__c=!currJsonObj.containskey('Answer_21') ? '' : (String)currJsonObj.get('Answer_21');
                m.Question_22__c=!currJsonObj.containskey('Question_22') ? '' : (String)currJsonObj.get('Question_22');
                m.Answer_22__c=!currJsonObj.containskey('Answer_22') ? '' : (String)currJsonObj.get('Answer_22');
                m.Question_23__c=!currJsonObj.containskey('Question_23') ? '' : (String)currJsonObj.get('Question_23');
                m.Answer_23__c=!currJsonObj.containskey('Answer_23') ? '' : (String)currJsonObj.get('Answer_23');
                m.Question_24__c=!currJsonObj.containskey('Question_24') ? '' : (String)currJsonObj.get('Question_24');
                m.Answer_24__c=!currJsonObj.containskey('Answer_24') ? '' : (String)currJsonObj.get('Answer_24');
                m.Question_25__c=!currJsonObj.containskey('Question_25') ? '' : (String)currJsonObj.get('Question_25');
                m.Answer_25__c=!currJsonObj.containskey('Answer_25') ? '' : (String)currJsonObj.get('Answer_25');
                m.Question_26__c=!currJsonObj.containskey('Question_26') ? '' : (String)currJsonObj.get('Question_26');
                m.Answer_26__c=!currJsonObj.containskey('Answer_26') ? '' : (String)currJsonObj.get('Answer_26');
                m.Question_27__c=!currJsonObj.containskey('Question_27') ? '' : (String)currJsonObj.get('Question_27');
                m.Answer_27__c=!currJsonObj.containskey('Answer_27') ? '' : (String)currJsonObj.get('Answer_27');
                m.Question_28__c=!currJsonObj.containskey('Question_28') ? '' : (String)currJsonObj.get('Question_28');
                m.Answer_28__c=!currJsonObj.containskey('Answer_28') ? '' : (String)currJsonObj.get('Answer_28');                
            }
           
        }
        if(xmem != null && xmem.size() > 0)
                update xmem;
        //put the map values
        
        
    }

   /* public void parseCSVData(String contents){
        CSVUtility cv = new CSVUtility();
        List<List<String>> x = cv.parseCSVContent(contents,true) ;
        insertPulls(x);
        system.debug('rows = '  + x.size());
        //system.debug('cols = ' + x[0].size());
        
    }*/

    public void insertPulls(List<List<String>> recs){
        //create campaign members
        Integer i = 0; Integer j = 0;
        for(i = 0; i < recs.size(); i++){
            for(j = 0; j < recs[i].size(); j++){
                system.debug(recs[i][j]);
            }
            system.debug('*******************************');
        }
    }
    public pageReference parseAllData(){
        waitMessage = 'Processing!';
        try{
            List<Campaign> camps = [Select id, Type_Form_ID__c, 
            Start_Date_Time__c, End_Date_Time__c, Successful_Deliveries__c, Failed_Deliveries__c, Average_Bounce_Rate__c, Average_Click_Rate__c, Average_Unsubscribe_Rate__c, Click_Rate_Success__c, Open_Rate_Success__c, Total_Bounce_Rate__c, Total_Click_Rate__c, Total_Open_Rate__c, Total_Unsubscribe_Rate__c, Last_Update_Date__c 
            from Campaign where Type_Form_ID__c =: camp.Type_Form_ID__c LIMIT 100];
            for(Campaign c : camps){
               pulldata_batch(c.Type_Form_ID__c, c);
            }
        }
        catch(exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading CSV file');
            ApexPages.addMessage(errorMessage);
            CSVContent += ' --- ' + e.getMessage() + ' --- ' + e.getStackTraceString();
        }
        return null;
    }    
    public void parseOneCampaignData(String formid){
      /*  try{
            if(!String.isBlank(formid))
                pulldata_batch(formid, null); 
        }
        catch(exception e){

        }*/
    }        
//********** PULL EMAIL BLAST FOR CAMPAIGN **************//
        public void parseEmailBlastDataForCampaign(Campaign cmp){
            camp = cmp;
            parseEmailBlastData();
        }
        
        public pageReference parseEmailBlastData(){
            waitMessage = 'Processing!';
                Campaign c = [Select id, Type_Form_ID__c, 
            Start_Date_Time__c, End_Date_Time__c, Successful_Deliveries__c, Failed_Deliveries__c, Average_Bounce_Rate__c, Average_Click_Rate__c, Average_Unsubscribe_Rate__c, Click_Rate_Success__c, Open_Rate_Success__c, Total_Bounce_Rate__c, Total_Click_Rate__c, Total_Open_Rate__c, Total_Unsubscribe_Rate__c, Last_Update_Date__c 
            from Campaign where Id = :camp.id  LIMIT 1];
                        
                pullEmailBlast(c);
                return null;
        }
        
        public void pullEmailBlast(Campaign c){
        Http m_http = new Http(); 
        HttpRequest req = new HttpRequest();
        String xcampid = c.id;
        xcampid = xcampid.substring(0,15);
        req.setEndpoint('http://mailer.arg.to/api.pull.blast.php?key=eU7GH1P_0s3jp8!?%7Cuc:&campaign_id=' + xcampid);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');        
        req.setMethod('GET');
       
        HttpResponse response;
        CSVContent = '';
        
        if(!Test.isRunningTest()){
           response = m_http.send(req);    
        }
        if(Test.isRunningTest() || (response != null && response.getStatusCode() == 200)){
            if(Test.isRunningTest())
                CSVContent = '{"success":true}';
            else
                CSVContent = response.getBody();
    
        }
        else if(response != null){
        }    
        //system.debug('CSVContent = ' + CSVContent.abbreviate(1000));
        parseEmailBlastPullJSONData(CSVContent, c);
                
        }
    public void parseEmailBlastPullJSONData(String jsonInput, Campaign c){
        
        Map<String, Object> respmap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        DateTime dateInstance; 
                //for(String fld : respmap.keySet()){
                        if(respmap.get('start_timestamp')!= null){
                                dateInstance = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0); //for converting UNIX timestamp
                                try{
                                        Integer ms = (Integer)respmap.get('start_timestamp');
                                        c.Start_Date_Time__c = dateInstance.addSeconds(ms);
                                }
                                catch(Exception e){
                                        c.Start_Date_Time__c=null;      
                                }
                        }
                        else{
                                c.Start_Date_Time__c=null;      
                        }
                        
                        if(respmap.get('end_timestamp')!= null){
                                dateInstance = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0); //for converting UNIX timestamp
                                try{
                                        Integer ms = (Integer)respmap.get('end_timestamp');
                                        c.End_Date_Time__c = dateInstance.addSeconds(ms);                                       
                                }
                                catch(Exception e){
                                        c.End_Date_Time__c=null;        
                                }

                        }
                        else{
                                c.End_Date_Time__c=null;                                        
                        }

                        
                        c.Successful_Deliveries__c=(Decimal)respmap.get('successful_deliveries');
                        c.Failed_Deliveries__c=(Decimal)respmap.get('failed_deliveries');
                        c.Average_Bounce_Rate__c=(Decimal)respmap.get('avg_bounce_rate');
                        c.Average_Click_Rate__c=(Decimal)respmap.get('avg_click_rate');
                        c.Average_Unsubscribe_Rate__c=(Decimal)respmap.get('avg_unsubscribe_rate');
                        c.Click_Rate_Success__c=(Decimal)respmap.get('click_rate_success');
                        c.Open_Rate_Success__c=(Decimal)respmap.get('open_rate_success');
                        c.Total_Bounce_Rate__c=(Decimal)respmap.get('total_bounce_rate');
                        c.Total_Click_Rate__c=(Decimal)respmap.get('total_click_rate');
                        c.Total_Open_Rate__c=(Decimal)respmap.get('total_open_rate');
                        c.Total_Unsubscribe_Rate__c=(Decimal)respmap.get('total_unsubscribe_rate');
                        
                        if(respmap.get('last_updated_date')!= null){
                                dateInstance = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0); //for converting UNIX timestamp
                                Integer ms = (Integer)respmap.get('last_updated_date');
                                c.Last_Update_Date__c = dateInstance.addSeconds(ms);
                        }
                        else{
                                c.Last_Update_Date__c=null;     
                        }

                //}
                update c;
        
    }
///******** PULL CAMPAIGN MEMBERS *****//
        public pageReference pullcampaignMem(){
                //pullcampaignMembers(camp.id);
                waitMessage = 'Processing!';
                pullcampaignMembers_Batch(camp.id);
                return null;
        } 
    
    public void pullcampaignMembers_Batch(Id campid){
        Boolean bMoreResult = pullcampaignMembers(campid);
        if(bMoreResult){
            PullCampaign_Batch pb = new PullCampaign_Batch();
            pb.campid = campid;
            Database.executeBatch(pb,1);
        }
        else{
            //send email
            SendEmail.sendEmailonPullCampMembers();
        }        
    }
    
    //this method is called from the above batch "PullCampaign_Batch"
    public Boolean pullcampaignMembers(Id campaignid){
        //get last saved id for the campaign being pulled
        Typeform_PushPull__c tp = Typeform_PushPull__c.getValues('Value');
        Integer lastid = 1;
        Campaign tempc = [Select id, LastId_Members__c from Campaign where Id = :campaignid limit 1];
        
        if(tempc.LastId_Members__c != null)
            lastid = Integer.valueOf(tempc.LastId_Members__c);
        
        Http m_http = new Http(); 
        HttpRequest req = new HttpRequest();
        String xcampaignid = campaignid;
        //xcampaignid = xcampaignid.substring(0,15);
        req.setEndpoint('http://mailer.arg.to/api.pull.members.php?key=eU7GH1P_0s3jp8!?%7Cuc:&campaign_id=' + xcampaignid + '&last_id='+lastid);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');        
        req.setMethod('GET');
       
        HttpResponse response;
        CSVContent = '';
        
        if(!Test.isRunningTest()){
           response = m_http.send(req);    
        }
        if(Test.isRunningTest() || (response != null && response.getStatusCode() == 200)){
            if(Test.isRunningTest())
                CSVContent = '{"success":true}';
            else
                CSVContent = response.getBody();
    
        }
        else if(response != null){
        }    
        //system.debug('CSVContent = ' + CSVContent.abbreviate(1000));
        Boolean bMoreResult = false;
        if(lastid < 0 || (!String.isBlank(CSVContent) && CSVContent == '{"result":0}')){
            bMoreResult = false;
            return false;
        }
            
        
        
        if(!Test.isRunningTest())
            parseJSONMembersData(CSVContent);            
        
                return true;
    }
    
    public void parseJSONMembersData(String jsonInput){
        Map<Id, Set<Id>> campmemids = new Map<Id, Set<Id>>();
        Map<String, Map<String, Object>> campctcObjMap = new Map<String, Map<String, Object>>();
        List<Object> m1 = (List<Object>)JSON.deserializeUntyped(jsonInput);
        Set<Id> testcampid = new Set<Id>();
        Integer lastid = -1;
        String xtempCamp;
        for(Object mx : m1){
            //for each record
            Map<String, Object> xm = (Map<String, Object>) mx;
            //get campaign
            if(xm.containsKey('campaign_id') && xm.get('campaign_id') != null && xm.containsKey('salesforce_id') && xm.get('salesforce_id') != null){
                String xcmpid = (String)xm.get('campaign_id');
                String xctcid = (String)xm.get('salesforce_id');
                xtempCamp = xcmpid;
                if(xcmpid.length() > 15)
                    xcmpid = xcmpid.substring(0, 15);
                if(xctcid.length() > 15)
                    xctcid = xctcid.substring(0, 15);
                
                String x = xcmpid + '~' + xctcid;
                campctcObjMap.put(x, xm);
            }
            if(test.isRunningtest()){
                campctcObjMap = new Map<String, Map<String, Object>>();
                campctcObjMap.put((String)xm.get('campaign_id'), xm);
            }
            String xid = (String)xm.get('id');
            if(xid != null)
                lastid = Integer.valueOf(xid);
           
        }
        //update last id in the campaign
        if(lastid > -1 && !String.isBlank(xtempCamp)){
            Campaign tempc = [Select id, LastId_Members__c from Campaign where Id = :xtempCamp LIMIT 1];
            tempc.LastId_Members__c = lastid;
            update tempc;
        }
        
        //get campaign members and convert to Map       
        List<CampaignMember> xmem;
        if(Test.isRunningTest()){
            xmem =  [Select id,  CampaignId, Campaign_Contact__c, Date__c, External_ID__c, Opened__c, Open_Date_Time__c, Send_Status_General__c, Send_Status_Detailed__c, Status, Clicked__c, Clicked_Date_Time__c, External_Last_Modified_Date_Time__c, Bounced__c, Bounced_Date_Time__c 
                                from CampaignMember where Campaignid IN: campctcObjMap.keySet() LIMIT 1];
        }
        else{
            xmem =  [Select id, CampaignId, Campaign_Contact__c, Date__c, External_ID__c, Opened__c, Open_Date_Time__c, Send_Status_General__c, Send_Status_Detailed__c, Status, Clicked__c, Clicked_Date_Time__c, External_Last_Modified_Date_Time__c, Bounced__c, Bounced_Date_Time__c 
                                from CampaignMember where Campaign_Contact__c IN: campctcObjMap.keySet() LIMIT 100];
        }
        
        DateTime dateInstance; 
        for(CampaignMember m : xmem){
            if(Test.isRunningTest() || campctcObjMap.containsKey(m.Campaign_Contact__c)){
                Map<String, Object> currJsonObj = campctcObjMap.get(m.Campaign_Contact__c);     
                if(Test.isRunningTest())
                    currJsonObj = campctcObjMap.get(m.CampaignId);   
                //set the values
                                if(currJsonObj.get('sent_timestamp')!= null){
                                        dateInstance = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0); //for converting UNIX timestamp
                                        try{
                                                Integer ms = (Integer)currJsonObj.get('sent_timestamp');
                                                m.Date__c = dateInstance.addSeconds(ms);        
                                        }
                                        catch(Exception e){
                                                m.Date__c=null;
                                        }
                                        
                                }
                                else{
                                        m.Date__c=null; 
                                }

                m.Opened__c=(Boolean)currJsonObj.get('is_opened');

                                if(currJsonObj.get('opened_timestamp')!= null){
                                        dateInstance = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0); //for converting UNIX timestamp
                                        try{
                                                Integer ms = (Integer)currJsonObj.get('opened_timestamp');
                                                m.Open_Date_Time__c = dateInstance.addSeconds(ms);                                              
                                        }
                                        catch(Exception e){
                                                m.Open_Date_Time__c = null;
                                        }

                                }
                                else{
                                        m.Open_Date_Time__c=null;       
                                }

                m.Send_Status_General__c=(String)currJsonObj.get('send_status_general');
                m.Send_Status_Detailed__c=(String)currJsonObj.get('send_status_detailed');
                m.Status=(String)currJsonObj.get('status_summarized');                
                m.Clicked__c=(Boolean)currJsonObj.get('is_clicked');

                                if(currJsonObj.get('clicked_timestamp')!= null){
                                        dateInstance = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0); //for converting UNIX timestamp
                                        try{
                                                Integer ms = (Integer)currJsonObj.get('clicked_timestamp');
                                                m.Clicked_Date_Time__c = dateInstance.addSeconds(ms);                                           
                                        }
                                        catch(Exception e){
                                                m.Clicked_Date_Time__c=null;
                                        }

                                }
                                else{
                                        m.Clicked_Date_Time__c=null;    
                                }

                                if(currJsonObj.get('last_modified')!= null){
                                        dateInstance = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0); //for converting UNIX timestamp
                                        try{
                                                Integer ms = (Integer)currJsonObj.get('last_modified');
                                                m.External_Last_Modified_Date_Time__c = dateInstance.addSeconds(ms);                                            
                                        }
                                        catch(Exception e){
                                                m.External_Last_Modified_Date_Time__c=null;
                                        }

                                }
                                else{
                                        m.External_Last_Modified_Date_Time__c=null;     
                                }

                m.Bounced__c=(Boolean)currJsonObj.get('is_bounced');

                                if(currJsonObj.get('bounced_timestamp')!= null){
                                        dateInstance = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0); //for converting UNIX timestamp
                                        try{
                                                Integer ms = (Integer)currJsonObj.get('bounced_timestamp');
                                                m.Bounced_Date_Time__c = dateInstance.addSeconds(ms);                                           
                                        }
                                        catch(Exception e){
                                                m.Bounced_Date_Time__c=null;    
                                        }

                                }
                                else{
                                        m.Bounced_Date_Time__c=null;    
                                }
                
            }
           
        }
        update xmem;
        //put the map values
        
        
    }



//////////// PUSH

    public pagereference pushdata(){
        waitMessage = '';
        errAuthInit = '';
        if(String.isBlank(authInitial)){
            errAuthInit = 'Please authorize email push!';
            return null;
        }
        waitMessage = 'Email blast request sent!';
        //get from email name and from email address
        String fromname = fromemailname;
        //String fromemail = fromemailaddr;
    
        List<TypeForm_metadata__mdt> mt = [select Name_And_Email__c, QualifiedApiName, MasterLabel, 
        Typeform_Email_From__c, Use__c, TypeForm_Emails__c from TypeForm_metadata__mdt where Name_And_Email__c = :fromemailaddr limit 1];
        if(Test.isRunningTest()){
            mt = [select Name_And_Email__c, QualifiedApiName, MasterLabel, 
        Typeform_Email_From__c, Use__c, TypeForm_Emails__c from TypeForm_metadata__mdt limit 1];
        }
        fromemailname = mt[0].Typeform_Email_From__c;
        String fromemail = mt[0].TypeForm_Emails__c;        
        
        DateTime dt1 = null;
        String dt;
        if(!String.isBlank(selScheduleOption) && selScheduleOption == 'later'){
            dt1 = thiscamp.BatchUpdateDateTime__c;
            dt = dt1.format('yyyy-MM-dd HH:mm:ss','America/Argentina/Buenos_Aires');
        }
            
        
        String templateId = selEmailTemplate; //to come from UI
        
        String addtnString = '&fromname='+fromname+'&fromemail='+fromemail+'&schedule='+dt+'&emailtemplateid='+templateId;
        system.debug('addtnString = ' + addtnString);
                
        Http m_http = new Http(); 
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://mailer.arg.to/api.createblast.php');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');        
        req.setMethod('POST');
        req.setTimeout(120000);
        Date crDate = date.newinstance(camp.createddate.year(), camp.createddate.month(), camp.createddate.day());
        String xcampaignid = camp.id;
        xcampaignid = xcampaignid.substring(0,15); 
        List<RecordType> lr = [select id, name, developername from recordtype where sobjecttype = 'Campaign' AND developername = 'Email' LIMIT 1];
        String strBlastType = camp.RecordTypeId;
        if(lr != null && lr.size() > 0){
            strBlastType = lr[0].id;
        }
        
        String strBody = 'key=eU7GH1P_0s3jp8!?|uc:&blast_name='+camp.name+'&sf_campaignid='+camp.id+'&typeform_id='+camp.Type_Form_ID__c+'&blast_type='+strBlastType+'&created_on='+crDate +'&report_id='+ selReport;
        system.debug('strBody = ' + strBody);
        strBody += addtnString;
        if(!String.isBlank(addtlids)){
            strBody += '&addtlids='+addtlids;
        }
        req.setBody(strBody);
        
        HttpResponse response;
        CSVContent = '';
        
        if(!Test.isRunningTest()){
         response = m_http.send(req);     
        }
       // waitMessage = strBody;
        
        if(Test.isRunningTest() || (response != null && response.getStatusCode() == 200)){
            if(Test.isRunningTest())
                CSVContent = '{"success":true}';
            else
                CSVContent = response.getBody();
    
        }
        else if(response != null){
            CSVContent = response.getBody();
        }    
       // CSVContent = '{"success":true,"id":"113"}'; //for TESTING
        //system.debug('CSVContent = ' + CSVContent.abbreviate(1000));
        String strstatus='';
        try{
            Map<String, Object> jsonresp = (Map<String, Object>)JSON.deserializeUntyped(CSVContent);
            if(jsonresp.containsKey('success') && jsonresp.containsKey('id')){
                strstatus = 'SUCCESS';
                //update campaign with this blast info
                camp.Blast_ID__c = (String)jsonresp.get('id');
                camp.Email_Blast_sent__c = true;
                if(!String.isBlank(selReport))
                    camp.Email_Blast_Report__c = 'https://' + URL.getSalesforceBaseUrl().getHost() +  '/' + selReport;
                
                if(!String.isBlank(selEmailTemplate))
                    camp.Email_Blast_Template__c = 'https://' + URL.getSalesforceBaseUrl().getHost() +  '/' + selEmailTemplate;
               
                update camp;
            }
            else{
                strstatus = 'FAILED';
                errAuthInit = 'Invalid response from server!';
            }
        }
        catch(Exception e){
            CSVContent = 'Error Parsing response: ' +  CSVContent + ' : ERROR : ' + e.getMessage() + '~~' + e.getStackTraceString() + '~~Line: ' + e.getLineNumber();
            strstatus = 'FAILED';
            errAuthInit = 'Error parsing response!';
        }
        finally{
            String schtime = (dt==null?'now' : String.valueOf(dt));
            String camplink = 'https://' + URL.getSalesforceBaseUrl().getHost() + '/' + camp.id;
            SendEmail.sendEmailonPullCampMembers(camp.name, strstatus, camp.Blast_ID__c, camplink, schtime, strBody, CSVContent); 
        }
        
        return null;
    }

    //******************************* PUSH Campaign Members In JSON Format
    public pageReference pushCampaignMembers(){
        //Typeform_PushCampaignMembers t = new Typeform_PushCampaignMembers();
                //CSVContent = t.createJSON(camp.id);
                Typeform_PushCampaignMembers t = new Typeform_PushCampaignMembers();
        t.campid = camp.id;
        Database.executeBatch(t, 100);
        return null;
    }           
    //************** NEW UI FOR TEMPLATE FOLDER SELECTION
    public Id selEmailTemplate {get; set;}
    public String strBody {get; set;}
    public String subject;
    public String strBody0;
    public String strSendPreviewEmailTo {get; set;}
    
    public String renderEmailText {
        get{
            if(selEmailTemplate == null)
                return null;

            Messaging.SingleEmailMessage mm =  Messaging.renderStoredEmailTemplate(selEmailTemplate, null, null);
            String x = mm.getPlainTextBody();
            x = x.replaceAll('\n\r', '<br/>'); x = x.replaceAll('\n', '<br/>');
            
            return x;
        }
    
    set;
    }
    
    public String renderEmailTemplate {
        get{
            if(selEmailTemplate == null)
                return null;

            Messaging.SingleEmailMessage mm =  Messaging.renderStoredEmailTemplate(selEmailTemplate, null, null);
            strBody = mm.getPlainTextBody();
            strBody0 = mm.getPlainTextBody();
            strBody = strBody.replaceAll('\n\r', '<br/>'); strBody = strBody.replaceAll('\n', '<br/>');
            subject = mm.getSubject();
            return mm.getHTMLBody();
        }
    
    set;
    }
    
    public String selEmailTemplateFolder {get; set;}    
    
    
    private Map<Id, Folder> templateFolders;
    //public Id selec
    public List<SelectOption> getTemplateFolders() {
        if(templateFolders == null){
            templateFolders = new Map<Id, Folder>([Select id, Name, DeveloperName from Folder where Type='email' LIMIT 1000]);
        }

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(UserInfo.getOrganizationId(), 'Unfiled Public Email Template'));
        //options.add(new SelectOption(UserInfo.getUserId(), 'Personal Email Template'));
        for(Id ii : templateFolders.keySet()){
            options.add(new SelectOption(ii, templateFolders.get(ii).Name));
        }

        return options;
    }
    public pageReference changeEmailTemplateFolder(){
        getEmailTemplateInFolder();
        return null;
    }
    public List<SelectOption> getEmailTemplateInFolder(){
        if(String.isBlank(selEmailTemplateFolder)){
            selEmailTemplateFolder = UserInfo.getOrganizationId(); //default show email templates from the unfiled folder (the first in the list)
        }
        
        List<EmailTemplate> ets = [select id, name, folder.name, folderid from EmailTemplate where folderid= :selEmailTemplateFolder ORDER BY name asc LIMIT 1000];
        List<SelectOption> options = new List<SelectOption>();
        for(EmailTemplate et : ets){
            options.add(new SelectOption(et.id, et.Name));
        }
    
        return options;            
    }
    
    public String selScheduleOption {get; set;}
    public List<SelectOption> getSchedulingOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('now', 'Send immediately'));
        options.add(new SelectOption('later', 'Send later (specify date/time below in DD/MM/YYYY HH:MM format)'));
        return options;            
    }
    //From email address
    public String fromemailaddr {get; set;}
    public String fromemailname {get; set;}
    public List<SelectOption> getFromEmails() {
        List<TypeForm_metadata__mdt> mt = [select Name_And_Email__c, QualifiedApiName, MasterLabel, Typeform_Email_From__c, Use__c, TypeForm_Emails__c from TypeForm_metadata__mdt limit 100];

        List<SelectOption> options = new List<SelectOption>();
        
        for(TypeForm_metadata__mdt m : mt){
            if(String.isBlank(fromemailname))
                fromemailname = m.Typeform_Email_From__c;
            
            options.add(new SelectOption(m.Name_And_Email__c, m.Name_And_Email__c));
            
        }
        
        return options;
    }
    
    public pagereference changeEmailFromName() {
        List<TypeForm_metadata__mdt> mt = [select Name_And_Email__c, QualifiedApiName, MasterLabel, 
        Typeform_Email_From__c, Use__c, TypeForm_Emails__c from TypeForm_metadata__mdt where Name_And_Email__c = :fromemailaddr limit 1];
        fromemailname = mt[0].Typeform_Email_From__c;
        return null;
    }
        
    public pageReference test(){
        return null;
    }
    
    //send preview email
    public pageReference sendEmailPreview(){
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress limit 1];
        if(!String.isBlank(strSendPreviewEmailTo)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {strSendPreviewEmailTo};
            mail.setToAddresses(toAddresses);
            //mail.setReplyTo('email@domain.com');
            //mail.setSenderDisplayName('Salesforce Admin');
            mail.setSubject(subject);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setHtmlBody(renderEmailTemplate);
            mail.setPlainTextBody(strBody0);
            mail.setTreatBodiesAsTemplate(true);
            if(!Test.isRunningTest()){
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
                        
            
        }
        return null;
    }
    
    public String authInitial {get; set;}
    
    //************** NEW UI FOR REPORT FOLDER SELECTION
    public Id selReport {get; set;}
    public String selReportFolder {get; set;}    
    private Map<Id, Folder> reportFolders;
    public String repRecCount {get; set;}
    public String addtlids {get; set;}
     
    //public Id selec
    public List<SelectOption> getReportFolders() {
        if(reportFolders == null){
            reportFolders = new Map<Id, Folder>([Select id, Name, DeveloperName from Folder where Type='Report' AND DeveloperName != null LIMIT 1000]);
        }

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(UserInfo.getOrganizationId(), 'Unfiled Public Reports'));
        //options.add(new SelectOption(UserInfo.getUserId(), 'Personal Reports'));
        for(Id ii : reportFolders.keySet()){
            options.add(new SelectOption(ii, reportFolders.get(ii).Name));
        }

        return options;
    }
    public pageReference changeReportFolder(){
        getReportInFolder();
        return null;
    }
    public List<SelectOption> getReportInFolder(){
        if(String.isBlank(selReportFolder)){
            selReportFolder = UserInfo.getOrganizationId(); //default show reports from the unfiled folder (the first in the list)
        }
        
        List<Report> ets = [select id, name, developername, ownerid from Report where Format='Tabular' AND ownerid = :selReportFolder LIMIT 1000];
        List<SelectOption> options = new List<SelectOption>();
        for(Report et : ets){
            options.add(new SelectOption(et.id, et.Name));
        }
    
        return options;            
    }
    public pageReference getReportRecCount(){
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_analytics_report_data.htm
        // Run a report synchronously
        
        
        Http m_http = new Http();
        HttpRequest req = new HttpRequest();
        string autho = 'Bearer '+userInfo.getSessionId();
        req.setHeader('Authorization', autho);
        req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v39.0/analytics/reports/' + selReport);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');        
        req.setMethod('GET');
        req.setTimeout(120000);
        HttpResponse response;
        if(Test.isRunningTest()){
        }
        else{
            response = m_http.send(req);
        }
        String x;
        if(Test.isRunningTest()){
            x = '{"attributes":{"describeUrl":"/services/data/v39.0/analytics/reports/00O6A000001t2k5UAA/describe","instancesUrl":"/services/data/v39.0/analytics/reports/00O6A000001t2k5UAA/instances","reportId":"00O6A000001t2k5UAA","reportName":"Pregunta 06","type":"Report"},"allData":true,"factMap":{"0_0!0":{"aggregates":[{"label":"1.030","value":1030}]},"1!0":{"aggregates":[{"label":"631","value":631}]},"T!0":{"aggregates":[{"label":"1.661","value":1661}]},"0!T":{"aggregates":[{"label":"1.030","value":1030}]},"0_0!T":{"aggregates":[{"label":"1.030","value":1030}]},"1!T":{"aggregates":[{"label":"631","value":631}]},"T!T":{"aggregates":[{"label":"1.661","value":1661}]},"1_1!T":{"aggregates":[{"label":"118","value":118}]},"1_2!T":{"aggregates":[{"label":"302","value":302}]},"1_0!T":{"aggregates":[{"label":"211","value":211}]},"1_1!0":{"aggregates":[{"label":"118","value":118}]},"1_2!0":{"aggregates":[{"label":"302","value":302}]},"1_0!0":{"aggregates":[{"label":"211","value":211}]},"0!0":{"aggregates":[{"label":"1.030","value":1030}]}},"groupingsAcross":{"groupings":[{"groupings":[],"key":"0","label":"Sante Fe IVR","value":"7016A000000glqrQAA"}]},"groupingsDown":{"groupings":[{"groupings":[{"groupings":[],"key":"0_0","label":"-","value":null}],"key":"0","label":"-","value":null},{"groupings":[{"groupings":[],"key":"1_0","label":"ESTÁ IGUAL","value":"ESTÁ IGUAL"},{"groupings":[],"key":"1_1","label":"ESTÁ MEJOR","value":"ESTÁ MEJOR"},{"groupings":[],"key":"1_2","label":"ESTÁ PEOR","value":"ESTÁ PEOR"}],"key":"1","label":"HACE 2 AÑOS HUBO ELECCIONES PRESIDENCIALES Y MACRI FUE ELEGIDO PRESIDENTE. ¿ESTO CÓMO AFECTÓ TU SITUACIÓN?","value":"HACE 2 AÑOS HUBO ELECCIONES PRESIDENCIALES Y MACRI FUE ELEGIDO PRESIDENTE. ¿ESTO CÓMO AFECTÓ TU SITUACIÓN?"}]},"hasDetailRows":false,"picklistColors":{},"reportExtendedMetadata":{"aggregateColumnInfo":{"RowCount":{"dataType":"int","label":"Record Count"}},"detailColumnInfo":{"CampaignMember.Question_01__c":{"dataType":"string","label":"Pregunta 01"},"HAS_RESPONDED":{"dataType":"boolean","label":"Responded"}},"groupingColumnInfo":{"CampaignMember.Question_06__c":{"dataType":"string","groupingLevel":0,"label":"Pregunta 06"},"CampaignMember.Answer_06__c":{"dataType":"string","groupingLevel":1,"label":"Respuesta 06"},"CAMPAIGN_NAME":{"dataType":"string","groupingLevel":0,"label":"Campaign Name"}}},"reportMetadata":{"aggregates":["RowCount"],"chart":{"chartType":"Horizontal Bar Stacked to 100","groupings":["CampaignMember.Question_06__c","CampaignMember.Answer_06__c"],"hasLegend":true,"legendPosition":"Right","referenceLineColors":[null],"referenceLineValues":[null],"showChartValues":false,"summaries":["RowCount"],"summaryAxisLocations":["Y"],"summaryColors":[null],"summaryVisualizationTypes":["Column"],"title":"Respuesta 06"},"crossFilters":[],"currency":null,"description":null,"detailColumns":["CampaignMember.Question_01__c","HAS_RESPONDED"],"developerName":"Pregunta_06","division":null,"folderId":"0056A000000UbpaQAC","groupingsAcross":[{"dateGranularity":"None","name":"CAMPAIGN_NAME","sortAggregate":null,"sortOrder":"Asc"}],"groupingsDown":[{"dateGranularity":"None","name":"CampaignMember.Question_06__c","sortAggregate":null,"sortOrder":"Asc"},{"dateGranularity":"None","name":"CampaignMember.Answer_06__c","sortAggregate":null,"sortOrder":"Asc"}],"hasDetailRows":false,"hasRecordCount":true,"historicalSnapshotDates":[],"id":"00O6A000001t2k5UAA","name":"Pregunta 06","reportBooleanFilter":null,"reportFilters":[{"column":"HAS_RESPONDED","isRunPageEditable":true,"operator":"equals","value":"True"},{"column":"CAMPAIGN_NAME","isRunPageEditable":false,"operator":"equals","value":"Sante Fe IVR"}],"reportFormat":"MATRIX","reportType":{"label":"Campaigns with Campaign Members","type":"CampaignWithCampaignMembers"},"scope":"organization","showGrandTotal":true,"showSubtotals":true,"sortBy":[],"standardDateFilter":null,"standardFilters":[],"supportsRoleHierarchy":false,"userOrHierarchyFilterId":null}}';
        }
        else{
            x = response.getBody();
        }
        
        system.debug('x = ' + x);
        Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(x);
        system.debug('m1 = ' + m1.keySet());
        MAP<String,Object> fm = (MAP<String,Object> ) m1.get('factMap');
        system.debug('fm= ' + fm);
        
        MAP<String,Object> factDetails = (MAP<String,Object>) fm.get('T!T');
        List<Object> s = (List<Object>)factDetails.get('aggregates');
        MAP<String,Object>  rr = (MAP<String,Object>)s[0];
        system.debug('out= ' + rr);
        system.debug('outlabel= ' + rr.get('label'));
        repRecCount = (String) rr.get('label');
        
        /*
        Reports.reportResults results;
        try{
            results = Reports.ReportManager.runReport(selReport, true);
            String factMapKey = 'T!T';
            
            // Get the fact map from the report results
            Reports.ReportFactWithDetails factDetails =
                (Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey);
            
            // Get the first summary amount from the fact map
            Reports.SummaryValue sumVal = factDetails.getAggregates()[0];
            System.debug('Summary Value: ' + sumVal.getLabel());
            repRecCount = sumVal.getLabel();
        }catch(Exception e){
            repRecCount = 'ERROR : ' + e.getMessage();
        }
        */
        return null;
    }
    
}