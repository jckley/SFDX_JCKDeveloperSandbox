public class prosumer_gestor_dominiosController {
    @AuraEnabled
    public static List<Prosumer_Dominio_de_Email__c> getDominios(){
        Id accountId = Prosumer_AudienciaPageController.getAccountFromUser();
        return [SELECT Dominio_Verificado__c, id, Name FROM Prosumer_Dominio_de_Email__c WHERE Account__c =: accountId];
    }

    @AuraEnabled
    public static Prosumer_Dominio_de_Email__c insertDominio(String dominio){
        Id accountId = Prosumer_AudienciaPageController.getAccountFromUser();
        Prosumer_Dominio_de_Email__c nuevoDominio = new Prosumer_Dominio_de_Email__c();
        nuevoDominio.Account__c = accountId;
        nuevoDominio.Name = dominio;
        insert nuevoDominio;
        return nuevoDominio;
    }

    @AuraEnabled
    public static boolean deleteDominio(Id idDominio){
        Prosumer_Dominio_de_Email__c nuevoDominio = new Prosumer_Dominio_de_Email__c();
        nuevoDominio.id = idDominio;
        delete nuevoDominio;
        return true;
    }
}