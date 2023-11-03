@IsTest
private class PulsoUrlRewriterTest {
    @testSetup
    private static void initializeTest() { 
    	Encuesta__c objEncuesta = null;
        
        objEncuesta = new Encuesta__c();
        objEncuesta.Slug__c = 'test';
        objEncuesta.TituloEncuesta__c = 'test'; 
        objEncuesta.TypeformId__c = 'test'; 
        objEncuesta.Description__c = 'test';
        objEncuesta.TypeformResultsId__c = 'test';
        
        insert objEncuesta;
    }
    
    @IsTest
    private static void urlRewriterTest() {
        PageReference objFriendlyPageReference = null;
        PageReference objUglyPageReference = null;
        PulsoUrlRewriter objPulsoUrlRewriter = null;
        Survey_Setting__mdt objSurveySettings = null;
        String strUglyUrl = null;
        List<Encuesta__c> lstSurveys = null;
        List<PageReference> lstPageReferences = null;

        objSurveySettings = HelperFunctions.retrieveSurveySettings('Pulso_CRM');
        lstSurveys = [SELECT TypeformId__c, Slug__c FROM Encuesta__c LIMIT 1]; 

        objFriendlyPageReference = new PageReference(objSurveySettings.UrlRewriterPath__c + lstSurveys[0].Slug__c);
        objPulsoUrlRewriter = new PulsoUrlRewriter();        
        objUglyPageReference = objPulsoUrlRewriter.mapRequestUrl(objFriendlyPageReference);
        
        System.assertEquals(objSurveySettings.UrlRewriterVF__c + lstSurveys[0].TypeformId__c , objUglyPageReference.getUrl());        
        
        lstPageReferences = new  List<PageReference> ();
        lstPageReferences.add(new PageReference(objSurveySettings.UrlRewriterVF__c + lstSurveys[0].TypeformId__c));
        objFriendlyPageReference = objPulsoUrlRewriter.generateUrlFor(lstPageReferences)[0];
        
        System.assertEquals(objSurveySettings.UrlRewriterPath__c + lstSurveys[0].Slug__c , objFriendlyPageReference.getUrl());                
    }
    
    /*
    @IsTest
    private static void urlRewriterTest() {
        PageReference objFriendlyPageReference = null;
        PageReference objUglyPageReference = null;
        PulsoUrlRewriter objPulsoUrlRewriter = null;
        List<PageReference> lstPageReferences = null;
        List<Encuesta__c> lstSurveys = null;
        Survey_Setting__mdt objSurveySettings = null;
        
        objSurveySettings = HelperFunctions.retrieveSurveySettings('Pulso_CRM');
        
        lstPageReferences = new  List<PageReference> ();
        lstSurveys = [SELECT ID FROM Encuesta__c LIMIT 1];
        lstPageReferences.add(new PageReference(objSurveySettings.UrlRewriterVF__c + '?surveyid=' + lstSurveys[0].Id));
        
        objFriendlyPageReference = new PageReference(objSurveySettings.UrlRewriterPath__c + '/test/');
        objPulsoUrlRewriter = new PulsoUrlRewriter();        
        objUglyPageReference = objPulsoUrlRewriter.mapRequestUrl(objFriendlyPageReference);
        
        System.assert(condition)
        objPulsoUrlRewriter.generateUrlFor(lstPageReferences);
    }*/
}