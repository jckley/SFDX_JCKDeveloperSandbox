public class Pulso_Home_Controller {
    public class PulsoSurveyException extends Exception {} 
    private Survey_Setting__mdt objSurveySettings = null;
     
    public RemotingMessageHelper.Pulso pulso { get; set;}
    public RemotingMessageHelper.PulsoSurvey survey { get; set;}
    public String QSParameters { get; set; }

    public Pulso_Home_Controller() {
        String strSurveyId = null;

        objSurveySettings = HelperFunctions.retrieveSurveySettings('Pulso_CRM');
        strSurveyId = ApexPages.currentPage().getParameters().get('surveyid');
        
        if(String.isNotBlank(strSurveyId)) {
            pulso = retrievePulsoData(objSurveySettings);
            survey = retrieveSurvey(strSurveyId);
            
            QSParameters = retrieveQueryStringParameters(survey);
        } 
    }
    
    public PageReference validateOrRedirect() {
        PageReference objPage = null;
        
        if(survey == NULL) {
            objPage = new PageReference('https://pulso.social');
            objPage.setRedirect(true);
        }
        
        return objPage;
    }
    
    @RemoteAction
    public static String retrieveEncryptData(String strFacebookId) { 
        String strPlainText = null;
        Blob blbEncrypted = null;
        Survey_Setting__mdt objSurveySettings = null;
        
        objSurveySettings = HelperFunctions.retrieveSurveySettings('Pulso_CRM');
        
        strPlainText = String.format('{0}{1}', new String[] { strFacebookId, objSurveySettings.Crypto_Message_Public_Key__c } );
                
        blbEncrypted = Crypto.encrypt('AES128', Blob.valueOf(objSurveySettings.Crypto_Message_Secret_Key__c), Blob.valueOf(objSurveySettings.Crypto_Message_Public_Key__c), Blob.valueOf(strPlainText));
        
        return EncodingUtil.base64Encode(blbEncrypted);
    }
        
    private String retrieveQueryStringParameters(RemotingMessageHelper.PulsoSurvey objSurvey) {
        Set<String> setQSParameter = null;
        String strQS = null;
        
        System.debug('retrieveQueryStringParameters [objSurvey : ' + objSurvey + ']');

        strQS = '';
        if(objSurvey != NULL) {
            setQSParameter = new Set<String>();
            //agrego los parametros que no se pueden sobreescribir
            setQSParameter.add('surveyid');
            setQSParameter.add('fbid');
            setQSParameter.add('mail');
            setQSParameter.add('d');
            setQSParameter.add('pulsohash');
            
            if(ApexPages.currentPage().getParameters() != NULL && ApexPages.currentPage().getParameters().size() > 0) {
                for(String strParameter : ApexPages.currentPage().getParameters().keySet()) {

                    if(!setQSParameter.contains(strParameter) ) {
                        setQSParameter.add(strParameter);
                        strQS += '&' + strParameter + '=' + ApexPages.currentPage().getParameters().get(strParameter);
                    } 
                }
            }
                         
            if(!setQSParameter.contains('f') && String.isNotBlank(objSurvey.advertisingid)) {
                strQS += '&f=' + objSurvey.advertisingid;
            }
            
            strQS += '&d=' +  ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');    
        }            
        return strQS;
    }
          
    private RemotingMessageHelper.Pulso retrievePulsoData(Survey_Setting__mdt objSurveySettings) {
        RemotingMessageHelper.Pulso objPulso = null;
        
        System.debug('retrievePulsoData [objSurveySettings : ' + objSurveySettings + '] <-');

        objPulso = new RemotingMessageHelper.Pulso();
        
        objPulso.TypeFormUrl = objSurveySettings.TypeForm_Url__c;
        objPulso.TwitterLink = objSurveySettings.Twitter_Url__c;
        objPulso.FacebookLink = objSurveySettings.Facebook_Url__c;
        objPulso.InstagramLink = objSurveySettings.Instagram_Url__c;                        
        objPulso.Domain = objSurveySettings.Survey_Domain__c;
        
        System.debug('retrievePulsoData [' + objPulso + '] <-');
        
        return objPulso;
    }
    
    private RemotingMessageHelper.PulsoSurvey retrieveSurvey(String strSurveyId) {
        List<Encuesta__c> lstSurveys = null;        
        RemotingMessageHelper.PulsoSurvey objSurvey = null;
        
        System.debug('retrieveDefaultSurvey [] <-');
        
        if(String.isNotBlank(strSurveyId)) {
            lstSurveys = [SELECT Id, TituloEncuesta__c, TypeformId__c, Description__c, Slug__c, Number_of_Questions_View__c, Number_Of_Questions__c,AdvertinsingID__c
                            FROM Encuesta__c 
                            WHERE TypeformId__c =: strSurveyId 
                            LIMIT 1];
        } 
        
        if(!lstSurveys.isEmpty()) {  
            objSurvey =  new RemotingMessageHelper.PulsoSurvey(lstSurveys[0]);            
        }
        
        System.debug('retrieveDefaultSurvey [' + objSurvey + '] <-');

        return objSurvey;
    }
    
}