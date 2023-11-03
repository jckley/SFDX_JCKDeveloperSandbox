@isTest
public class Prosumer_DashboardControllerTest {

    @isTest
    public static void testQuerys () {
        //just querys, this could be done directly with the Lightning Data Service but I haven't time to check
        Account acc = new Account();
        acc.name = 'PROSUMER ADMINS DEFAULT ACCOUNT';
        insert acc;

        Project__c pj = new Project__c ();
        pj.name = 'TEST';
        insert pj;

        Campania__c campania = new Campania__c ();
        campania.name = 'TEST TITULO';
        campania.Prosumer_SAQL_Audiencias__c = 'TEST SAQL, deberia ser una correcta, pero no hace diferencia';
        campania.Prosumer_Filtros_Audiencia__c = 'TEST JSON de FILTROS VA A ACA';
        campania.Prosumer_Mensaje_SMS__c = 'ACA VA UN MSJ DE TEXTO';
        campania.Prosumer_Creditos_Campania__c = 123;
        campania.Prosumer_Moviles_en_Audiencia__c = 5;
        campania.Prosumer_Tamanio_de_Audiencia__c = 5;
        campania.Prosumer_Fecha_de_Inicio__c = Datetime.now();
        campania.Project__c = pj.id;
        campania.Prosumer_Cuenta_Cliente__c = acc.id;
        insert campania;

        System.assertEquals(1, Prosumer_DashboardController.getCampanias().size(), 'Debe recuperar la lista de campañas, de tamaño 1.');
        System.assertEquals(campania.id, Prosumer_DashboardController.getCampania(campania.id).id, 'Debe recuperar la campaña');
    }
}