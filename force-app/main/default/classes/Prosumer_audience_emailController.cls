public class Prosumer_audience_emailController {
    @AuraEnabled
    public static boolean consumeCredits(Decimal totalOfMobiles){
        Map<String, Decimal> values = Prosumer_AudienciaPageController.getUserCreditInformation();
        Decimal creditsToConsume = values.get('email_cost') * totalOfMobiles;
        Boolean enoughCredits = values.get('accountCredits') >= creditsToConsume;

        if(!enoughCredits){ return false;}

        Account acc = [SELECT Cantidad_Creditos__c FROM account WHERE id = :Prosumer_AudienciaPageController.getAccountFromUser()];
        acc.Cantidad_Creditos__c = acc.Cantidad_Creditos__c - creditsToConsume;
        update acc;

        return true;
    }

    @AuraEnabled
    public static Id createCampaing(String titulo, String saql, String filtros, 
                            Id emailId, Integer costo, Integer cantidadEmails, Integer personas, 
                            String asuntoCampania, String nombreRemitente, String emailRemitente){
            Campania__c campania = new Campania__c ();
            campania.name = titulo;
            campania.Prosumer_SAQL_Audiencias__c = saql;
            campania.Prosumer_Filtros_Audiencia__c = filtros;
            campania.Prosumer_email__c = emailId;
            campania.Prosumer_Creditos_Campania__c = costo;
            campania.Prosumer_cantidad_emails__c = cantidadEmails;
            campania.Prosumer_Tamanio_de_Audiencia__c = personas;
            campania.Prosumer_Cuenta_Cliente__c = Prosumer_AudienciaPageController.getAccountFromUser();
            campania.Prosumer_Fecha_de_Inicio__c = Datetime.now();
            campania.Project__c = getProject('ProsumerEmail');
            campania.Prosumer_Email_Asunto_Campania__c = asuntoCampania;
            campania.Prosumer_Email_Remitente_Nombre__c = nombreRemitente;
            campania.Prosumer_Email_Remitente_Email__c = emailRemitente;
            insert campania;
            return campania.id;
    }

    @testVisible
    private static Id getProject (String projectName) {
        List<Project__c> proyects = [SELECT id FROM Project__c WHERE NAME =:projectName];
        if(proyects.size() != 0){
            return proyects[0].id;
        }

        Project__c pj = new Project__c ();
        pj.name = projectName;
        insert pj;
        return pj.id;
    }
}