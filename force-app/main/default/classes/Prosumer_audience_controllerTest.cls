@isTest
public class Prosumer_audience_controllerTest {
    @isTest
    public static void testConsumeCredits() {
        Account acc = new Account ();
        acc.name = 'PROSUMER ADMINS DEFAULT ACCOUNT';
        acc.SAQL_Sharing_Criteria__c = '(\'CI_Asalariado\' == 1 || \'CI_Cuentapropista\' == 1)';
        acc.Cantidad_Creditos__c = 10;
        acc.Creditos_Email__c = 1;
        acc.Creditos_IVR__c = 1;
        acc.Creditos_SMS__c = 1;
        
        insert acc;

        System.assertEquals(false, Prosumer_audience_controller.consumeCredits (11), 'NO deberia poder consumir mas creditos de los que tiene disponibles');
        System.assertEquals(true, Prosumer_audience_controller.consumeCredits (8), 'Deberia retornar true si fue capaz de consumir los creditos');
        Account updatedAcc = [SELECT Cantidad_Creditos__c FROM account WHERE id =:  acc.id];
        System.assertEquals(2, updatedAcc.Cantidad_Creditos__c, 'Luego de consumir 8 creditos deben restarle 2');
    }

    @isTest
    public static void testCreateCampaing() {
        Prosumer_audience_controller.createCampaing('String titulo', 'String saql', 'String filtros', 'String msj', 5, 5, 5);
        List<Campania__c> campanias = [SELECT id FROM Campania__c WHERE name = 'String titulo'];

        System.assertEquals(1, campanias.size(), 'Debe haberse creado la campaña');
    }

    @isTest
    public static void testCreateCampaingIVR() {
        Prosumer_audience_controller.createCampaignIVR('String titulo', 'String saql', 'String filtros', 'audiofileid', 5, 5, 5, Datetime.now(), Datetime.now(), '08:00', '18:00');
        List<Campania__c> campanias = [SELECT id FROM Campania__c WHERE name = 'String titulo'];

        System.assertEquals(1, campanias.size(), 'Debe haberse creado la campaña');
    }
    
}