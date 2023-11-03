@isTest
public class Prosumer_AudienciaPageControllerTest {
    @isTest
    public static void testGetProsumerAudienciaCriteria(){
        //el SAQL_Sharing_Criteria__c es el importante
        Account acc = new Account ();
        acc.name = 'PROSUMER ADMINS DEFAULT ACCOUNT';
        acc.SAQL_Sharing_Criteria__c = '(\'CI_Asalariado\' == 1 || \'CI_Cuentapropista\' == 1)';
        acc.Cantidad_Creditos__c = 10;
        acc.Creditos_Email__c = 1;
        acc.Creditos_IVR__c = 1;
        acc.Creditos_SMS__c = 1;
        acc.Prosumer_Sharing_Id__c = 'A1';
        acc.Sharing_Criteria__c = 'String, not being used really.';
        
        insert acc;

        Prosumer_AudienciaPageController.getProsumerAudienceCriterias();
    }

    @isTest
    public static void testGetProsumerAudienciaCriteria_sinCuentaPrevia(){
        //si la cuenta no existe debe crearla
        Prosumer_AudienciaPageController.getProsumerAudienceCriterias();
    }

    @isTest
    public static void testGetUserCreditInformation(){
        //el SAQL_Sharing_Criteria__c es el importante
        Account acc = new Account ();
        acc.name = 'PROSUMER ADMINS DEFAULT ACCOUNT';
        acc.SAQL_Sharing_Criteria__c = '(\'CI_Asalariado\' == 1 || \'CI_Cuentapropista\' == 1)';
        acc.Cantidad_Creditos__c = 10;
        acc.Creditos_Email__c = 1;
        acc.Creditos_IVR__c = 1;
        acc.Creditos_SMS__c = 1;
        acc.Prosumer_Sharing_Id__c = 'A1';
        acc.Sharing_Criteria__c = 'String, not being used really.';
        
        insert acc;

        Prosumer_AudienciaPageController.getUserCreditInformation();
    }
}