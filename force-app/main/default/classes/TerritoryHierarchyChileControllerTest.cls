/**
* ClassName: TerritoryHierarchyChileControllerTest
* Description: Test class for the territory list view
* Developer: José Gerstner - Date: 24/02/2022
*/

@isTest
public class TerritoryHierarchyChileControllerTest {
    
    @testSetup
    static void setup(){		
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        Territorio_Administrativo__c terr = new Territorio_Administrativo__c();
        terr.Location_UUID__c = 'TEST';
        terr.Nivel_Administrativo__c = 0;
        terr.Name = 'Chile';
        insert terr;
        /*Test Setup */
        Territorio_Administrativo__c terr2 = new Territorio_Administrativo__c();
        terr2.Location_UUID__c = 'TEST 2';
        terr2.Nivel_Administrativo__c = 1;
        terr2.Name = 'TEST 2';
		terr2.ParentId__c = terr.Id;
        insert terr2;
        Territorio_Administrativo__c terr3 = new Territorio_Administrativo__c();
        terr3.Location_UUID__c = 'TEST 3';
        terr3.Nivel_Administrativo__c = 2;
        terr3.Name = 'TEST 3';
        terr3.ParentId__c = terr2.Id;
        insert terr3;
        Territorio_Administrativo__c terr4 = new Territorio_Administrativo__c();
        terr4.Location_UUID__c = 'TEST 4';
        terr4.Nivel_Administrativo__c = 3;
        terr4.Name = 'TEST 4';
        terr4.ParentId__c = terr3.Id;
        insert terr4;
        Territorio_Administrativo__c terr5 = new Territorio_Administrativo__c();
        terr5.Location_UUID__c = 'TEST 5';
        terr5.Nivel_Administrativo__c = 4;
        terr5.Name = 'TEST 5';
        terr5.ParentId__c = terr4.Id;
        insert terr5;
        sessionPart.put('UserRoleLevel', 0);
		sessionPart.put('SelTer1', terr2.Id);
        sessionPart.put('SelTer1Parent', terr2.ParentId__c);
        sessionPart.put('SelTer2', terr3.Id);
        sessionPart.put('SelTer2Parent', terr3.ParentId__c);
        sessionPart.put('SelTer3', terr4.Id);
        sessionPart.put('SelTer3Parent', terr4.ParentId__c);
        sessionPart.put('SelTer4', terr5.Id);
        sessionPart.put('SelTer4Parent', terr5.ParentId__c);
        sessionPart.put('ComesFrom', 'URL');       
    }
    
    @isTest 
    static void testConstructor() {
        Territorio_Administrativo__c ter = [SELECT Id, Name, ParentId__c, Nivel_Administrativo__c FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c = 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryHierarchyChile')); 
        System.currentPageReference().getParameters().put('id', ter.Id);
        System.currentPageReference().getParameters().put('al', '1');
        System.currentPageReference().getHeaders().put('User-Agent', 'Mobile');
        TerritoryHierarchyChileController terCon = new TerritoryHierarchyChileController();
        TerritoryHierarchyChileController.getChildTerritories(ter.Id, ter.ParentId__c);
        TerritoryHierarchyChileController.saveSelectedTerritory(ter.Id, ter.ParentId__c, ter.Nivel_Administrativo__c);
        terCon.removeSessionData();
        terCon.redirect();
    }
    
    @isTest 
    static void testConstructor2() {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        sessionPart.put('ComesFrom', 'Standard');
        Territorio_Administrativo__c ter = [SELECT Id, Name, ParentId__c, Nivel_Administrativo__c FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c = 1];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryHierarchyChile')); 
        System.currentPageReference().getParameters().put('id', ter.Id);
        System.currentPageReference().getParameters().put('al', '1');
        System.currentPageReference().getHeaders().put('User-Agent', 'Mobile');
        TerritoryHierarchyChileController terCon = new TerritoryHierarchyChileController();
        TerritoryHierarchyChileController.getChildTerritories(ter.Id, ter.ParentId__c);
        TerritoryHierarchyChileController.saveSelectedTerritory(ter.Id, ter.ParentId__c, ter.Nivel_Administrativo__c);
        terCon.removeSessionData();
        terCon.redirect();
    }
    
    @isTest 
    static void testConstructor3() {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        sessionPart.put('ComesFrom', 'Standard');
        Territorio_Administrativo__c ter = [SELECT Id, Name, ParentId__c, Nivel_Administrativo__c FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c = 2];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryHierarchyChile')); 
        System.currentPageReference().getParameters().put('id', ter.Id);
        System.currentPageReference().getParameters().put('al', '2');
        System.currentPageReference().getHeaders().put('User-Agent', 'Mobile');
        TerritoryHierarchyChileController terCon = new TerritoryHierarchyChileController();
        TerritoryHierarchyChileController.getChildTerritories(ter.Id, ter.ParentId__c);
        TerritoryHierarchyChileController.saveSelectedTerritory(ter.Id, ter.ParentId__c, ter.Nivel_Administrativo__c);
        terCon.removeSessionData();
        terCon.redirect();
    }
    
    @isTest 
    static void testConstructor4() {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        sessionPart.put('ComesFrom', 'Standard');
        Territorio_Administrativo__c ter = [SELECT Id, Name, ParentId__c, Nivel_Administrativo__c FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c = 3];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryHierarchyChile')); 
        System.currentPageReference().getParameters().put('id', ter.Id);
        System.currentPageReference().getParameters().put('al', '3');
        System.currentPageReference().getHeaders().put('User-Agent', 'Mobile');
        TerritoryHierarchyChileController terCon = new TerritoryHierarchyChileController();
        TerritoryHierarchyChileController.getChildTerritories(ter.Id, ter.ParentId__c);
        TerritoryHierarchyChileController.saveSelectedTerritory(ter.Id, ter.ParentId__c, ter.Nivel_Administrativo__c);
        terCon.removeSessionData();
        terCon.redirect();
    }
    
    @isTest 
    static void testConstructor5() {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        sessionPart.put('ComesFrom', 'Standard');
        Territorio_Administrativo__c ter = [SELECT Id, Name, ParentId__c, Nivel_Administrativo__c FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c = 4];
        Test.setCurrentPageReference(new PageReference('Page.TerritoryHierarchyChile')); 
        System.currentPageReference().getParameters().put('id', ter.Id);
        System.currentPageReference().getParameters().put('al', '4');
        System.currentPageReference().getHeaders().put('User-Agent', 'Mobile');
        TerritoryHierarchyChileController terCon = new TerritoryHierarchyChileController();
        TerritoryHierarchyChileController.getChildTerritories(ter.Id, ter.ParentId__c);
        TerritoryHierarchyChileController.saveSelectedTerritory(ter.Id, ter.ParentId__c, ter.Nivel_Administrativo__c);
        terCon.removeSessionData();
        terCon.redirect();
    }
    
    @isTest    
    private static void retrieveTerritoriesByParentTest() {
        Territorio_Administrativo__c objTerritory = null;
        
        objTerritory = [SELECT ID 
                        FROM Territorio_Administrativo__c 
                        WHERE Nivel_Administrativo__c = 1];
        System.assertEquals(0, TerritoryHierarchyChileController.retrieveParentTerritory().Level) ;
        
        System.assertEquals(1, TerritoryHierarchyChileController.retrieveTerritoriesByParent(NULL).size()) ;
        System.assertEquals(1, TerritoryHierarchyChileController.retrieveTerritoriesByParent(objTerritory.Id).size()) ; 
        
        TerritoryHierarchyChileController.saveLastSelectedTerritory(objTerritory.Id);
        System.assertEquals(1, TerritoryHierarchyChileController.retrieveTerritoriesByParent(objTerritory.Id).size()) ;
        TerritoryHierarchyChileController.clearLastSelectedTerritory();
    }
}