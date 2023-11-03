@isTest
public class PCash_HomeControllerTest {
    
    @testSetup
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
    }
    
    @isTest  
    static void test1() {      
        Territorio_Administrativo__c objTerritoryC = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 0 
                         LIMIT 1];
        
        PCash_HomeController pcc = new PCash_HomeController();
        PCash_HomeController.getTerritoryById(objTerritoryC.Id);
    }

}