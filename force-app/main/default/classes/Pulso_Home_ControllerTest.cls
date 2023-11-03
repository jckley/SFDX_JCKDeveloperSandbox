@IsTest
private class Pulso_Home_ControllerTest {
	
    @testSetup
    private static void initializeTest() {
        Territorio_Administrativo__c objTerritoryLevel0 = null;
        Territorio_Administrativo__c objTerritoryLevel1 = null;
        Territorio_Administrativo__c objTerritoryLevel2 = null;
 
        createSurvey();
        objTerritoryLevel0 = createTerritory( 0, 'Level 0', NULL);
        objTerritoryLevel1 = createTerritory( 1, 'Level 1', objTerritoryLevel0.Id);
        objTerritoryLevel2 = createTerritory( 2, 'Level 2', objTerritoryLevel1.Id);
    }
    
    @IsTest
    private static void homePageTest() {
        PageReference objPulsoHomeVF = null;
        Pulso_Home_Controller objPulsoHome = null;
        Encuesta__c objEncuesta = null;
        Territorio_Administrativo__c objTerritoryLevel0 = null;
        Territorio_Administrativo__c objTerritoryLevel1 = null;
        Territorio_Administrativo__c objTerritoryLevel2 = null;
        
        objPulsoHomeVF = Page.PulsoHome;
                        
        objEncuesta = [SELECT Id, Name,TypeformId__c, TituloEncuesta__c, Number_Of_Answered_Questions__c,Number_Of_Answering_Users__c,Number_Of_Questions__c
                       FROM Encuesta__c];

        objPulsoHomeVF.getParameters().put('surveyid',objEncuesta.TypeformId__c);
        Test.setCurrentPage(objPulsoHomeVF);
        objPulsoHome = new Pulso_Home_Controller();
        
        System.assertEquals(objEncuesta.TypeformId__c, objPulsoHome.survey.typeformid);
        System.assertEquals(NULL, objPulsoHome.validateOrRedirect());
        Pulso_Home_Controller.retrieveEncryptData('11111111');
        
        objTerritoryLevel0 = [SELECT Id FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c = 0];
        objTerritoryLevel1 = [SELECT Id FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c = 1];
        objTerritoryLevel2 = [SELECT Id FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c = 2];
        

        System.assertEquals(objTerritoryLevel0.Id, Pulso_Contact_Modal_Controller.retrieveTerritories(0, null)[0].Id);
        System.assertEquals(objTerritoryLevel1.Id, Pulso_Contact_Modal_Controller.retrieveTerritories(1, objTerritoryLevel0.Id)[0].Id);
        System.assertEquals(objTerritoryLevel2.Id, Pulso_Contact_Modal_Controller.retrieveTerritories(2, objTerritoryLevel1.Id)[0].Id);
    }
    
    private static void createSurvey() {
        Encuesta__c objEncuesta = null;
        
        objEncuesta = new Encuesta__c();
        objEncuesta.TituloEncuesta__c = 'Title test';
        objEncuesta.TypeformId__c = 'mytypeformid';
        objEncuesta.Description__c = 'My Survey description'; 
        objEncuesta.Slug__c = 'test';
        objEncuesta.Default_Survey__c = true;
        objEncuesta.TypeformResultsId__c = 'test'; 
            
        insert objEncuesta;
    }
    
    private static Territorio_Administrativo__c createTerritory(Integer intLevel, String strName, String strParentId) {
        Territorio_Administrativo__c objTerritory = null;
        
        objTerritory = new Territorio_Administrativo__c();
        objTerritory.Nivel_Administrativo__c = intLevel;
        objTerritory.Name = strName;
        objTerritory.Location_UUID__c = strName; 
        if(String.isNotBlank(strParentId)) {
            objTerritory.ParentId__c = strParentId;
        }
        
        insert objTerritory;
        
        return objTerritory;
    }
}