public class Pulso_Survey_Controller {
    public class PulsoSurveyException extends Exception {} 
    private Survey_Setting__mdt objSurveySettings = null;
    
    public RemotingMessageHelper.FacebookUser user { get; set;}
    public RemotingMessageHelper.Pulso pulso { get; set;}
    public RemotingMessageHelper.PulsoSurvey survey { get; set;}
    
    public Pulso_Survey_Controller() {
        String strSurveyId = null;
        String strLeadId = null;
        Lead objLead = null;
        
        System.debug('Pulso_Survey_Controller [] ->');
        
        strSurveyId = ApexPages.currentPage().getParameters().get('surveyid');
        strLeadId = ApexPages.currentPage().getParameters().get('leadid');
        
        if(String.isNotBlank(strSurveyId) && String.isNotBlank(strLeadId) ) {
            try {
                objSurveySettings = HelperFunctions.retrieveSurveySettings('Pulso_CRM');    
                if(objSurveySettings != NULL) {                     
                    objLead = retrieveLead(strLeadId);
                    
                    user = new RemotingMessageHelper.FacebookUser(objLead);
                    pulso = retrievePulsoData(objSurveySettings);
                    survey = retrieveSurvey(strSurveyId);
                } else {
                    throw new PulsoSurveyException(Label.FacebookConnector_NoApplicationDefined);
                }
            } catch(Exception Ex) {
                HelperFunctions.handleRuntimeException(Ex);
                throw new PulsoSurveyException(Ex.getMessage());
            }
        }
        
        System.debug('Pulso_Survey_Controller [] <-');
    }
    
    private Lead retrieveLead(Id strLeadId) {
        Lead objLead = null;
        List<Lead> lstLeads = null;
        
        System.debug('retrieveLead [strLeadId : ' + strLeadId + '] ->');

        lstLeads = [SELECT Id, FirstName, LastName, Email, FacebookId__c 
                    FROM Lead 
                    WHERE Id =: strLeadId];
        
        if(!lstLeads.isEmpty()) {
            objLead = lstLeads[0];
        }
        
        System.debug('retrieveLead [' + objLead + '] <-');
        
        return objLead;
    }
    
    private RemotingMessageHelper.Pulso retrievePulsoData(Survey_Setting__mdt objSurveySettings) {
        RemotingMessageHelper.Pulso objPulso = null;
        
        System.debug('retrievePulsoData [objSurveySettings : ' + objSurveySettings + '] <-');

        objPulso = new RemotingMessageHelper.Pulso();
        
        objPulso.TypeFormUrl = objSurveySettings.TypeForm_Url__c;
        objPulso.TwitterLink = objSurveySettings.Twitter_Url__c;
        objPulso.FacebookLink = objSurveySettings.Facebook_Url__c;
        objPulso.InstagramLink = objSurveySettings.Instagram_Url__c;                        
        
        System.debug('retrievePulsoData [' + objPulso + '] <-');
        
        return objPulso;
    }
    
    private RemotingMessageHelper.PulsoSurvey retrieveSurvey(String strSurveyId) {
        List<Encuesta__c> lstSurveys = null;        
        RemotingMessageHelper.PulsoSurvey objSurvey = null;
        
        System.debug('retrieveSurvey [strSurveyId : ' + strSurveyId + '] <-');
        
        lstSurveys = [SELECT Id, TituloEncuesta__c, TypeformId__c, Description__c, Slug__c, Number_Of_Questions__c
                        FROM Encuesta__c 
                        WHERE Id =:  strSurveyId];
        
        if(!lstSurveys.isEmpty()) {  
            objSurvey =  new RemotingMessageHelper.PulsoSurvey(lstSurveys[0]);            
        }
        
        System.debug('retrieveSurvey [' + objSurvey + '] <-');
        
        return objSurvey;
    }
}