@istest
public with sharing class PRM_Cuidarnos_GET_IVRNumeral8_Sch_Test {

    @testSetup 
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
    }

    @IsTest
    private static void PRM_Cuidarnos_GET_IVRNumeral8_Sch_Test() {
        
        PRM_Cuidarnos_GET_IVRNumeral8_Sched objSchedulable = null;

        Covid19__c a = new Covid19__c();
        a.Name = 'testScheduledApexFromTestMethod';
        a.Citizen__c = CommonTestFunctions.retrieveContact().id;
        a.proactiva_risk__c = 'Sintomático';
        a.Riesgo__c = 'Bajo';
        a.Mobile_Phone__c = '541155555555';
        a.GUID__c = CommonTestFunctions.retrieveContact().GUID__c;
        insert a;

        IVR_Calls_Numeral8__c ivr = new IVR_Calls_Numeral8__c();
        ivr.Covid19__c = a.Id;
        ivr.Paciente_Phone__c = a.Mobile_Phone__c;
        ivr.Status__c = 'POST_OK';
        insert ivr;

        Test.startTest();
            objSchedulable = new PRM_Cuidarnos_GET_IVRNumeral8_Sched();
            objSchedulable.execute(null);
        Test.stopTest();
    }
}