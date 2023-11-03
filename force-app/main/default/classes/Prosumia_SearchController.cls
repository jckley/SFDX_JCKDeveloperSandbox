public with sharing class Prosumia_SearchController {
    @AuraEnabled
    public static String retrieveCitizens() {
        /*
        Integer intCount = null;

        System.debug('retrieveCitizens [] ->');
        intCount = Database.countQuery('SELECT count() FROM Contact');*/
        RemotingMessageHelper.Territory objTerritory = null;
        
        objTerritory =  TerritoryHierarchyController.retrieveParentTerritory();
        
        //System.debug('objTerritory : ' + objTerritory);
        System.debug('retrieveCitizens [' + TerritoryDetailController.getTerritoryById2(objTerritory.Id).totalCiudadanosFormated + '] <-');
        return  TerritoryDetailController.getTerritoryById2(objTerritory.Id).totalCiudadanosFormated;
        

        //return intCount;
    }

    @AuraEnabled
    public static String retrieveRiverIDCitizens() {
        Integer members = [SELECT COUNT() FROM RiverId__c];
        System.debug('retrieveRiverMembers [' + members + '] <-');
        return  String.valueOf(members);
    }
    
    @AuraEnabled
    public static String retrieveChileCitizens() {
        /*
        Integer intCount = null;

        System.debug('retrieveChileCitizens [] ->');
        intCount = Database.countQuery('SELECT count() FROM Contact');*/
        RemotingMessageHelper.Territory objTerritory = null;
        
        objTerritory =  TerritoryHierarchyChileController.retrieveParentTerritory();
        
        if(objTerritory!=null) {
            
            //System.debug('objTerritory : ' + objTerritory);
            System.debug('retrieveChileCitizens [' + TerritoryDetailChileController.getTerritoryById2(objTerritory.Id).totalCiudadanosFormated + '] <-');
            return  TerritoryDetailChileController.getTerritoryById2(objTerritory.Id).totalCiudadanosFormated;
        } else {
            return 'No hay nada';
        }
        

        //return intCount;
    }
    
    @AuraEnabled
    public static String searchForNames(String strSearch) {
        Integer intLimit = 7;
        List<List<sObject>> lstResults = null;
        SearchResults objSearchResults = null;
        String strJSON = null;
        
        System.debug('searchForNames [ strSearch : ' + strSearch + '] ->');
        
        lstResults = [FIND :strSearch IN ALL FIELDS  
                      RETURNING Contact(Id, Name, PhotoUrl_legacy__c, Administrative_Level_1__c, Administrative_Level_2__c, gender__c), Territorio_Administrativo__c(Id, Name) 
                      LIMIT :intLimit];

        System.debug('searchForNames [ lstResults : ' + lstResults + ']');
        
        if(!lstResults.IsEmpty()) {
            objSearchResults = new SearchResults(lstResults);
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
    
    public class SearchResults {
        public List<SearchResult> results { get; set; }
        
        public SearchResults() {
            this.results = new List<SearchResult>();
        } 
        
        public SearchResults(List<List<sObject>> lstSOSLResult) {
            this();
            SearchResult objSearchResult = null;
            
            if(lstSOSLResult != null && !lstSOSLResult.isEmpty()) {
                for(List<sObject> lstResultType : lstSOSLResult) {
                    
                    if(lstResultType != null && !lstResultType.isEmpty()) {
                        objSearchResult = new SearchResult(lstResultType);
                        this.results.add(objSearchResult);
                    }
                }
            }
        } 
        
    }
    
    public class SearchResult { 
        public String type 			{ get; set; }
        public List<sObject> record { get; set; }
        
        public SearchResult() {
            this.record = new List<sObject>();
        }
        
        public SearchResult(List<sObject> lstResults) {
            this();
            if(lstResults != null && !lstResults.isEmpty()) {
                this.type = lstResults[0].getSObjectType().getDescribe().getLabel();
                this.record = lstResults;
            }
        }
    }
}