@isTest
private class AdFi_ConnectedPeopleControllerTest {
    @testSetup
    public static void setupTest() {
       CommonTestFunctions.commonSetup();
    }
    
    @isTest
    public static void retrieveRandomConnectedPeopleTest() {        
        System.assertEquals(5, AdFi_ConnectedPeopleController.retrieveRandomConnectedPeople(5).size());
    }
}