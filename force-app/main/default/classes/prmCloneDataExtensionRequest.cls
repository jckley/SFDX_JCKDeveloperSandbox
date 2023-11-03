global with sharing class prmCloneDataExtensionRequest {
    public static String dataExtensionFrom;
    public static String dataExtensionTo;
	public static String filterOneField;
	public static String filterOneCondition;
	public static String filterOneValue;
	public static String filterTwoField;
	public static String filterTwoCondition;
	public static String filterTwoValue;
    public static String filterCondition;
    public static String exportId;

    public static void prmCloneDataExtensionRequestInit(String strExportId, String argDataExtensionFrom, String argDataExtensionTo) {
        System.debug('prmCloneDataExtensionRequestInit [strExportId : ' + strExportId + ' - argDataExtensionFrom : ' + argDataExtensionFrom + ' - argDataExtensionTo : ' + argDataExtensionTo + '] ->');

        dataExtensionFrom = argDataExtensionFrom;
        dataExtensionTo = argDataExtensionTo;
        exportId = strExportId;

        execute();

        System.debug('prmCloneDataExtensionRequestInit [] <-');
    }

    @AuraEnabled
    public static void prmCloneDataExtensionRequestInit(String argDataExtensionFrom, String argDataExtensionTo, String argFilterOneField, String argFilterOneCondition, String argFilterOneValue, String argFilterTwoField, String argFilterTwoCondition, String argFilterTwoValue, String argFilterCondition) {
        System.debug('prmCloneDataExtensionRequestInit [argDataExtensionFrom : ' + argDataExtensionFrom + ' - argDataExtensionTo : ' + argDataExtensionTo + '] ->');

        dataExtensionFrom = argDataExtensionFrom;
        dataExtensionTo = argDataExtensionTo;
        filterOneField = argFilterOneField;
        filterOneCondition = argFilterOneCondition;
        filterOneValue = argFilterOneValue;
        filterTwoField = argFilterTwoField;
        filterTwoCondition = argFilterTwoCondition;
        filterTwoValue = argFilterTwoValue;
        filterCondition = argFilterCondition;

        execute();

        System.debug('prmCloneDataExtensionRequestInit [] <-');
    }
    
    public static void execute() {
        Http objHttp = null;
        HttpRequest objRequest = null;
        HttpResponse objResponse = null;
        
        System.debug('execute [] ->');

        try {
            
            if(String.isNotBlank(dataExtensionFrom) && String.isNotBlank(dataExtensionTo)) {
                String bodyStr = '{"dataExtensionFrom":"' + dataExtensionFrom + '","dataExtensionTo":"' + dataExtensionTo + '"';
                if (String.isNotBlank(filterOneField) && String.isNotBlank(filterOneValue)) {
                    bodyStr += ',"filter1":[{"Property":"' + filterOneField + '","SimpleOperator":"' + filterOneCondition + '","Value":"' + filterOneValue + '"}]';
                    if (String.isNotBlank(filterTwoField) && String.IsNotBlank(filterTwoValue) && String.IsNotBlank(filterCondition)) {
                        bodyStr += ',"LogicalOperator":"' + filterCondition + '"';
                        bodyStr += ',"filter2":[{"Property":"' + filterTwoField + '","SimpleOperator":"' + filterTwoCondition + '","Value":"' + filterTwoValue + '"}]';
                    }
                }
                bodyStr += '}';

                objRequest = new HttpRequest();
                objRequest.setMethod('POST');
                objRequest.setEndpoint('callout:HerokuAPI/pulso_mc_data_extension');
                objRequest.setHeader('content-type', 'application/json; charset=UTF-8');
                //objRequest.setBody(JSON.serialize(bodyStr));
                objRequest.setBody(bodyStr);


                //curl -X POST http://localhost:8080/pulso_mc_data_extension 
                //		--header "Content-Type: application/json" 
                //		--data '{"filter1":[{"Property":"MobilePhone" , "SimpleOperator":"equals" , "Value": "542302565981"}] , "dataExtensionFrom":"DATA_EXTENSION_FOR_TEST","dataExtensionTo":"DATA_EXTENSION_FOR_TEST_Cloned"}
                //{"dataExtensionFrom":"DATA_EXTENSION_FOR_TEST","dataExtensionTo":"DATA_EXTENSION_FOR_TEST_Cloned"}

                objHttp = new Http();
                objResponse = objHttp.send(objRequest);

                if(objResponse.getStatusCode() == 200 || objResponse.getStatusCode() == 202) {
                    System.debug('BODY: ' + objResponse.getBody());
                } else {
                    System.debug('BODY: ' + objResponse.getBody());
                }
            } else {
                updateExportStatusWithError(exportId, 'Parámetros inválidos'); 
            }
        } catch(Exception Ex) {
            updateExportStatusWithError(exportId, 'Parámetros inválidos'); 
        }                

        System.debug('execute [] <-');
    }

    private static void updateExportStatusWithError(String strExportId, String strMessage) {
        Export__c objExport = null;

        System.debug('updateExportStatusWithError [strExportId : ' + strExportId + ' - strMessage : ' + strMessage + '] ->');

        objExport = [SELECT Status__c, Callout_Message__c 
                     FROM Export__c 
                     WHERE Id =: strExportId];
        
        objExport.Status__c = 'Finalizado con errores'; 
        objExport.Callout_Message__c = strMessage;

        update objExport;

        HelperFunctions.sendEmail(UserInfo.getUserEmail(), 'Error en la operacion', strMessage);

        System.debug('updateExportStatusWithError [] <-');
    }
}