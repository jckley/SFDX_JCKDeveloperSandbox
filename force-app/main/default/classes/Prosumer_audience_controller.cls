public without sharing class Prosumer_audience_controller {
    @AuraEnabled
    public static boolean consumeCredits(Decimal totalOfMobiles){
        Map<String, Decimal> values = Prosumer_AudienciaPageController.getUserCreditInformation();
        Decimal creditsToConsume = values.get('sms_cost') * totalOfMobiles;
        Boolean enoughCredits = values.get('accountCredits') >= creditsToConsume;

        if(!enoughCredits){ return false;}

        Account acc = [SELECT Cantidad_Creditos__c FROM account WHERE id = :Prosumer_AudienciaPageController.getAccountFromUser()];
        acc.Cantidad_Creditos__c = acc.Cantidad_Creditos__c - creditsToConsume;
        update acc;

        return true;
    }

    @AuraEnabled
    public static Id createCampaing(String titulo, String saql, String filtros, String msj, Integer costo, Integer moviles, Integer personas){
        try {
            Campania__c campania = new Campania__c ();
            campania.name = titulo;
            campania.Prosumer_SAQL_Audiencias__c = saql;
            campania.Prosumer_Filtros_Audiencia__c = filtros;
            campania.Prosumer_Mensaje_SMS__c = msj;
            campania.Prosumer_Creditos_Campania__c = costo;
            campania.Prosumer_Moviles_en_Audiencia__c = moviles;
            campania.Prosumer_Tamanio_de_Audiencia__c = personas;
            campania.Prosumer_Cuenta_Cliente__c = Prosumer_AudienciaPageController.getAccountFromUser();
            campania.Prosumer_Fecha_de_Inicio__c = Datetime.now();
            campania.Project__c = getProject('ProsumerSMS');
            insert campania;
            return campania.id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id createCampaignIVR(String titulo, String saql, String filtros, String audiofileid, Integer costo, Integer moviles, Integer personas, Datetime fecha_inicio, Datetime fecha_finalizacion, String hora_inicio, String hora_finalizacion){
        try {
            Campania__c campania = new Campania__c ();
            campania.name = titulo;
            campania.Prosumer_SAQL_Audiencias__c = saql;
            campania.Prosumer_Filtros_Audiencia__c = filtros;
            campania.Prosumer_Mensaje_Audio__c = audiofileid;
            campania.Prosumer_Creditos_Campania__c = costo;
            campania.Prosumer_Moviles_en_Audiencia__c = moviles;
            campania.Prosumer_Tamanio_de_Audiencia__c = personas;
            campania.Prosumer_Cuenta_Cliente__c = Prosumer_AudienciaPageController.getAccountFromUser();
            // campania.Prosumer_Fecha_de_Inicio__c = Datetime.now();
            campania.Prosumer_Fecha_de_Inicio__c = fecha_inicio;
            campania.Prosumer_Fecha_de_Finalizacion__c = fecha_finalizacion;
            campania.Prosumer_Hora_de_Inicio__c = hora_inicio;
            campania.Prosumer_Hora_de_Finalizacion__c = hora_finalizacion;
            campania.Project__c = getProject('ProsumerIVR');
            insert campania;
            return campania.id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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