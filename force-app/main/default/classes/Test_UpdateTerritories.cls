@isTest
public with sharing class Test_UpdateTerritories {

    @testSetup
    static void setup(){	

        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        Territorio_Administrativo__c terr = new Territorio_Administrativo__c();
        terr.Location_UUID__c = 'TEST';
        terr.Nivel_Administrativo__c = 0;
        terr.Name = 'Argentina';
        insert terr;
        /*Test Setup */
        Territorio_Administrativo__c terr2 = new Territorio_Administrativo__c();
        terr2.Location_UUID__c = 'TEST 2';
        terr2.Nivel_Administrativo__c = 1;
        terr2.Name = 'TEST 2';
		terr2.ParentId__c = terr.Id;
        insert terr2;
        Territorio_Administrativo__c terr3 = new Territorio_Administrativo__c();
        terr3.Location_UUID__c = 'TEST 3';
        terr3.Nivel_Administrativo__c = 2;
        terr3.Name = 'TEST 3';
        terr3.ParentId__c = terr2.Id;
        insert terr3;
        Territorio_Administrativo__c terr4 = new Territorio_Administrativo__c();
        terr4.Location_UUID__c = 'TEST 4';
        terr4.Nivel_Administrativo__c = 3;
        terr4.Name = 'TEST 4';
        terr4.ParentId__c = terr3.Id;
        insert terr4;
        Territorio_Administrativo__c terr5 = new Territorio_Administrativo__c();
        terr5.Location_UUID__c = 'TEST 5';
        terr5.Nivel_Administrativo__c = 4;
        terr5.Name = 'TEST 5';
        terr5.ParentId__c = terr4.Id;
        insert terr5;

        List<Contact> citizens = new List<Contact>();

        Contact con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1231';
        con.Territorio_Administrativo__c = terr5.Id;
        con.Birthdate = Date.today();
        con.Gender__c = 'M';
        con.Ingreso__c = 'Muy Bajo';
        con.Education_Level__c = 'Primaro';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();

        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1232';
        con.Territorio_Administrativo__c = terr5.Id;
        con.Birthdate = Date.today();
        con.Gender__c = 'F';
        con.Ingreso__c = 'Bajo';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();

        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1233';
        con.Territorio_Administrativo__c = terr5.Id;
        con.Birthdate = Date.today().addYears(-15);
        con.Gender__c = 'M';
        con.Ingreso__c = 'Medio';
        con.Education_Level__c = 'Secundario';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();

        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1234';
        con.Territorio_Administrativo__c = terr5.Id;
        con.Birthdate = Date.today().addYears(-15);
        con.Gender__c = 'F';
        con.Ingreso__c = 'Alto';
        con.Education_Level__c = 'Terciario';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();

        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1235';
        con.Territorio_Administrativo__c = terr5.Id;
        con.Birthdate = Date.today().addYears(-30);
        con.Gender__c = 'M';
        con.Ingreso__c = 'Muy Alto';
        con.Education_Level__c = 'Universitario';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();

        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1236';
        con.Territorio_Administrativo__c = terr5.Id;
        con.Birthdate = Date.today().addYears(-30);
        con.Gender__c = 'F';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();

        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1237';
        con.Territorio_Administrativo__c = terr5.Id;
        con.Birthdate = Date.today().addYears(-45);
        con.Gender__c = 'M';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();

        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1238';
        con.Territorio_Administrativo__c = terr5.Id;
        con.Birthdate = Date.today().addYears(-45);
        con.Gender__c = 'F';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();

        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1239';
        con.Territorio_Administrativo__c = terr5.Id;
        con.Birthdate = Date.today().addYears(-60);
        con.Gender__c = 'M';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();

        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1230';
        con.Territorio_Administrativo__c = terr5.Id;
        con.Birthdate = Date.today().addYears(-60);
        con.Gender__c = 'F';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();

        citizens.add(con);
                            
        insert citizens;
    }
    
    @isTest 
    static void testUpdate() {
        Test.startTest();
            SchdUpdateTerritories.start('Argentina');
        Test.stopTest();

    }
}