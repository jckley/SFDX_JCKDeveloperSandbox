/**
 * ClassName: TerritoryListControllerTest
 * Description: Test class for the territory list view
 * Developer: Luis Puentes - Date: 29/06/2018
*/

@isTest
public class TerritoryListControllerTest {	
    @testSetup
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
    }   
    
    @isTest  
    static void territoryListControllerExclusionTest() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        Territorio_Administrativo__c objTerritoryToExclude = NULL;
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 0 
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
		objTerritoryToExclude = CommonTestFunctions.createTerritorioAdministrativo('Excluite este', objTerritoryC, 1);
	        
        objTerritoryController = new TerritoryListController();
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListController.getChildTerritoriesWithExclusion(objTerritoryC.Id, objTerritoryToExclude.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(1, lstTerritories.size() );               
    }
    
    @isTest  
    static void territoryListControllerLevel0Test() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 0 
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
        
        objTerritoryController = new TerritoryListController();
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListController.getChildTerritories(objTerritoryC.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(1, lstTerritories.size() );               
    }
    
    @isTest  
    static void territoryListControllerLevel1Test() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 1
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
        
        objTerritoryController = new TerritoryListController();
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListController.getChildTerritories(objTerritoryC.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(1, lstTerritories.size() );             
    }
    
    @isTest  
    static void territoryListControllerLevel2Test() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 2 
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
        
        objTerritoryController = new TerritoryListController();
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListController.getChildTerritories(objTerritoryC.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(1, lstTerritories.size() );                            
    }
    
    @isTest  
    static void territoryListControllerLevel3Test() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 3 
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
        
        objTerritoryController = new TerritoryListController();
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListController.getChildTerritories(objTerritoryC.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(1, lstTerritories.size() );                           
    }
    
    @isTest  
    static void territoryListControllerLevel4Test() {        
        Territorio_Administrativo__c objTerritoryC = null;
        TerritoryListController objTerritoryController = NULL;
        List<Territorio_Administrativo__c> lstTerritories = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 4
                         LIMIT 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryList')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
        
        objTerritoryController = new TerritoryListController();
        
        System.assertEquals('Level 4', objTerritoryController.territory.Name); //4
        System.assertEquals('Level 3', objTerritoryController.parentTerritory.Name); //3
        //System.assertEquals('Level 2', objTerritoryController.grandParentTerritory.Name); //2
        //System.assertEquals('Level 1', objTerritoryController.gGrandParentTerritory.Name); //1
        //System.assertEquals('Level 0', objTerritoryController.gGGrandParentTerritory.Name); //0
        System.assertEquals(NULL, objTerritoryController.grandParentTerritory.Name); //2
        System.assertEquals(NULL, objTerritoryController.gGrandParentTerritory.Name); //1
        System.assertEquals(NULL, objTerritoryController.gGGrandParentTerritory.Name); //0
        
        
        lstTerritories = (List<Territorio_Administrativo__c>)JSON.deserialize(TerritoryListController.getChildTerritories(objTerritoryC.Id), List<Territorio_Administrativo__c>.class );
        System.assertEquals(0, lstTerritories.size() );                            
    }

    @isTest  
    static void territoryListControllerRootTerritory_communityDefault() {        
        Territorio_Administrativo__c objTerritoryC = null;
        RemotingMessageHelper.Territory objTerritoryCont = TerritoryListController.retrieveRootTerritory();
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c
                         WHERE Nivel_Administrativo__c = 0
                         AND Name = 'Argentina'
                         LIMIT 1];
                         
        System.debug('Name 1: ' + objTerritoryC.Name);
        System.debug('Name 2: ' + objTerritoryCont.Name);
        System.assertEquals(objTerritoryC.Name, objTerritoryCont.Name, 'El territorio recuperado default deberia ser del nivel 0 de argentina.');
    }
    @isTest
    static void retrieveChildTerritories() {    
        Territorio_Administrativo__c objTerritoryC = [SELECT Id, Name
        FROM Territorio_Administrativo__c
        WHERE Nivel_Administrativo__c = 0
        AND Name = 'Argentina'
        LIMIT 1];

        List<Territorio_Administrativo__c> childTerritoriesListExpected = [SELECT Id, Name
                                                FROM Territorio_Administrativo__c
                                                WHERE Nivel_Administrativo__c = 1
                                                AND ParentId__c =: objTerritoryC.Id];

        Test.startTest();
        List<RemotingMessageHelper.Territory> childTerritoriesList = TerritoryListController.retrieveChildTerritories (objTerritoryC.Id, 1);
        Test.stopTest();

        System.assertEquals(childTerritoriesListExpected.size(), childTerritoriesList.size(), 'La lista de territorios hijos debe tener el tamaño adecuado.');
    }
}