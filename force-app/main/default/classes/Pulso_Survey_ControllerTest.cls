@IsTest
public class Pulso_Survey_ControllerTest {	
    @testSetup
    private static void initializeTest() {
        createSurvey();
        createLead();
    }
    
    @IsTest
    private static void surveyPageTest() {
        Pulso_Survey_Controller objPulsoSurvey = null;
        Encuesta__c objSurvey = null;
        Lead objLead = null;
        
        objSurvey = [SELECT Id, Name, TituloEncuesta__c, Number_Of_Answered_Questions__c,Number_Of_Answering_Users__c,Number_Of_Questions__c
                       FROM Encuesta__c];
        objLead = [SELECT Id, FirstName, LastName, MobilePhone, Email 
                   FROM Lead];
        
        ApexPages.currentPage().getParameters().put('leadid', objLead.Id);
        ApexPages.currentPage().getParameters().put('survey', objSurvey.Id);

        objPulsoSurvey = new Pulso_Survey_Controller();
        
        //System.assertEquals(objPulsoSurvey.survey.Id, objSurvey.Id);
		
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
    
    private static void createLead() {
        Lead objLead = null;
        
        objLead = new Lead();
        objLead.FirstName = 'Juan';
        objLead.LastName = 'Perez';
        objLead.Company = 'SurveyCRM';
        objLead.Email = 'juanperez@salesforce.com';
        objLead.MobilePhone = '11122233';
        
        insert objLead; 
    }
}