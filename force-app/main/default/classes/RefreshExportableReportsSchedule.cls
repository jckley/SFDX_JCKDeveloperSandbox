global class RefreshExportableReportsSchedule implements Schedulable {           
    global void execute(SchedulableContext objSchedulableContext) {
        List<Report> lstReports = null;
        Map<Id, Report_Quereable__c>  mapQueriedReports = null;
        Report_Quereable__c objReportQuereable = null;
        List<Report> lstReportsToQuery = null;
        Set<Id> setReportsToDelete = null;
        RefreshRecordsProcessedBatch objBatch = null;
        
        System.debug('execute [objSchedulableContext : ' + objSchedulableContext + '] ->');
        
        lstReportsToQuery = new List<Report>();
        lstReports = retrieveReports();
        mapQueriedReports = retrieveQueriedReports();
        if(!lstReports.isEmpty()) {
            setReportsToDelete = new Set<Id>();

            for(Report objReport : lstReports) {
                if(mapQueriedReports.containsKey(objReport.Id)) {
                    if(objReport.IsDeleted) {
                        setReportsToDelete.add(objReport.Id);
                    } else {
                        objReportQuereable = mapQueriedReports.get(objReport.Id);
                        objReportQuereable.Name = objReport.Name;
                        objReportQuereable.Folder_Name__c = objReport.FolderName;
                        objReportQuereable.Format__c = objReport.Format;                 
                        
                        mapQueriedReports.put(objReport.Id, objReportQuereable);
                    }
                } else {
                    lstReportsToQuery.add(objReport);
                }
            }
            
            if(!setReportsToDelete.IsEmpty()) {
                deleteReports(setReportsToDelete);
            }
            
            if(!lstReportsToQuery.IsEmpty() && !Test.isRunningTest()) {
                objBatch = new RefreshRecordsProcessedBatch(lstReportsToQuery);
                Database.executeBatch(objBatch, 50);
            }
        } else {
            deleteReports(mapQueriedReports.keySet());
        }
        
        System.debug('execute [objSchedulableContext : ' + objSchedulableContext + '] <-');
    }       
    private List<Report> retrieveReports() {
        List<Report> lstReports = null;
        
        System.debug('retrieveQueriedReports [] ->');
        
        lstReports = [SELECT Id, Name, FolderName, Format, IsDeleted
                      FROM Report];
        
        System.debug('retrieveQueriedReports [' + lstReports +  '] <-');
        
        return lstReports;       
    }
    
    private Map<Id, Report_Quereable__c> retrieveQueriedReports() { 
    	List<Report_Quereable__c> lstReports = null;
        Map<Id, Report_Quereable__c> mapReports = null;
        
        System.debug('retrieveQueriedReports [] ->');

        lstReports = [SELECT Name, Folder_Name__c, Format__c, Report_Id__c, Source__c, Type__c 
                      FROM Report_Quereable__c];
        
        mapReports = new Map<Id, Report_Quereable__c>();
        if(!lstReports.isEmpty()) {
            for(Report_Quereable__c objQuereableReport : lstReports) {
                mapReports.put(objQuereableReport.Report_Id__c, objQuereableReport);
            }
        }
        
        System.debug('retrieveQueriedReports [' + mapReports +  '] <-');
        
        return mapReports;
    }
    
    private void deleteReports(Set<Id> setReportsIds) {
        System.debug('deleteReports [ setReportsIds : ' + setReportsIds + ' ] ->');
        
        delete [SELECT Id 
                FROM Report_Quereable__c 
                WHERE Report_Id__c =: setReportsIds];
        
        System.debug('deleteReports [] <-');
    }       
}