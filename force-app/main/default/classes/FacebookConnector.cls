public class FacebookConnector {
    public class FacebookConnectorException extends Exception {} 
    public String ApplicationId { get; set; }
    public String PixelId { get; set; }
    public String Version { get; set; }
    
    public FacebookConnector() {       
        System.debug('FacebookConnector [] ->');

        Survey_Setting__mdt objSurveySettings = NULL;
        
        objSurveySettings = HelperFunctions.retrieveSurveySettings('Pulso_CRM');
        if(objSurveySettings != NULL) {
            this.ApplicationId = objSurveySettings.Facebook_Application_Id__c.toPlainString();
            this.Version = objSurveySettings.Facebook_API_Version__c;
            this.PixelId = objSurveySettings.Facebook_Pixel_Id__c;
        } else {
            throw new FacebookConnectorException(Label.FacebookConnector_NoApplicationDefined);
        }
        
        System.debug('FacebookConnector [] <-');
    }
}