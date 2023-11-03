@isTest
public class prosumer_gestor_dominiosControllerTest {
    @TestSetup
    static void makeData(){
        Id adminAccountId = Prosumer_AudienciaPageController.getAccountFromUser();
    }

    @isTest
    public static void getDominiosTest (){
        prosumer_gestor_dominiosController.getDominios();
    }

    @isTest
    public static void insertDominioTest (){
        prosumer_gestor_dominiosController.insertDominio('@test.com');
    }

    @isTest
    public static void deleteDominioTest (){
        Prosumer_Dominio_de_Email__c dominio = new Prosumer_Dominio_de_Email__c();
        dominio.name = '@test.com';
        insert dominio;
        prosumer_gestor_dominiosController.deleteDominio(dominio.id);
    }
}