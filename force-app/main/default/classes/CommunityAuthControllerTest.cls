@isTest
global with sharing class CommunityAuthControllerTest {    
    /*@IsTest
    global static void testCommunityAuthController () {
        String username = 'test@salesforce.com';
        String password = '123456';
        
        System.assertEquals(CommunityAuthController.communityLogin(username, password), null);                           
    }*/
    
    @IsTest
    global static void testCommunityAuthController2 () {
        CommunityAuthController controller = new CommunityAuthController();
        controller.username = 'test@salesforce.com';
        controller.password = '123456';
        //String startUrl = 'https://dev-prosumia.cs79.force.com/prosumia2/s/';
        
        System.assertEquals(controller.doLogin(), null);                           
    }

}