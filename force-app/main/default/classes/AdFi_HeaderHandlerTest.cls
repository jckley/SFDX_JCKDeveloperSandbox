@isTest
private class AdFi_HeaderHandlerTest {
   @testSetup
    public static void setupTest() {
       CommonTestFunctions.commonSetup();
    }
            
    @isTest
    public static void searchTest() {
        List<Territorio_Administrativo__c> lstTerritories = null;
        List<Id> lstTerritoriesResults = null;
        
        lstTerritories = [SELECT Id, Name FROM Territorio_Administrativo__c];
        lstTerritoriesResults = new List<Id>();
        
        for(Territorio_Administrativo__c objTerritory : lstTerritories) {
            lstTerritoriesResults.add(objTerritory.Id);
        }
        
        Test.setFixedSearchResults(lstTerritoriesResults);
        
        AdFi_HeaderHandler.searchForNames('Juan Perez');
        AdFi_HeaderHandler.searchForIds('hola mundo');
    }    
    
    @isTest
    public static void searchTestNoResults() {        
        AdFi_HeaderHandler.searchForNames('Juan Perez');
        AdFi_HeaderHandler.searchForIds('hola mundo');
    }    
}