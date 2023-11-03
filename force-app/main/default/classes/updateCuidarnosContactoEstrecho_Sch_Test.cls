@istest
public with sharing class updateCuidarnosContactoEstrecho_Sch_Test {

    @testSetup 
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
    }

    @IsTest
    private static void updateCuidarnosContactoEstrecho_Sch_Test() {
        
        updateCuidarnosContactoEstrecho_Sch objSchedulable = null;

        Covid19__c b = new Covid19__c();

        b.Name = 'testScheduledApexFromTestMethod_a';
        b.Citizen__c = CommonTestFunctions.retrieveContact().id;
        b.guid__c = '10';
        b.Contacto_Estrecho__c = True;
        b.Contacto_Estrecho_GUID__c = CommonTestFunctions.retrieveContact().id;
        b.Cuidarnos_Comunidad_Status__c = 'Notificado';
        b.Cuidarnos_Muestra_Result__c = 'Detectable';
        b.Cuidarnos_Muestra_Result_Date__c = datetime.now().addDays(-15); 
        b.Cuidarnos_Comunidad_Date__c = datetime.now().addDays(-15);
        insert b;

        Test.startTest();
            objSchedulable = new updateCuidarnosContactoEstrecho_Sch();
            objSchedulable.execute(null);
        Test.stopTest();
    }
}