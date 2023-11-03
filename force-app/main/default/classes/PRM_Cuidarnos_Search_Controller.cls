public with sharing class PRM_Cuidarnos_Search_Controller {
    @AuraEnabled
    public static Integer retrieveCitizens() {
        Integer intCount = null;

        System.debug('retrieveCitizens [] ->');
        intCount = Database.countQuery('SELECT count() FROM Contact');

        System.debug('retrieveCitizens [' + intCount + '] <-');

        return intCount;
    }

    @AuraEnabled
    public static String searchCitizen(String strSearch, Integer intResults) {
        List<List<sObject>> lstResults = null;
        RemotingMessageHelper.SearchResults objSearchResults = null;
        String strJSON = null;
        
        System.debug('searchCitizen [ strSearch : ' + strSearch + ' - intResults : ' + intResults +  '] ->');
        
        lstResults = [FIND :strSearch IN ALL FIELDS  
                      RETURNING Contact(Id, Name,Document_Number__c, Age_f_x__c, Administrative_Level_2__c,  covid19_salud_status__c )
                      LIMIT :intResults];

        System.debug('searchForNames [ lstResults : ' + lstResults + ']');
        
        if(!lstResults.IsEmpty()) {
            objSearchResults = new RemotingMessageHelper.SearchResults(lstResults);
            strJSON = JSON.serializePretty(objSearchResults, true);            
        }
        
        System.debug('searchCitizen [ ' + strJSON + '] <-');

        return strJSON;
    }    
}