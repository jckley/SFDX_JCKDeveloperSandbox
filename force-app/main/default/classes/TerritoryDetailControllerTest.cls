/**
* Class Name: TerritoryDetailControllerTest
* Description: Test Class for the TerritoryDetailController
* Developer: Luis Puentes - Date: 06/06/2018
*/

@isTest
public class TerritoryDetailControllerTest {    
    @testSetup
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
    }    
    
    @isTest
    private static void retrieveTerritoryTest() {
        RemotingMessageHelper.TerritoryInfo objTerritoryInfo = null;
        Id objTerritoryId = null;
            
        objTerritoryId = [SELECT ID FROM Territorio_Administrativo__c LIMIT 1].Id;
        TerritoryDetailController.retrieveTerritory(objTerritoryId,'prosumia');
    }
    
    @isTest  
    static void territoryStandardControllerTest() {      
        Territorio_Administrativo__c objTerritoryC = null;
        
        ApexPages.StandardController objStandardController = null;
        TerritoryDetailController objTerritoryController = null;
        TerritoryDetailController objTerritoryControllerEmpty = null;
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
        objTerritoryController = new TerritoryDetailController (objStandardController);
        objTerritoryControllerEmpty = new TerritoryDetailController();
        
        objTerritoryRootWrapper = TerritoryDetailController.getRootTerritoryInfo();
        System.assertEquals(objTerritoryC.Name, objTerritoryRootWrapper.territoryName);
        
       	objTerritoryWrapper = TerritoryDetailController.getTerritoryById(objTerritoryC.Id);
        System.assertEquals(objTerritoryC.Name, objTerritoryWrapper.territoryName);
       	TerritoryWrapper2 objTerritoryWrapper2 = TerritoryDetailController.getTerritoryById2(objTerritoryC.Id);             
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
        
        TerritoryDetailController ter = new TerritoryDetailController();
        TerritoryWrapper2 objTerritoryWrapper2 = TerritoryDetailController.getTerritoryById2(objTerritoryC1.Id);             

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
        
        TerritoryDetailController ter = new TerritoryDetailController();
        TerritoryWrapper2 objTerritoryWrapper2 = TerritoryDetailController.getTerritoryById2(objTerritoryC2.Id);             

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
        
        TerritoryDetailController ter = new TerritoryDetailController();
        TerritoryWrapper2 objTerritoryWrapper2 = TerritoryDetailController.getTerritoryById2(objTerritoryC3.Id);             

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
        
        TerritoryDetailController ter = new TerritoryDetailController();
        TerritoryWrapper2 objTerritoryWrapper2 = TerritoryDetailController.getTerritoryById2(objTerritoryC4.Id);             

    }
}