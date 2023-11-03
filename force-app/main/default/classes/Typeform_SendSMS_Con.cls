public with sharing class Typeform_SendSMS_Con {
    public Typeform_SendSMS_Con(){}
    public String CSVContent {get;set;}
    public String errormessages {get;set;}
    public String requestString {get;set;}
    
    public campaign thiscamp {get; set;}
    public Typeform_SendSMS_Con(ApexPages.StandardController stdController) {
        thiscamp = (Campaign) stdController.getRecord();
        thiscamp = [Select id, name, recordtypeid, Type_Form_ID__c, SMS_Content__c, createddate, BatchUpdateDateTime__c from Campaign where id=: thiscamp.id LIMIT 1];
        selScheduleOption = 'now';
    }
//////////// PUSH

    public pagereference updateCampaign(){
        if(String.isBlank(authInitial)){
            errormessages = 'Please authorize SMS push!';
            return null;
        }
        update thiscamp;
        return null;
    }
    
    public pagereference pushdata(){
        if(String.isBlank(authInitial)){
            errormessages = 'Please authorize SMS push!';
            return null;
        }

        String fromname = UserInfo.getName();
        String fromemail = UserInfo.getUserEmail();
        DateTime dt = null;
        if(!String.isBlank(selScheduleOption) && selScheduleOption == 'later')
            dt = thiscamp.BatchUpdateDateTime__c;
        
        //String templateId = selEmailTemplate; //to come from UI
        
        String addtnString = '&fromname='+fromname+'&fromemail='+fromemail+'&schedule='+dt;
                
        Http m_http = new Http(); 
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://mailer.arg.to/api.createblast.php');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');        
        req.setMethod('POST');
        Date crDate = date.newinstance(thiscamp.createddate.year(), thiscamp.createddate.month(), thiscamp.createddate.day());
        String xcampaignid = thiscamp.id;
        xcampaignid = xcampaignid.substring(0,15); 
        List<RecordType> lr = [select id, name, developername from recordtype where sobjecttype = 'Campaign' AND developername = 'SMS' LIMIT 1];
        String strBlastType = thiscamp.RecordTypeId;
        if(lr != null && lr.size() > 0){
            strBlastType = lr[0].id;
        }
        
        String strBody = 'key=eU7GH1P_0s3jp8!?|uc:&blast_name='+thiscamp.name+'&sf_campaignid='+thiscamp.id+'&typeform_id='+thiscamp.Type_Form_ID__c+'&blast_type='+strBlastType+'&created_on='+crDate +'&report_id='+ selReport;
        system.debug('strBody = ' + strBody);
        strBody += addtnString;
        if(!String.isBlank(addtlids)){
            strBody += '&addtlids='+addtlids;
        }
        
        req.setBody(strBody);
        
        requestString = strBody;
        
        HttpResponse response;
        CSVContent = '';
        
        if(!Test.isRunningTest()){
           response = m_http.send(req);    
        }
        if(Test.isRunningTest() || (response != null && response.getStatusCode() == 200)){
            if(Test.isRunningTest())
                CSVContent = 'Response = {"success":true}';
            else
                CSVContent = 'Response = ' + response.getBody();
    
        }
        else if(response != null){
        }    
        //system.debug('CSVContent = ' + CSVContent.abbreviate(1000));
        try{
            Map<String, Object> jsonresp = (Map<String, Object>)JSON.deserializeUntyped(CSVContent);
            if(jsonresp.containsKey('success') && jsonresp.containsKey('id')){
                //update campaign with this blast info
                thiscamp.Blast_ID__c = (String)jsonresp.get('id');
                
            }
        }
        catch(Exception e){
            errormessages  = 'Error Parsing response: ' +  CSVContent + ' : ERROR : ' + e.getMessage();
        }
        finally{
            update thiscamp;
        }
        return null;
    }
    
    public String selScheduleOption {get; set;}
    public List<SelectOption> getSchedulingOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('now', 'Send immediately'));
        options.add(new SelectOption('later', 'Send later (specify date/time below)'));
        return options;            
    }
    
    public pageReference test(){
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
        
        /*Reports.reportResults results;
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
        }*/
        
        return null;
    }
    
}