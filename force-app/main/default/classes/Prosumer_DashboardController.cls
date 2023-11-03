public without sharing class Prosumer_DashboardController {
    
    @AuraEnabled
    public static List<Campania__c> getCampanias () {
        return [SELECT Id, Name, Prosumer_Estado__c, FORMAT(Prosumer_Fecha_de_Inicio__c) Desde, Prosumer_Moviles_en_Audiencia__c
                FROM Campania__c
                WHERE Prosumer_Cuenta_Cliente__c =: Prosumer_AudienciaPageController.getAccountFromUser()
                ORDER BY Prosumer_Fecha_de_Inicio__c DESC];
    }

    @AuraEnabled
    public static Campania__c getCampania (Id id) {
        return [SELECT Id, Name, Prosumer_Estado__c, Prosumer_Creditos_Campania__c,
                        FORMAT(Prosumer_Fecha_de_Inicio__c) Desde, Prosumer_Moviles_en_Audiencia__c,
                        Prosumer_Mensaje_SMS__c, Prosumer_Tamanio_de_Audiencia__c, Prosumer_Filtros_Audiencia__c, Prosumer_Cantidad_Entregados__c, Prosumer_Cantidad_No_Entregados__c
                FROM Campania__c
                WHERE id=: id];
    }
}