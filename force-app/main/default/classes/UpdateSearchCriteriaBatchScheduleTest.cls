@isTest
public class UpdateSearchCriteriaBatchScheduleTest {

    @isTest
    static void test1(){
        
        Test.StartTest();
        UpdateSearchCriteriaSchedule usce = new UpdateSearchCriteriaSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('UpdateSearchCriteriaTest', sch, usce);
        Test.stopTest();
    }
}