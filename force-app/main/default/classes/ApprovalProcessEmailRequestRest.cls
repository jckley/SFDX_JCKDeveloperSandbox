@RestResource(urlMapping='/exports/req/*')
global class ApprovalProcessEmailRequestRest {
    @HttpGet 
    global static String isAlive() {
        RestRequest objRESTRequest;
        RestResponse objRESTResponse;
        String strUrl;
        List<String> lstString;
        String strAction;
        String strExportId;
        
        objRESTRequest = RestContext.request;
        objRESTResponse = RestContext.response;
        
        strUrl = objRESTRequest.requestURI;

        if(strUrl.endsWith('/')) {
            strUrl = strUrl.removeEnd('/');
        }
        lstString = strUrl.split('/');
        
        strAction = lstString[lstString.size() - 1];
        strExportId = lstString[lstString.size() - 2];
        
        String variable = '';
        String resultado = '';
        
        System.debug('id: ' + strExportId + ' - action:' + strAction);
        if(strAction == 'approve') {
            ExportController.processRequest(strExportId, true);
            resultado = 'Aprobado';
        } else if(strAction == 'reject') {
            ExportController.processRequest(strExportId, false);
            resultado = 'Rechazado';
        }
        
        variable = 'id: ' + strExportId + ' - action:' + strAction + ' - result: ' + resultado;
        
        return variable;
    }

}