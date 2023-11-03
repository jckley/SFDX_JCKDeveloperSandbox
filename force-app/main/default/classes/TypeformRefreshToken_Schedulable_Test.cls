@IsTest
private with sharing class TypeformRefreshToken_Schedulable_Test {
    @testSetup 
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
        createTypeformsSettings();
    }

    @IsTest
    private static void TypeformRefreshToken_Schedulable_Test() {
        TypeformRefreshToken_Schedulable objSchedule = null;
        Test.setMock(HttpCalloutMock.class, new TypeformMock(TypeformMock.REQUEST_TYPE.TOKEN));

        Test.startTest();
        objSchedule = new TypeformRefreshToken_Schedulable();
        objSchedule.execute(null);        
        Test.stopTest();
    }

    private static void createTypeformsSettings() {
        TypeformSettings__c objTypeformSettings = null;
                
        objTypeformSettings = new TypeformSettings__c();
        objTypeformSettings.Code__c = 'pepe';
        objTypeformSettings.SetupOwnerId = UserInfo.getOrganizationId();
        insert objTypeformSettings;
    }
}