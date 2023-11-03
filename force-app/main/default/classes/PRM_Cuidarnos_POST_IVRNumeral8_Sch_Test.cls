@istest
public with sharing class PRM_Cuidarnos_POST_IVRNumeral8_Sch_Test {

    @testSetup 
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
    }

    @IsTest
    private static void PRM_Cuidarnos_POST_IVRNumeral8_Sched_Test() {
        
        PRM_Cuidarnos_POST_IVRNumeral8_Sched objSchedulable = null;

        Covid19__c a = new Covid19__c();
        a.Name = 'testScheduledApexFromTestMethod';
        a.Citizen__c = CommonTestFunctions.retrieveContact().id;
        a.Cuidarnos_Comunidad_Status__c = 'Seguimiento';
        a.Cuidarnos_Comunidad_Date__c = datetime.now().addDays(-10);
        a.Riesgo__c = 'Bajo';
        a.Mobile_Phone__c = '541155555555';
        a.guid__c = CommonTestFunctions.retrieveContact().GUID__c;
        insert a;

        Test.startTest();
            objSchedulable = new PRM_Cuidarnos_POST_IVRNumeral8_Sched();
            objSchedulable.execute(null);
        Test.stopTest();
    }
}