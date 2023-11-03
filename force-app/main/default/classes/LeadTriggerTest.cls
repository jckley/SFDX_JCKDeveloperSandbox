@IsTest
public with sharing class LeadTriggerTest {
    @IsTest
    private static void sendWhatsAppMessage() {
        Lead objLead = null;

        Test.setMock(HttpCalloutMock.class, new MarketingCloudAPIMock());
        
        Test.startTest();
        objLead = new Lead();
        objLead.FirstName = 'Hola';
        objLead.LastName = 'Chau';
        objLead.Email = 'prueba@prueba.com';
        objLead.MobilePhone = '5491123456789';
        objLead.Company = 'Test';

        insert objLead;
        
        Test.stopTest();
    }
}