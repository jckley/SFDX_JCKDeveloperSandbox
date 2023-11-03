/**
* Class Name: TerritoryDetailChileControllerTest
* Description: Test Class for the TerritoryDetailChileController
* Developer: José Gerstner - Date: 24/02/2022
*/

@isTest
public class TerritoryDetailChileControllerTest {    
    @testSetup
    private static void setupTest() {
        CommonTestFunctions.commonChileSetup();
    }    
    
    @isTest
    private static void retrieveTerritoryTest() {
        RemotingMessageHelper.TerritoryInfo objTerritoryInfo = null;
        Id objTerritoryId = null;
            
        objTerritoryId = [SELECT ID FROM Territorio_Administrativo__c LIMIT 1].Id;
        TerritoryDetailChileController.retrieveTerritory(objTerritoryId,'prosumia');
    }
    
    @isTest  
    static void territoryStandardControllerTest() {      
        Territorio_Administrativo__c objTerritoryC = null;
        
        ApexPages.StandardController objStandardController = null;
        TerritoryDetailChileController objTerritoryController = null;
        TerritoryDetailChileController objTerritoryControllerEmpty = null;
        TerritoryWrapper objTerritoryWrapper = null;
        TerritoryWrapper objTerritoryRootWrapper = null;
        List<RemotingMessageHelper.Territory> lstTerritories = null;
        
        objTerritoryC = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 0 
                         LIMIT 1];
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.TerritoryDetailComponents')); 
        System.currentPageReference().getParameters().put('id', objTerritoryC.Id);
        System.currentPageReference().getParameters().put('terrId', objTerritoryC.Id);
        
        objStandardController = new ApexPages.StandardController(objTerritoryC);
        objTerritoryController = new TerritoryDetailChileController (objStandardController);
        objTerritoryControllerEmpty = new TerritoryDetailChileController();
        
        objTerritoryRootWrapper = TerritoryDetailChileController.getRootTerritoryInfo();
        System.assertEquals(objTerritoryC.Name, objTerritoryRootWrapper.territoryName);
        
       	objTerritoryWrapper = TerritoryDetailChileController.getTerritoryById(objTerritoryC.Id);
        System.assertEquals(objTerritoryC.Name, objTerritoryWrapper.territoryName);
       	TerritoryWrapper objTerritoryWrapper2 = TerritoryDetailChileController.getTerritoryById(objTerritoryC.Id);             
        Test.stopTest();
    }
    
    @isTest  
    static void territoryLvl1Test() {
        Territorio_Administrativo__c objTerritoryC1 = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 1 
                         LIMIT 1];
        
        PageReference myVfPage = Page.TerritoryDetailComponents;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',objTerritoryC1.Id);
        
        TerritoryDetailChileController ter = new TerritoryDetailChileController();
        TerritoryWrapper objTerritoryWrapper2 = TerritoryDetailChileController.getTerritoryById(objTerritoryC1.Id);             

    }
    
    @isTest  
    static void territoryLvl2Test() {
        Territorio_Administrativo__c objTerritoryC2 = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 2 
                         LIMIT 1];
        
        PageReference myVfPage = Page.TerritoryDetailComponents;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',objTerritoryC2.Id);
        
        TerritoryDetailChileController ter = new TerritoryDetailChileController();
        TerritoryWrapper objTerritoryWrapper2 = TerritoryDetailChileController.getTerritoryById(objTerritoryC2.Id);             

    }
    
    @isTest  
    static void territoryLvl3Test() {
        Territorio_Administrativo__c objTerritoryC3 = [SELECT Id, Name
                         FROM Territorio_Administrativo__c 
                         WHERE Nivel_Administrativo__c = 3 
                         LIMIT 1];
        
        PageReference myVfPage = Page.TerritoryDetailComponents;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',objTerritoryC3.Id);
        
        TerritoryDetailChileController ter = new TerritoryDetailChileController();
        TerritoryWrapper objTerritoryWrapper2 = TerritoryDetailChileController.getTerritoryById(objTerritoryC3.Id);             

    }
    
    @isTest  
    static void territoryLvl4Test() {
        Territorio_Administrativo__c objTerritoryC4 = [SELECT Id, Name
                          FROM Territorio_Administrativo__c 
                          WHERE Nivel_Administrativo__c = 4 
                          LIMIT 1];
        
        PageReference myVfPage = Page.TerritoryDetailComponents;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',objTerritoryC4.Id);
        
        TerritoryDetailChileController ter = new TerritoryDetailChileController();
        TerritoryWrapper objTerritoryWrapper2 = TerritoryDetailChileController.getTerritoryById(objTerritoryC4.Id);             

    }
}