@isTest
public class UpdateEdadFieldScheduleTest {
    @isTest
    static void test1(){
        
        Test.StartTest();
        UpdateEdadFieldSchedule usce = new UpdateEdadFieldSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('UpdateEdadFieldScheduleTest', sch, usce);
        Test.stopTest();
    }
}