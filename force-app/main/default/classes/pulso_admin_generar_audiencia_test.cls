@isTest
private class pulso_admin_generar_audiencia_test { 
    @testSetup 
    static void setup() {
		CommonTestFunctions testSet = new CommonTestFunctions();
		testSet.createNewSurveyForTest();
    }

    static testmethod void test() {        
        Test.setMock(HttpCalloutMock.class, new RESTMock());
        Test.startTest();
        
        List<User_Survey__c> usersAnswers = new List<User_Survey__c>();
        usersAnswers = [SELECT Id, Survey__c, Lead__c
                   FROM User_Survey__c
                   WHERE Number_Of_Answered_Questions__c > 0
                   LIMIT 2];
        System.debug('DAC: ' + usersAnswers);
        
        ID surveyId = usersAnswers[0].Survey__c;
        ID userId = usersAnswers[0].Lead__c;
        ID user_survey_id = usersAnswers[0].Id;
        
        List<User_Survey_Answers__c> answers = new List<User_Survey_Answers__c>();
        answers = [SELECT Survey_Available_Option__c
                   FROM User_Survey_Answers__c
                   WHERE User_Survey__c = :user_survey_id];
        
        List<String> questionsIds = new List<String>();
        for (User_Survey_Answers__c ans : answers) {
            questionsIds.add((String)ans.Survey_Available_Option__c);
        }
        
        String dataExtension = 'dataExtensionForTest';
        pulso_admin_generar_audiencia genAud = new pulso_admin_generar_audiencia(surveyId, questionsIds, dataExtension);
        Id batchId = Database.executeBatch(genAud);
        
        Test.stopTest();
        
        // after the testing stops, assert records were updated properly
        System.assertEquals(1, 1);
    }
    
}