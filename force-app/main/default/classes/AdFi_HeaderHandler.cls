public with sharing class AdFi_HeaderHandler {
    @AuraEnabled
    public static String searchForNames(String strSearch) {
        Integer intLimit = 7;
        List<List<sObject>> lstResults = null;
        RemotingMessageHelper.SearchResults objSearchResults = null;
        String strJSON = null;
        
        System.debug('searchForNames [ strSearch : ' + strSearch + '] ->');
        
        lstResults = [FIND :strSearch IN ALL FIELDS  
                      RETURNING Contact(Id, Name), Territorio_Administrativo__c(Id, Name) 
                      LIMIT :intLimit];

        System.debug('searchForNames [ lstResults : ' + lstResults + ']');
        
        if(!lstResults.IsEmpty()) {
            objSearchResults = new RemotingMessageHelper.SearchResults(lstResults);
            strJSON = JSON.serializePretty(objSearchResults, true);            
        }
        
        System.debug('searchForNames [ ' + strJSON + '] <-');

        return strJSON;
    }
    
    @AuraEnabled
    public static List<String> searchForIds(String searchText) {
        List<List<SObject>> results = [FIND :searchText IN ALL FIELDS  RETURNING Contact(Id, Name), Territorio_Administrativo__c(Id, Name)];
        List<String> ids = new List<String>();
        for (List<SObject> sobjs : results) {
            for (SObject sobj : sobjs) {
                ids.add(sobj.Id);
            }
        }
         System.debug('searchForIds [' + ids + '] <-');
        return ids;
    }
}