@IsTest
private class Pulso_Admin_Typeform_Controller_Test {
	@testSetup
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
    }
    
    @IsTest
    private static void adminTest() {
        Pulso_Admin_Typeform_Controller.retrieveAuthorizationUrl();
        Pulso_Admin_Typeform_Controller.retrieveTypeformInfo('test','2010-01-01');
        Pulso_Admin_Typeform_Controller.retrieveTypeformStatus();
        Pulso_Admin_Typeform_Controller.saveAuthorizationCode('test');
    }
}