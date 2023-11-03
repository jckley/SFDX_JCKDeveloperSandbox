@IsTest
private class TypeformAPITest {
    
    @testSetup 
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
        createTypeformsSettings();
        createSurvey();
    }
    
    @IsTest
    private static void testTypeform() {
        TypeformAPI.retrieveAuthorizationUrl();
        TypeformAPI.retrieveIsAuthenticated();        
        TypeformAPI.retrieveCredentials();
    
    }
    
    @IsTest
    private static void testTypeformTest1() {
        TypeformSettings__c objTypeformSettings = null;
        Test.setMock(HttpCalloutMock.class, new TypeformMock(TypeformMock.REQUEST_TYPE.ANSWERS));
                
        objTypeformSettings = [SELECT Id FROM TypeformSettings__c LIMIT 1];
        
        objTypeformSettings.Access_Token__c = '111';
        objTypeformSettings.Code__c = '22';
        objTypeformSettings.Expires__c = DateTime.now().addDays(7);
        objTypeformSettings.Name = 'PulsoCRM';
        objTypeformSettings.Refresh_Token__c = 'test';
        update objTypeformSettings;
        Test.startTest();
        TypeformAPI.retrieveTypeformAnswers('ljImzD');
        Test.stopTest();
    }
    
    @IsTest
    private static void testTypeformRefreshToken() {
        TypeformSettings__c objTypeformSettings = null;
        Test.setMock(HttpCalloutMock.class, new TypeformMock(TypeformMock.REQUEST_TYPE.REFRESH_TOKEN));
                
        objTypeformSettings = [SELECT Id FROM TypeformSettings__c LIMIT 1];
        
        objTypeformSettings.Access_Token__c = '111';
        objTypeformSettings.Code__c = '22';
        objTypeformSettings.Expires__c = DateTime.now().addDays(-7);
        objTypeformSettings.Name = 'PulsoCRM';
        objTypeformSettings.Refresh_Token__c = 'test';
        update objTypeformSettings;
        Test.startTest();
        TypeformAPI.retrieveToken();
        Test.stopTest();
    }
    @IsTest
    private static void testTypeformTest2() {        
        Test.setMock(HttpCalloutMock.class, new TypeformMock(TypeformMock.REQUEST_TYPE.SURVEY));            
        Test.startTest();
        
        TypeformAPI.retrieveTypeformSurvey('ljImzD');
        Test.stopTest();
    }
    @IsTest
    private static void testTypeformTest3() {
        Test.setMock(HttpCalloutMock.class, new TypeformMock(TypeformMock.REQUEST_TYPE.TOKEN));
        Test.startTest();
        TypeformAPI.retrieveToken();
        Test.stopTest();
    }        
    
    private static void createTypeformsSettings() {
        TypeformSettings__c objTypeformSettings = null;
        
        objTypeformSettings = new TypeformSettings__c();
        objTypeformSettings.Code__c = 'pepe';
        objTypeformSettings.SetupOwnerId = UserInfo.getOrganizationId();
        insert objTypeformSettings;
    }
    
    private static void createSurvey() {
        Encuesta__c objEncuesta = null;
        
        objEncuesta = new Encuesta__c();
        objEncuesta.Description__c = 'test'; 
        objEncuesta.TituloEncuesta__c = 'test';
        objEncuesta.Slug__c = 'test';
        objEncuesta.TypeformId__c = 'ljImzD';
        objEncuesta.AdvertinsingID__c = 'ljImzD';
        objEncuesta.TypeformResultsId__c = 'ljImzD';
        
        insert objEncuesta;     

        createQuestions(objEncuesta);
        createAvailableOptions();
    }
    
    private static void createQuestions(Encuesta__c objSurvey) {
        List<RemotingMessageHelper.TypeformSurveyReponseItemAnswerField> lstQuestions = null;
        List<Survey_Question__c> lstSurveyQuestions = null;
        Survey_Question__c objSurveyQuestions = null;

        lstQuestions = retrieveQuestions();
        lstSurveyQuestions = new List<Survey_Question__c>();

        for (RemotingMessageHelper.TypeformSurveyReponseItemAnswerField objQuestion : lstQuestions) {
            objSurveyQuestions = new Survey_Question__c();
            objSurveyQuestions.Title__c = 'test';
            objSurveyQuestions.Survey__c = objSurvey.Id;
            objSurveyQuestions.Question_Type__c = objQuestion.type;
            objSurveyQuestions.TypeformId__c = objQuestion.id;
            lstSurveyQuestions.add(objSurveyQuestions);            
        }
        insert lstSurveyQuestions;                        
    }
    
    private static void createAvailableOptions() {
        List<Survey_Available_Option__c> lstSurveyAvailableOptions = null;
        Survey_Available_Option__c objSurveyAvailableOptions = null;
        List<String> lstAvailableOptions = null;
        
        lstAvailableOptions = retrieveAvailableOptions();
        
        lstSurveyAvailableOptions = new List<Survey_Available_Option__c>();     
        for(String strOption : lstAvailableOptions) {
            objSurveyAvailableOptions = new Survey_Available_Option__c();
            objSurveyAvailableOptions.Survey_Question__r = new Survey_Question__c(TypeformId__c = strOption.substring(0, 12)) ;
            objSurveyAvailableOptions.Index__c = 1;
            objSurveyAvailableOptions.TypeformId__c = strOption;
            objSurveyAvailableOptions.Survey_Option__c = strOption;
          
            lstSurveyAvailableOptions.add(objSurveyAvailableOptions);
        }
        
        insert lstSurveyAvailableOptions;
    }
    
    private static List<RemotingMessageHelper.TypeformSurveyReponseItemAnswerField> retrieveQuestions() {
        List<RemotingMessageHelper.TypeformSurveyReponseItemAnswerField> lstQuestions = null;
        RemotingMessageHelper.TypeformSurveyReponseItemAnswerField objQuestion = null;
        
        lstQuestions = new List<RemotingMessageHelper.TypeformSurveyReponseItemAnswerField>();
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'j4tOubMhqqk5';
        objQuestion.type = 'dropdown';
        lstQuestions.add(objQuestion);
        
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'flL8rhALAm7F';
        objQuestion.type = 'opinion_scale';
        lstQuestions.add(objQuestion);
        
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'Pv4ox3eq6w6q';
        objQuestion.type = 'picture_choice';
        lstQuestions.add(objQuestion);
        
        
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'OrNRkZzP65yI';
        objQuestion.type = 'picture_choice';
        lstQuestions.add(objQuestion);
        
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'FF0IE3XQYH9N';
        objQuestion.type = 'multiple_choice';
        lstQuestions.add(objQuestion);
        
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'rNJtO0fDfnWA';
        objQuestion.type = 'multiple_choice';
        lstQuestions.add(objQuestion);
        
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'XOf93LmZpZOW';
        objQuestion.type = 'picture_choice';
        lstQuestions.add(objQuestion);
        
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'iI5EjTBpMch3';
        objQuestion.type = 'picture_choice';
        lstQuestions.add(objQuestion);
        
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'LfNvoF59ttkG';
        objQuestion.type = 'picture_choice';
        lstQuestions.add(objQuestion);
        
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'bl8W2VmQZQt9';
        objQuestion.type = 'picture_choice';
        lstQuestions.add(objQuestion);
        
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'SqM4YLnnhV1S';
        objQuestion.type = 'picture_choice';
        lstQuestions.add(objQuestion);
        
        objQuestion = new RemotingMessageHelper.TypeformSurveyReponseItemAnswerField();
        objQuestion.id = 'HzgYGlAfwWPd';
        objQuestion.type = 'dropdown';
        lstQuestions.add(objQuestion);
        
        return lstQuestions;
    }
 
    private static List<String> retrieveAvailableOptions() {
        List<String> lstAnswers = null;
        
        lstAnswers = new List<String>();
        lstAnswers.add('j4tOubMhqqk5Córdoba');
        lstAnswers.add('flL8rhALAm7F10');
        lstAnswers.add('Pv4ox3eq6w6qBuena');
        lstAnswers.add('OrNRkZzP65yIMala');
        lstAnswers.add('FF0IE3XQYH9NReducción del gasto público');
        lstAnswers.add('rNJtO0fDfnWA...que sea parte de la política actual');
        lstAnswers.add('XOf93LmZpZOWCambiemos');
        lstAnswers.add('iI5EjTBpMch3Mauricio Macri');
        lstAnswers.add('LfNvoF59ttkGMauricio Macri');
        lstAnswers.add('bl8W2VmQZQt9José Luis Espert');
        lstAnswers.add('SqM4YLnnhV1SMauricio Macri');
        lstAnswers.add('HzgYGlAfwWPdBuenos Aires');
        
        return lstAnswers;
    }
  
}