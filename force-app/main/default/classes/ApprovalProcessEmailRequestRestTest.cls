@IsTest
private class ApprovalProcessEmailRequestRestTest {
    @IsTest 
    static void testApprove(){        
        RestRequest objRESTRequest = null; 
        RestResponse objRESTResponse = null;
        Export__c objExport = null;

        objExport = createExport();
        objRESTRequest = new RestRequest(); 
        objRESTResponse = new RestResponse();

        objRESTRequest.requestURI = String.format('https://www.salesforce.com/{0}/approve', new String [] { objExport.Id} );
        objRESTRequest.httpMethod = 'GET';
        RestContext.request = objRESTRequest;
        RestContext.response = objRESTResponse;

        ApprovalProcessEmailRequestRest.IsAlive();        
    }

    @IsTest
    static void testReject(){        
        RestRequest objRESTRequest = null; 
        RestResponse objRESTResponse = null;
        Export__c objExport = null;

        objExport = createExport();
        objRESTRequest = new RestRequest(); 
        objRESTResponse = new RestResponse();

        objRESTRequest.requestURI = String.format('https://www.salesforce.com/{0}/reject', new String [] { objExport.Id} );
        objRESTRequest.httpMethod = 'GET';
        RestContext.request = objRESTRequest;
        RestContext.response = objRESTResponse;

        ApprovalProcessEmailRequestRest.IsAlive();        
    }
    private static Export__c createExport() {
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
        objExport.Status__c = 'Pendiente de Aprobacion';
        objExport.Callout_Message__c = 'test';
        objExport.Record_Count__c = 1;

        insert objExport;

        return objExport;
    }
}