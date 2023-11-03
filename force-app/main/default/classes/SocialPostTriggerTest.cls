@isTest
private class SocialPostTriggerTest {
    private static String TWITTER_HANDLE = 'demotest';
    
    @testSetup
    private static void setupTest() {
        createCitizen();
        insertMarketingCloudSettings();
        createSocialMediaSendsConfiguration();
    } 
    
    @isTest
    private static void testTwitterPost() {
        SocialPost objSocialPost = null;
        
        Test.setMock(HttpCalloutMock.class, new MarketingCloudAPIMock());
        Test.startTest();
        objSocialPost = new SocialPost();
        objSocialPost.Handle = TWITTER_HANDLE;
        objSocialPost.Provider = 'Twitter';
        objSocialPost.MediaProvider = 'Twitter';
        objSocialPost.Name = 'Twitter test';
        objSocialPost.TopicProfileName = '#ListenTestArgentina';        
        insert objSocialPost;
            
        SocialPostController.sendNotifications([SELECT Name, Handle, TopicProfileName, MediaProvider FROM SocialPost]);
            
        Test.stopTest();
    }
    
    private static void createCitizen() {
        Contact objContact = null;
        
        objContact = new Contact();
        objContact.FirstName = 'Juan';
        objContact.LastName = 'Perez';
        objContact.Email = 'matias.rodriguez@prosumia.la';
        objContact.MobilePhone = '541167304156';
        objContact.Usuario_Twitter__c = TWITTER_HANDLE;
        objContact.guid__c = '111';
        objContact.RecordTypeId = [SELECT Id 
                                   FROM RecordType 
                                   WHERE sObjectType = 'Contact' 
                                   LIMIT 1].Id;
        
        insert objContact;        
    }
    
    private static void insertMarketingCloudSettings() {
        Marketing_Cloud_Settings__c objMarketingCloudSettings = null;
        
        System.debug('insertMarketingCloudSettings [] ->'); 
        
        objMarketingCloudSettings = new Marketing_Cloud_Settings__c();
        objMarketingCloudSettings.Name = 'ORG WIDE DEFAULTS';
        objMarketingCloudSettings.ClientId__c = 'b9679b57yusr2z8u0fgbijti';
        objMarketingCloudSettings.ClientSecret__c = 'EiOZQZClpr10wkEiU61Fkx9s';
        objMarketingCloudSettings.Email_Sender_Address__c = 'salesforce@prosumia.la';
        objMarketingCloudSettings.Email_Sender_Name__c = 'Prosumia';
        objMarketingCloudSettings.EmailMessageId__c = 'demoprosumia';
        objMarketingCloudSettings.ShortCode__c = '76767';
        objMarketingCloudSettings.SMSKeyword__c = 'FREETEXT';
        objMarketingCloudSettings.SMSMessageId__c = 'MTIzOjc4OjA';
        objMarketingCloudSettings.SetupOwnerId = UserInfo.getOrganizationId();
        
        insert objMarketingCloudSettings;        
        
        System.debug('insertMarketingCloudSettings [ ' + objMarketingCloudSettings + ' ] <-'); 
    }
    
    @isTest
    private static void createSocialMediaSendsConfiguration() {
        Social_Source__c objSource = null;
        Social_Destination__c objDestination = null;
		Social_Media_Sends__c objSMS = null;
        Social_Media__c objSocialMedia = null;
        
        objSource = new Social_Source__c();
        objSource.Name = '#ListenTestArgentina';
        insert objSource;

        objSocialMedia = new Social_Media__c();
        objSocialMedia.Name = 'Twitter';
        insert objSocialMedia;
        
        objDestination = new Social_Destination__c();
        objDestination.Name = 'Whats App';
        insert objDestination;
        
        objSMS = new Social_Media_Sends__c();
        objSMS.Active__c = true;
        objSMS.Social_Destination__c = objDestination.Id;
        objSMS.Social_Media__c = objSocialMedia.Id;
        objSMS.Social_Source__c = objSource.id;
        insert objSMS;
        
        objDestination = new Social_Destination__c();
        objDestination.Name = 'SMS';
        insert objDestination;
        
        objSMS = new Social_Media_Sends__c();
        objSMS.Active__c = true;
        objSMS.Social_Destination__c = objDestination.Id;
        objSMS.Social_Media__c = objSocialMedia.Id;
        objSMS.Social_Source__c = objSource.id;
        insert objSMS;
        
        objDestination = new Social_Destination__c();
        objDestination.Name = 'Email';
        insert objDestination;
        
        objSMS = new Social_Media_Sends__c();
        objSMS.Active__c = true;
        objSMS.Social_Destination__c = objDestination.Id;
        objSMS.Social_Media__c = objSocialMedia.Id;
        objSMS.Social_Source__c = objSource.id;
        insert objSMS;
    }
    
}