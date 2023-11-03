@istest
public with sharing class updateCuidarnosStatusDetectable_Sch_Test {

    @testSetup 
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
    }

    @IsTest
    private static void updateCuidarnosStatusDetectable_Sch_Test() {
        
        updateCuidarnosStatusDetectable_Sched objSchedulable = null;

        Covid19__c b = new Covid19__c();

        b.Name = 'testScheduledApexFromTestMethod_a';
        b.Citizen__c = CommonTestFunctions.retrieveContact().id;
        b.guid__c = '10';
        b.Cuidarnos_Comunidad_Status__c = 'Notificado';
        b.Cuidarnos_Muestra_Result__c = 'Detectable';
        b.Cuidarnos_Muestra_Result_Date__c = datetime.now().addDays(-15); 
        b.Cuidarnos_Comunidad_Date__c = datetime.now().addDays(-15);
        insert b;

        Test.startTest();
            objSchedulable = new updateCuidarnosStatusDetectable_Sched();
            objSchedulable.execute(null);
        Test.stopTest();
    }
}