/**
 * ClassName: TerritoryListChileControllerTest
 * Description: Test class for the territory list view
 * Developer: José Gerstner - Date: 24/02/2022
*/

@isTest
public class TerritoryListChileControllerTest {	
    @testSetup
    private static void setupTest() {
        CommonTestFunctions.commonChileSetup();
    }   
    
    @isTest  
    static void territoryListChileControllerExclusionTest() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListChileController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        Territorio_Administrativo__c objTerritoryToExclude = NULL;
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 0 
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
		objTerritoryToExclude = CommonTestFunctions.createTerritorioAdministrativo('Excluite este', objTerritoryC, 1);
	        
        objTerritoryController = new TerritoryListChileController();
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListChileController.getChildTerritoriesWithExclusion(objTerritoryC.Id, objTerritoryToExclude.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(1, lstTerritories.size() );               
    }
    
    @isTest  
    static void territoryListChileControllerLevel0Test() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListChileController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 0 
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
        
        objTerritoryController = new TerritoryListChileController();
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListChileController.getChildTerritories(objTerritoryC.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(1, lstTerritories.size() );               
    }
    
    @isTest  
    static void territoryListChileControllerLevel1Test() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListChileController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 1
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
        
        objTerritoryController = new TerritoryListChileController();
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListChileController.getChildTerritories(objTerritoryC.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(1, lstTerritories.size() );             
    }
    
    @isTest  
    static void territoryListChileControllerLevel2Test() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListChileController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 2 
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
        
        objTerritoryController = new TerritoryListChileController();
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListChileController.getChildTerritories(objTerritoryC.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(1, lstTerritories.size() );                            
    }
    
    @isTest  
    static void territoryListChileControllerLevel3Test() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListChileController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 3 
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
        
        objTerritoryController = new TerritoryListChileController();
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListChileController.getChildTerritories(objTerritoryC.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(1, lstTerritories.size() );                           
    }
    
    @isTest  
    static void territoryListChileControllerLevel4Test() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListChileController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 4
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
        
        objTerritoryController = new TerritoryListChileController();
        
        System.assertEquals('Level 4', objTerritoryController.territory.Name); //4
        System.assertEquals('Level 3', objTerritoryController.parentTerritory.Name); //3
        //System.assertEquals('Level 2', objTerritoryController.grandParentTerritory.Name); //2
        //System.assertEquals('Level 1', objTerritoryController.gGrandParentTerritory.Name); //1
        //System.assertEquals('Level 0', objTerritoryController.gGGrandParentTerritory.Name); //0
        System.assertEquals(NULL, objTerritoryController.grandParentTerritory.Name); //2
        System.assertEquals(NULL, objTerritoryController.gGrandParentTerritory.Name); //1
        System.assertEquals(NULL, objTerritoryController.gGGrandParentTerritory.Name); //0
        
        
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListChileController.getChildTerritories(objTerritoryC.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(0, lstTerritories.size() );                            
    }

    @isTest  
    static void territoryListChileControllerRootTerritory() {        
        Territorio_Administrativo__c objTerritoryC = null;
        RemotingMessageHelper.Territory objTerritoryCont = TerritoryListChileController.retrieveRootTerritory();
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c
                         WHERE Nivel_Administrativo__c = 0
                         AND Name = 'Chile'
                         LIMIT 1];
                         
        System.debug('Name 1: ' + objTerritoryC.Name);
        System.debug('Name 2: ' + objTerritoryCont.Name);
        System.assertEquals(objTerritoryC.Name, objTerritoryCont.Name);
    }
}