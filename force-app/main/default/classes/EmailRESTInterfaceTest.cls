@IsTest
private class EmailRESTInterfaceTest {
    @IsTest
    private static void sendEmailTest() {

        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Attachment attach = new Attachment();
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId = testAccount.Id;
        insert attach;

        RemotingMessageHelper.RESTEmailRequest objEmailRequest = new RemotingMessageHelper.RESTEmailRequest();
        objEmailRequest.userid = UserInfo.getUserId();
        objEmailRequest.message = 'test';
        objEmailRequest.files = new List<String>();
        objEmailRequest.files.add(String.valueOf(attach.Id));

        EmailRESTInterface.sendNotification(objEmailRequest);
    }
}