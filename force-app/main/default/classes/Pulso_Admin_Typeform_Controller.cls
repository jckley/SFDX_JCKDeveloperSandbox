public class Pulso_Admin_Typeform_Controller{
    @RemoteAction
    public static Boolean retrieveTypeformStatus() {
        Boolean boolIsAutheticated = null;
        
        System.debug('retrieveTypeformStatus [] ->'); 
        
        boolIsAutheticated = TypeformAPI.retrieveIsAuthenticated();
                
        System.debug('retrieveTypeformStatus [' + boolIsAutheticated  + '] <-'); 
        
        return boolIsAutheticated;
    }
    
    @RemoteAction
    public static String retrieveAuthorizationUrl() {
        String strAuthorizationUrl = null;
        
        System.debug('retrieveAuthorizationUrl [] ->'); 
        
        strAuthorizationUrl = TypeformAPI.retrieveAuthorizationUrl();
        
        System.debug('retrieveAuthorizationUrl [' + strAuthorizationUrl  + '] <-'); 
        
        return strAuthorizationUrl;
    }
    
    @RemoteAction
    public static RemotingMessageHelper.OperationResult saveAuthorizationCode(String strCode) { 
        TypeformSettings__c objTypeformSettings = null;
        RemotingMessageHelper.OperationResult objResult = null;
        String strAccessToken = null;
        
        System.debug('saveAuthorizationCode [strCode : ' + strCode + '] ->');
        
        try {
            objResult = new RemotingMessageHelper.OperationResult();

            objTypeformSettings = [SELECT Id, Code__c, Refresh_Token__c
                                   FROM TypeformSettings__c 
                                   WHERE SetupOwnerId =: UserInfo.getOrganizationId()];
            objTypeformSettings.Code__c = strCode;
            
            update objTypeformSettings;
                        
            objResult.Code = 0;
            objResult.Message = 'La operación se ha realizado de manera exitosa';
        } catch (Exception Ex) {
            objResult.Code = 999;
            objResult.Message = Ex.getMessage();
            HelperFunctions.handleRuntimeException(Ex);
        }
        
        System.debug('saveAuthorizationCode [' + objResult + '] <-');
        
        return objResult;        
    }       
    
    @RemoteAction
    public static List<Encuesta__c>  retrieveTypeformSurveys() { 
        List<Encuesta__c> lstEncuestas = null;

        lstEncuestas = [SELECT Id, TituloEncuesta__c 
                        FROM Encuesta__c
                        WHERE Enabled__c = TRUE];

		return lstEncuestas;    
    } 

    @RemoteAction
    public static void retrieveTypeformInfo(String strSurveyId, String strDate) { 
        List<Encuesta__c> lstSurvey = null;
        String strToken = null;
        String strLastHour = null;
        String strNowHour = null;
        DateTime datDate = null;

        System.debug('retrieveTypeformInfo [strSurveyId : ' + strSurveyId + ' - strDate : ' + strDate + ' ] ->');
        
        if(String.isNotBlank(strSurveyId) && String.isNotBlank(strDate)) {
            lstSurvey = [SELECT Id, TypeformId__c 
                        FROM Encuesta__c
                        WHERE Id =: strSurveyId];
            
            System.debug('retrieveTypeformInfo [lstSurvey : ' + lstSurvey + ' ]');

            if(!lstSurvey.IsEmpty()) {
                strToken = TypeformAPI.retrieveToken();

                System.debug('retrieveTypeformInfo [strToken : ' + strToken + ' ]');

                if(String.isNotBlank(strToken)) {
                    datDate = DateTime.valueOf(strDate + ' 00:00:00');

                    System.debug('retrieveTypeformInfo [datDate : ' + datDate + ' ]');

                    for(integer intHour = 0; intHour < 24; intHour++) {
                        strLastHour = DateTime.now().addHours(-intHour).formatGMT('yyyy-MM-dd\'T\'hh:30:00');
                        strNowHour = DateTime.now().addHours(-intHour + 1 ).formatGMT('yyyy-MM-dd\'T\'hh:00:00');
                        System.debug('retrieveTypeformInfo [strLastHour : ' + strLastHour + ' - strNowHour : ' + strNowHour + ']');

                        TypeformAPI.retrieveTypeformAnswers(strToken, lstSurvey[0].TypeformId__c,strLastHour, strNowHour);
                    }
                }
            }
        }
    }
}