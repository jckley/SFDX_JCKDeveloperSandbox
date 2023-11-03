@isTest
public class ContactsCSVControllerTest {

    @isTest
    static void readFileTestSemicolon() {
        Contact con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '123';
        con.RecordTypeId = [SELECT Id 
                            FROM RecordType 
                            WHERE sObjectType = 'Contact' 
                            AND DeveloperName = 'Argentino' 
                            LIMIT 1].Id;
        insert con;
        ContactsCSVController conCSV = new ContactsCSVController();
        conCSV.selectedSearchCriteria = 'SearchCriteria__c';
        conCSV.contentFile = Blob.valueOf('a;22/01/2001F609\r\n'.repeat(2000));
        conCSV.nameFile = 'test.csv';
        conCSV.ReadFile();
    }
    
    @isTest
    static void readFileTestComma() {
        Contact con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '123';
        con.RecordTypeId = [SELECT Id 
                            FROM RecordType 
                            WHERE sObjectType = 'Contact' 
                            AND DeveloperName = 'Argentino' 
                            LIMIT 1].Id;
        insert con;
        ContactsCSVController conCSV = new ContactsCSVController();
        conCSV.selectedSearchCriteria = 'SearchCriteria__c';
        conCSV.contentFile = Blob.valueOf('a,22/01/2001F609\r\n'.repeat(2000));
        conCSV.nameFile = 'test.csv';
        conCSV.ReadFile();
    }
}