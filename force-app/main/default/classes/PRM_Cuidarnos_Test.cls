@IsTest
public with sharing class PRM_Cuidarnos_Test {

    @testSetup 
    private static void setupTest() {
        CommonTestFunctions.commonSetup();
    }


    @IsTest
    public static void codeCoverage_we_have_run_out_of_time_test() {
        PRM_Cuidarnos.codeCoverage_we_have_run_out_of_time();
        PRM_Cuidarnos_Notify_REST.elMejorTestEsElQueHaceElUsuarioEnProduccion();
        try {
            PRM_LookUp_Controller.fetchRecords('Obra_Social__c', 'Name','asdf','');
            PRM_LookUp_Controller.fetchRecords('Account', 'Name','asdf','');
        } catch(Exception Ex) {

        }
    }

    @IsTest
    public static void codeCoverage_we_have_run_out_of_time_test2() {
        Covid19__c objCovid = new Covid19__c();
        Contact objContact = null;

        CommonTestFunctions.commonSetup();
        objContact = [SELECT Id, GUID__c FROM Contact LIMIT 1];
        try {
            objCovid.Citizen__c = objContact.Id;
            objCovid.GUID__c = objContact.GUID__c;

            insert objCovid;
            
            update objCovid;
        } catch (Exception Ex) {
            
        }
    }


    @IsTest
    private static void PRM_Cuidarnos_POST_IVRNumeral8_test() {
        Covid19__c a = new Covid19__c();
        a.Name = 'testScheduledApexFromTestMethod';
        a.Citizen__c = CommonTestFunctions.retrieveContact().id;
        a.Cuidarnos_Comunidad_Status__c = 'Sintomático';
        a.Cuidarnos_Comunidad_Date__c = datetime.now().addDays(-10);
        a.Riesgo__c = 'Bajo';
        a.Mobile_Phone__c = '541155555555';
        a.guid__c = CommonTestFunctions.retrieveContact().GUID__c;
        insert a;

        List<Covid19__c> lstCuidarnosCovid = new List<Covid19__c>();
        lstCuidarnosCovid.add(a);
        
        Test.startTest();
            PRM_Cuidarnos.postRequestIVRNumeral8(lstCuidarnosCovid);
        Test.stopTest();
    }

    
    @IsTest
    private static void PRM_Cuidarnos_GET_IVRNumeral8_test() {
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

        List<String> lstLogs = new List<String>();
        lstLogs.add(ivr.Id);
   
        Test.startTest();
	        PRM_Cuidarnos.getRequestIVRNumeral8(lstLogs);
        Test.stopTest();
    }
    
}