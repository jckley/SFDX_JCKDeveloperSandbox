@isTest
Public class UpdateEdadFieldBatchTest {
@isTest 
        
    static void executeBatchTest1() {         
        Contact con = new Contact();
        con.Lastname = 'Test';
        con.guid__c = '111';
        con.birthdate = date.newInstance(1956, 12, 03);
        con.RecordTypeId = [SELECT Id 
                            FROM RecordType 
                            WHERE sObjectType = 'Contact' 
                            AND DeveloperName = 'Argentino' 
                            LIMIT 1].Id;
        insert con;
		UpdateEdadFieldBatch uscb = new UpdateEdadFieldBatch();
        uscb.runForAll = True;
        Database.executeBatch(uscb);
				
        }
@isTest  	
static void executeBatchTest2() { 
        Contact con = new Contact();
        con.Lastname = 'Test';
    con.guid__c = '111';
        con.birthdate = date.newInstance(1956, 12, 03);
        con.RecordTypeId = [SELECT Id 
                            FROM RecordType 
                            WHERE sObjectType = 'Contact' 
                            AND DeveloperName = 'Argentino' 
                            LIMIT 1].Id;
        insert con;
		UpdateEdadFieldBatch uscb = new UpdateEdadFieldBatch();
    	uscb.runForAll = False;    
        Database.executeBatch(uscb);
				
        }    
}