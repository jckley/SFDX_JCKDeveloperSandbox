global class UpdateTypeFormResponses_Schedulable  implements Schedulable {
    global void execute(SchedulableContext objSchedulableContext) { 
    	List<Encuesta__c> lstSurvey = null;
        String strToken = null;
        String strLastHour = null;
        String strNowHour = null;
        
        lstSurvey = [SELECT Id, TypeformId__c 
                     FROM Encuesta__c
                     LIMIT 1000];
        
        if(!lstSurvey.IsEmpty()) {
            strToken = TypeformAPI.retrieveToken();
            strLastHour = DateTime.now().addHours(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
            strNowHour = DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
            if(String.isNotBlank(strToken)) {
                for(Encuesta__c objSurvey : lstSurvey) {
                    TypeformAPI.retrieveTypeformSurvey(objSurvey.TypeformId__c);
                    TypeformAPI.retrieveTypeformAnswers(strToken, objSurvey.TypeformId__c,strLastHour, strNowHour);
                }
            }
        }
    }
}