@IsTest
private class HelperFunctionsTest {
    @IsTest
    private static void retrieveSiteTest() {
        HelperFunctions.retrieveSite();
    }
    
    @IsTest
    private static void sendEmailTest(){
 		HelperFunctions.sendEmail('email@email.com', 'Test', 'Test');
        HelperFunctions.sendEmail('email@email.com', 'Test', 'Test', 'test.csv', 'text/csv', Blob.valueOf('test,test,test'));        
        HelperFunctions.sendEmail(new String[] {'email@email.com'}, new String[] {'email@email.com'}, 'Test', 'Test', 'test.csv', 'text/csv', Blob.valueOf('test,test,test'));

        
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Attachment attach = new Attachment();
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId = testAccount.Id;
        insert attach;
       
        List<Attachment> objAttachmentList = new List<Attachment>();
        objAttachmentList.add(attach);

	    /*public static void sendEmail(String strTO, String strSubject, String strBody, List<Attachment> objAttachmentArr, String strAttachmentContentType)*/
        HelperFunctions.sendEmail('email@email.com', 'Test Subject', 'Test Body', objAttachmentList, 'text/csv');
	    /*public static void sendEmail(List<String> lstTO, List<String> lstCC, String strSubject, String strBody, List<Attachment> objAttachmentArr, String strAttachmentContentType)*/
        HelperFunctions.sendEmail(new String[] {'email@email.com'}, new String[] {'email@email.com'}, 'Test Subject', 'Test Body', objAttachmentList, 'text/csv');
    }
    
    @IsTest
    private static void formatFunctionsTest() { 
        HelperFunctions.convertStringToDate('2018-09-01', 'YYYYMMDD', '-');
        HelperFunctions.getThousandSeparatedByDot(10000000);
        HelperFunctions.getThousandSeparatedByDot(10000);
        HelperFunctions.removeAccents('papepipopu');       
        HelperFunctions.handleRuntimeException( (new ContactDetailController.LayoutNotFoundException()));
        HelperFunctions.capitalizeList(new Set<String>{'Test 1', 'Test 2'});
        HelperFunctions.capitalizeList(new List<String>{'Test 1', 'Test 2'});

        Date fecha = Date.newInstance(2018, 9, 1);
        HelperFunctions.convertDateToString(fecha);

        HelperFunctions.formatCUIT('30125564458');
        HelperFunctions.formatNumberString('123456');
    	HelperFunctions.formatNumber(125.35);

    }
    
    @IsTest
    private static void customSettingsTest() { 
        HelperFunctions.retrieveCommunitySettings();
        HelperFunctions.retrieveSurveySettings('PulsoCRM');
    }
    
    @IsTest
    private static void metadataTest() { 
        List<Schema.PicklistEntry>  lstPicklistEntries =  null;
    	HelperFunctions.getFieldLabel('Name', 'Contact');
        HelperFunctions.getFieldType('Name', 'Contact');

        lstPicklistEntries = HelperFunctions.retrievePicklistValues('Contact', 'Community__c');
        HelperFunctions.buildPickListOptions(lstPicklistEntries);
        HelperFunctions.getValuesFromMultiPickList (new String[] {'test','test','test'});
        
        String value = HelperFunctions.retrievePicklistValue('Contact', 'Community__c', 'Test');

        HelperFunctions.retrievePicklistValuesToStringList('Contact', 'Community__c');

        HelperFunctions.getValuesFromMultiPickList ('Contact', 'Community__c', new List<String> {'Test 1', 'Test 2'});
    	HelperFunctions.hasSObjectField('Community__c', 'Contact');
        
    }
    
    @IsTest
    private static void metadataCalloutTest() {
        Test.setMock(HttpCalloutMock.class, new RESTMock());
		Test.startTest();
        HelperFunctions.addValueToPickList ('Contact', 'Community__c', true, 'pepe');        
        HelperFunctions.addValueToPickList ('Contact', 'Community__c', false, 'pepe'); 
        Test.stopTest();
    }
}