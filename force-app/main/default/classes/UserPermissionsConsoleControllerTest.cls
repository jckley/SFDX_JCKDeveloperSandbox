@isTest
public class UserPermissionsConsoleControllerTest {

    @isTest
    public static void testConstructor() {
        Test.setCurrentPageReference(new PageReference('Page.UserPermissionsConsole'));
        User u = [SELECT Id From User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.currentPageReference().getParameters().put('id', u.Id);
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
    }
    
    @isTest
    public static void testUpdateView() {
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
        Contact con = new Contact();
        con.OwnerId = [SELECT Id From User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1].Id;
        upcc.contact = con;
        upcc.updateUserView();
    }
    
    @isTest
    public static void testUpdateViewWithCommonUser() {
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
        Contact con = new Contact();
        con.OwnerId = [SELECT Id From User WHERE isActive = true AND Profile.Name != 'System Administrator' AND Profile.Name != NULL LIMIT 1].Id;
        upcc.contact = con;
        upcc.updateUserView();
    }
    
    //este test no lo corro mas para que no joda con el perfil test profile
    public static void testUpdateViewWithTestUser() {
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
        Contact con = new Contact();
        con.OwnerId = [SELECT Id From User WHERE isActive = true AND Profile.Name = 'Test Profile' LIMIT 1].Id;
        upcc.contact = con;
        upcc.updateUserView();
    }
    
    @isTest
    public static void testGetGroupDetail() {
        Test.setCurrentPageReference(new PageReference('Page.UserPermissionsConsoleDetail'));
        User u = [SELECT Id From User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.currentPageReference().getParameters().put('id', u.Id);
        System.currentPageReference().getParameters().put('group', 'Identificacion');
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
        upcc.getGroupDetail();
    }
    
    @isTest
    public static void testGetGroupDetail2() {
        Test.setCurrentPageReference(new PageReference('Page.UserPermissionsConsoleDetail'));
        User u = [SELECT Id From User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.currentPageReference().getParameters().put('id', u.Id);
        System.currentPageReference().getParameters().put('group', 'Atributos');
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
        upcc.getGroupDetail();
    }
    
    @isTest
    public static void testGetGroupDetail3() {
        Test.setCurrentPageReference(new PageReference('Page.UserPermissionsConsoleDetail'));
        User u = [SELECT Id From User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.currentPageReference().getParameters().put('id', u.Id);
        System.currentPageReference().getParameters().put('group', 'Ingresos');
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
        upcc.getGroupDetail();
    }
    
    @isTest
    public static void testGetGroupDetail5() {
        Test.setCurrentPageReference(new PageReference('Page.UserPermissionsConsoleDetail'));
        User u = [SELECT Id From User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.currentPageReference().getParameters().put('id', u.Id);
        System.currentPageReference().getParameters().put('group', 'Electoral');
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
        upcc.getGroupDetail();
    }
    
    @isTest
    public static void testGetGroupDetail4() {
        Test.setCurrentPageReference(new PageReference('Page.UserPermissionsConsoleDetail'));
        User u = [SELECT Id From User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.currentPageReference().getParameters().put('id', u.Id);
        System.currentPageReference().getParameters().put('group', 'Contacto');
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
        upcc.getGroupDetail();
    }
    
    @isTest
    public static void testGetGroupDetail6() {
        Test.setCurrentPageReference(new PageReference('Page.UserPermissionsConsoleDetail'));
        User u = [SELECT Id From User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.currentPageReference().getParameters().put('id', u.Id);
        System.currentPageReference().getParameters().put('group', 'Contacto(tiene)');
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
        upcc.getGroupDetail();
    }
    
    @isTest
    public static void testGetGroupDetail7() {
        Test.setCurrentPageReference(new PageReference('Page.UserPermissionsConsoleDetail'));
        User u = [SELECT Id From User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.currentPageReference().getParameters().put('id', u.Id);
        System.currentPageReference().getParameters().put('group', 'Tags Standard');
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
        upcc.getGroupDetail();
    }
    
    @isTest
    public static void testGetGroupDetail8() {
        Test.setCurrentPageReference(new PageReference('Page.UserPermissionsConsoleDetail'));
        User u = [SELECT Id From User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.currentPageReference().getParameters().put('id', u.Id);
        System.currentPageReference().getParameters().put('group', 'Tags x proyecto');
        UserPermissionsConsoleController upcc = new UserPermissionsConsoleController();
        upcc.getGroupDetail();
    }
    
}