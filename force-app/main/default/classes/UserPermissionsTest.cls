@isTest
private class UserPermissionsTest {
	@isTest
    public static void test() {
        UserPermissions objUserPermissions = null;
        
        objUserPermissions = new UserPermissions();
        System.assertNotEquals(objUserPermissions.ContactViewAttributes, NULL);
        System.assertNotEquals(objUserPermissions.ContactViewCommonData, NULL);
        System.assertNotEquals(objUserPermissions.ContactViewContactInfo, NULL);
        System.assertNotEquals(objUserPermissions.ContactViewContactInfoDetails, NULL);
        System.assertNotEquals(objUserPermissions.ContactViewElectoral, NULL);
        System.assertNotEquals(objUserPermissions.ContactViewIncome, NULL);
        System.assertNotEquals(objUserPermissions.ContactViewLocation, NULL);
        System.assertNotEquals(objUserPermissions.ContactViewMapInfo, NULL);
        System.assertNotEquals(objUserPermissions.ContactViewSocialInfoDetails, NULL);
        System.assertNotEquals(objUserPermissions.ContactViewSocialInfo, NULL);               
    }
}