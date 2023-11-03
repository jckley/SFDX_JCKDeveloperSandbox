@IsTest
public class Prosumia_SearchControllerTest {
    @IsTest
    private static void cuidarnosSearchTest() {

        Prosumia_SearchController.retrieveCitizens();
        //Prosumia_SearchController.searchCitizen('juan',10); 
    }
    @IsTest
    private static void chileSearchTest() {

        Prosumia_SearchController.retrieveChileCitizens();
        //Prosumia_SearchController.searchCitizen('juan',10); 
    }
    @IsTest
    private static void riverTest() {

        Prosumia_SearchController.retrieveRiverIDCitizens();
    }
    
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
        
        Prosumia_SearchController.searchForNames('Juan Perez');
        Prosumia_SearchController.searchForIds('hola mundo');
    }    
    
    @isTest
    public static void searchTestNoResults() {        
        Prosumia_SearchController.searchForNames('Juan Perez');
        Prosumia_SearchController.searchForIds('hola mundo');
    }
}