@IsTest
private class Typeform_pushpull_test {
    static testmethod void runtest(){
        Campaign cm = new Campaign();
        cm.Name = 'TestCampaign';
        cm.Type_Form_ID__c = 'Test';
        insert cm;
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.guid__c = '111';
        c.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DeveloperName = 'Argentino' ].Id;
        insert c;
        
        CampaignMember cmem = new CampaignMember();
        cmem.campaignid = cm.id;
        cmem.contactid = c.id;
        insert cmem;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cm);
        Typeform_pushpull tp = new Typeform_pushpull(sc);
        
        PageReference pageRef = Page.TypeformTestPAge;
        pageRef.getParameters().put('id', String.valueOf(cm.Id));
        Test.setCurrentPage(pageRef);
        String jsonResp = '[{"TypeForm ID":"eEEB1J","token":"aa","c":"'+c.id+'","browser":"default","platform":"other","date_land":"2017-06-26T15:42:18-04:00","date_submit":"2017-06-26T16:02:39-04:00","user_agent":"m","referer":"h","network_id":"380dd55b2d","Status":"Responded","Campaign ID":"'+cm.id+'","Question_1":"q","Answer_1":"Buena","Question_2":"q","Answer_2":"Buena","Question_3":"q","Answer_3":"Regular"}]';
        tp.parseJSONData(jsonResp);
        tp.authInitial = 'test';
        tp.pushdata();
        tp.parseOneCampaignData(cm.Type_Form_ID__c);
        
        tp.parseEmailBlastData();
        
        tp.pullcampaignMem();
        jsonResp = '[{"id":"2","campaign_id":"'+cm.id+'","campaign_member_id":"","salesforce_id":"'+c.id+'","internal_blast_id":"","created_by":"","sent_timestamp":1498574009,"is_opened":false,"opened_timestamp":"","send_status_general":"","send_status_detailed":"250 2.1.5 OK l34si2878532qte.350 - gsmtp","status_summarized":"","is_clicked":false,"clicked_timestamp":"","last_modified":1498706460,"is_bounced":false,"bounced_timestamp":""}]';
        tp.parseJSONMembersData(jsonResp);
        
        tp.parseAllData();
        tp.pushCampaignMembers();
        SendEmail.sendEmailonPullCampMembers();
        
    }
    static testmethod void runtest_emailtemplate(){
		Typeform_pushpull tp = new Typeform_pushpull();
        //cover email templates
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'test';
        validEmailTemplate.DeveloperName = 'testSM1';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getOrganizationId();
        insert validEmailTemplate;        
        
        tp.getTemplateFolders();
        tp.changeEmailTemplateFolder();
		tp.test();        
        String x = tp.renderEmailTemplate;
        String y = tp.renderEmailText;
        
        tp.strSendPreviewEmailTo = 'matias.rodriguez@prosumia.la';
        tp.sendEmailPreview();
        

    }
    static testmethod void runtest_report(){
		Typeform_pushpull tp = new Typeform_pushpull();
        tp.getReportFolders();
        tp.changeReportFolder();
		tp.getReportInFolder();        
        tp.getReportRecCount();

		Typeform_SendSMS_Con ts = new Typeform_SendSMS_Con();
        ts.getReportFolders();
        ts.changeReportFolder();
		ts.getReportInFolder();        
        ts.getReportRecCount();


    }


    static testmethod void runtest_sms(){
        Campaign cm = new Campaign();
        cm.Name = 'TestCampaign';
        cm.Type_Form_ID__c = 'Test';
        insert cm;
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.guid__c = '111';
        c.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DeveloperName = 'Argentino' ].Id;
        insert c;
        
        CampaignMember cmem = new CampaignMember();
        cmem.campaignid = cm.id;
        cmem.contactid = c.id;
        insert cmem;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cm);
        Typeform_SendSMS_Con tp = new Typeform_SendSMS_Con(sc);
        tp.getSchedulingOptions();
		tp.pushdata();
    }   
    
    static testmethod void runtest_batch(){
        Campaign cm = new Campaign();
        cm.Name = 'TestCampaign';
        cm.Type_Form_ID__c = 'Test';
        insert cm;
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.guid__c = '111';
        c.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DeveloperName = 'Argentino' ].Id;
        insert c;
        
        CampaignMember cmem = new CampaignMember();
        cmem.campaignid = cm.id;
        cmem.contactid = c.id;
        insert cmem;
		
		Batch_PullCampaign_Email_Blast pc = new Batch_PullCampaign_Email_Blast();
    	database.executeBatch(pc, 1);
    	    	
    	String CRON_EXP = '0 0 0 15 3 ? 2022';
    	String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new Schedule_PullCampaign_Email_Blast());
    } 
}