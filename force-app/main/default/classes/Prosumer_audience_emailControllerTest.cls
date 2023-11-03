@isTest
public class Prosumer_audience_emailControllerTest {
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

        System.assertEquals(false, Prosumer_audience_emailController.consumeCredits (11), 'NO deberia poder consumir mas creditos de los que tiene disponibles');
        System.assertEquals(true, Prosumer_audience_emailController.consumeCredits (8), 'Deberia retornar true si fue capaz de consumir los creditos');
        Account updatedAcc = [SELECT Cantidad_Creditos__c FROM account WHERE id =:  acc.id];
        System.assertEquals(2, updatedAcc.Cantidad_Creditos__c, 'Luego de consumir 8 creditos deben restarle 2');
    }

    @isTest
    public static void testCreateCampaing() {
        Prosumer_email__c emailRecord = new Prosumer_email__c();
        emailRecord.name = 'test';
        insert emailRecord;

        //String titulo, String saql, String filtros, 
        //Id emailId, Integer costo, Integer cantidadEmails, Integer personas, 
        //String asuntoCampania, String nombreRemitente, String emailRemitente

        Prosumer_audience_emailController.createCampaing('String titulo', 'String saql', 'String filtros',
                                                                emailRecord.Id, 5, 5, 5,
                                                                'asunto', 'nombre', 'email@test.com');
        
        List<Campania__c> campanias = [SELECT id FROM Campania__c WHERE name = 'String titulo'];

        System.assertEquals(1, campanias.size(), 'Debe haberse creado la campaña');
    }
}