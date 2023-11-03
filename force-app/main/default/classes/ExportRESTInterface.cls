@RestResource(urlMapping='/export/*')
global class ExportRESTInterface {

    @HttpGet 
    global static String isAlive() {
        return 'isAlive!';
    }

    @HttpPost
    global static Integer updateExportStatus(String strCallingApp, String strNewStatus) {
        List<Export__c> lstExport = null;
        
        System.debug('updateExportStatus [To : ' + strNewStatus + '] [strCallingApp :' + strCallingApp);

        lstExport = [SELECT ID FROM Export__c WHERE Status__c = 'En ejecución' and Type__c =: strCallingApp LIMIT 1];

        if (!lstExport.isEmpty()) {
			lstExport[0].Status__c = strNewStatus;
			update lstExport;
        } else {
            System.debug('updateExportStatus [Lista Vacía! No hay exports en ejecución!]');
        }

        return 0;
    }
    
}