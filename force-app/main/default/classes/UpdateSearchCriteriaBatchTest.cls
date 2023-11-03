@isTest
public class UpdateSearchCriteriaBatchTest {

    @isTest
    static void executeBatchTest() {
        Contact con = new Contact();
        con.LastName = 'Test';
        con.guid__c = '111';
        con.RecordTypeId = [SELECT Id 
                            FROM RecordType 
                            WHERE sObjectType = 'Contact' 
                            AND DeveloperName = 'Argentino' 
                            LIMIT 1].Id;
        insert con;
        List<String> mixList = new List<String>{'Test'};
        UpdateSearchCriteriaBatch uscb = new UpdateSearchCriteriaBatch();
        Database.executeBatch(uscb);
    }
}