@istest
public with sharing class updateCuidarnosStatusSalud_Sched_Test {


    @testSetup 
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
    }

    @IsTest
    private static void updateCuidarnosStatusSalud_Sched_Test() {
        
        updateCuidarnosStatusSalud_Schedulable objSchedulable = null;

        Covid19__c a = new Covid19__c();
        a.Name = 'testScheduledApexFromTestMethod';
        a.Citizen__c = CommonTestFunctions.retrieveContact().id;
        a.Cuidarnos_Comunidad_Status__c = 'Sintomático';
        a.Cuidarnos_Comunidad_Date__c = datetime.now().addDays(-10);
        insert a;

        Test.startTest();
            objSchedulable = new updateCuidarnosStatusSalud_Schedulable();
            objSchedulable.execute(null);
        Test.stopTest();
    }
}