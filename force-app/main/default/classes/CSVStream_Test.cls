@IsTest
private class CSVStream_Test {
    static testMethod void testMethod1(){
        CSVStream cs = new CSVStream();
        cs.getCSVStream();
        
        rptobj__c r = new rptobj__c();
        r.Name = 'ThisReport';
        r.reporttrigger__c = 0;
        insert r;
        
        String sch = '0 0 23 * * ?'; 
        IncrementReport sh1 = new IncrementReport();
		system.schedule('Test Check', sch, sh1); 
    }

}