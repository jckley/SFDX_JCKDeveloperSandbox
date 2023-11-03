@IsTest
private  class ExportControllerTest {
    @IsTest
    private static void processApproveExportRequestTest() {
        ExportController.createExport('eamc', 'terst', true, true, 'esto es un saql', 'esto es una data extension', 'Pulso Survey', '', '', '', '', '');
        ExportController.createExport('pulso', 'terst', true, true, 'esto es un saql', 'esto es una data extension', 'Pulso Survey', '', '', '', '', '');
        ExportController.createExport('eacsv', 'terst', true, true, 'esto es un saql', 'esto es una data extension', 'Pulso Survey', '', '', '', '', '');
        ExportController.createExport('mccsv', 'terst', true, true, 'esto es un saql', 'esto es una data extension', 'Pulso Survey', '', '', '', '', '');
        initializeTest();

        ExportController.elmejortestlohacelusuarioenproduccion();
        Test.setMock(HttpCalloutMock.class, new RESTMock());

        List<Export__c> lstExport = ExportController.exports('');

        for(Export__c objExport : lstExport) {
            objExport.Order_Date__c = Date.today();
            objExport.Status__c = 'Aprobado';

            ExportController.processRequest(objExport.Id, true);
            ExportRESTInterface.updateExportStatus('eamc', 'En ejecución');
            ExportRESTInterface.updateExportStatus('eamc', 'Finalizado OK');            
        }

        update lstExport;
    }

    @IsTest
    private static void processUpdateExportTest() {
        Export__c objExport = null;

        objExport = new Export__c();
        objExport.Name = 'test';
        objExport.Type__c = 'test';
        objExport.All_Data__c = false;
        objExport.Sendable__c = false;
        objExport.SAQL__c = 'test';
        objExport.Data_Extension__c = 'test';
        objExport.Survey__c = 'test';

        objExport.Order_Date__c = Datetime.now();
        objExport.Status__c = 'test';
        objExport.Callout_Message__c = 'test';
        objExport.Record_Count__c = 1;

        insert objExport;
        update objExport;
    }

    @IsTest
    private static void processREjectedExportRequestTest() {
        ExportController.createExport('eamc', 'terst', true, true, 'esto es un saql', 'esto es una data extension', 'Pulso Survey', '', '', '', '', '');
        ExportController.createExport('pulso', 'terst', true, true, 'esto es un saql', 'esto es una data extension', 'Pulso Survey', '', '', '', '', '');
        ExportController.createExport('eacsv', 'terst', true, true, 'esto es un saql', 'esto es una data extension', 'Pulso Survey', '', '', '', '', '');
        ExportController.createExport('mccsv', 'terst', true, true, 'esto es un saql', 'esto es una data extension', 'Pulso Survey', '', '', '', '', '');
        

        List<Export__c> lstExport = ExportController.exports('');

        for(Export__c objExport : lstExport) {
            objExport.Order_Date__c = Date.today();
            objExport.Status__c = 'Rechazado';

            ExportController.processRequest(objExport.Id, false);
        }

        update lstExport;
    }

    private static void initializeTest() {
        Permission_Type__c objPermissionType = null;
        List<Permission_Type__c> lstPermissionType = null;
        
        lstPermissionType = new List<Permission_Type__c>();
        
        objPermissionType = new Permission_Type__c();
        objPermissionType.MaxRecords__c = 100000;
        objPermissionType.Records__c = 100000;
        objPermissionType.Profile_Id__c = UserInfo.getProfileId();
        objPermissionType.Time__c = 'Semanal';
        lstPermissionType.add(objPermissionType);

        objPermissionType = new Permission_Type__c();
        objPermissionType.MaxRecords__c = 100000;
        objPermissionType.Records__c = 100000;
        objPermissionType.UserId__c = UserInfo.getUserId();
        objPermissionType.Time__c = 'Semanal';
        lstPermissionType.add(objPermissionType);

		insert lstPermissionType;        
    }
}