global class RefreshRecordsProcessedBatch  implements Database.Batchable<sObject> {    
    private static Integer API_VERSION = 44;
    private List<Report> lstReportsToProcess = null;
    
    private class RequestReportTypeResult {
        public ReportMetadataResult reportMetadata { get; set; } 
    }
    
    private class ReportMetadataResult {
        public String id { get; set; }
        public String name { get; set; }
        public ReportTypeResult reportType { get; set;}
        
    }
    
    public class ReportTypeResult { 
        public String label { get; set; }
        public String type { get; set; }        
    }
    
    public RefreshRecordsProcessedBatch(List<Report> lstReportsAux) {
        lstReportsToProcess = lstReportsAux;
    }    
    
    global List<Report> start(Database.BatchableContext objBatchableContext) {
        List<Report> lstReportsAux = null;
        
        System.debug('start [ objBatchableContext : ' + objBatchableContext + '] ->');    
        
        lstReportsAux = this.lstReportsToProcess;     
        
        System.debug('start [' + lstReportsAux + '] <-');   
        return lstReportsAux;
    }
    
    global void execute(Database.BatchableContext objBatchableContext, List<Report> lstReports) {                
        ReportQueue objReportQueue = null;
        System.debug('execute [ objBatchableContext : ' + objBatchableContext + '] ->');  
        
        objReportQueue = new ReportQueue(lstReports);
        System.enqueueJob(objReportQueue);
        
        System.debug('execute [] <-');  
    }  
    
    global void finish(Database.BatchableContext objBatchableContext) {      
        System.debug('finish [ objBatchableContext : ' + objBatchableContext + '] ->');  
        
        
        System.debug('finish [] <-');  
    }
    
    
    
    public class ReportQueue implements Queueable {
        private List<Report> lstReportsToProcess = null;
        
        public ReportQueue(List<Report> lstReports) {
            this.lstReportsToProcess = lstReports;
        }
        
        public void execute(QueueableContext objQueueableContext) {
            for(Report objReport : lstReportsToProcess) {
                updateReportTypeInfo (JSON.serialize(objReport));
            }
        }                
    }
    
    @future(callout=true)
    private static void updateReportTypeInfo(String strJSON) {
        Report objReport = null;
        String strMethod = null;
        String strEndpoint = null;
        String strBody = null;
        Map<String, String> mapHeader = null;
        HttpResponse objResponse = null;
        RequestReportTypeResult objResult = null;
        Report_Quereable__c objReportQuereable = null;
                        
        System.debug('updateReportTypeInfo [ strJSON : ' + strJSON + ' ] ->');
        
        if(String.isNotBlank(strJSON)) {
            objReport = (Report)JSON.deserialize(strJSON, Report.class);
            if(objReport != NULL && String.isNotBlank(objReport.Id)) { 
                strEndPoint = URL.getSalesforceBaseUrl().toExternalForm(); 
                strEndPoint = String.format('{0}/services/data/v{1}.0/analytics/reports/{2}/', new String[] { strEndpoint, String.valueOf(API_VERSION), objReport.Id});  
                strMethod = 'GET';
                
                mapHeader = new Map<String, String>();
                mapHeader.put('Content-Type', 'text/xml');
                mapHeader.put('Authorization', 'OAuth ' + UserInfo.getSessionId());
                mapHeader.put('Authorization', 'Bearer ' + UserInfo.getSessionId());
                
                objResponse = sendRequest(strMethod, strEndpoint, mapHeader, strBody);
                strBody = objResponse.getBody();
                
                if(objResponse.getStatusCode() == 200) {
                    objResult = (RequestReportTypeResult) JSON.deserialize(strBody, RequestReportTypeResult.class);
                    System.debug('objResult : ' + objResult);
                    
                    objReportQuereable = new Report_Quereable__c();
                    objReportQuereable.Name = objReport.Name;
                    objReportQuereable.Folder_Name__c = objReport.FolderName;
                    objReportQuereable.Format__c = objReport.Format;          
                    objReportQuereable.Report_Id__c = objReport.Id;
                    objReportQuereable.Source__c = 'Report';
                    objReportQuereable.Type__c = objResult.reportMetadata.reportType.type;
                    
                    insert objReportQuereable;
                } 
            }
        }    
        
        System.debug('updateReportTypeInfo [] <-');
    }
    
    private static HttpResponse sendRequest(String strMethod, String strEndpoint, Map<String, string> mapHeader, String strJSON) {
        HttpRequest objRequest = null;
        Http objHttp = null;               
        HttpResponse objResponse = null;
        
        System.debug('sendRequest [ strMethod : ' + strMethod + ' - strEndpoint : ' + strEndpoint + ' - mapHeader : ' + mapHeader +' - strJSON : ' + strJSON + '] ->');
        objRequest = new HttpRequest();
        objRequest.setMethod(strMethod); 
        objRequest.setEndpoint(strEndpoint);
        
        for(String strHeader : mapHeader.keySet()) {            
            objRequest.setHeader(strHeader, mapHeader.get(strHeader));
        }
        if(strMethod != 'GET') {
            objRequest.setBody(strJSON);            
        }
        
        objHttp = new Http();               
        objResponse = objHttp.send(objRequest);
        
        System.debug('sendRequest [ Code : ' + objResponse.getStatusCode() + ']');
        System.debug('sendRequest [ Body : ' + objResponse.getBody() + ']');
        
        System.debug('sendRequest [] <-');
        
        return objResponse;
    }
}