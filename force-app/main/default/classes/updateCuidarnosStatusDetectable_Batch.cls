global  without sharing class updateCuidarnosStatusDetectable_Batch  implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT Id , Citizen__c, Cuidarnos_Comunidad_Status__c , LastModifiedDate, Cuidarnos_Comunidad_Date__c, Estado_Epidemiologico__c
            FROM Covid19__c
            WHERE Cuidarnos_Muestra_Result__c = 'Detectable' AND Cuidarnos_Muestra_Result_Date__c < LAST_N_DAYS:7 
                AND Cuidarnos_Comunidad_Status__c = 'Notificado' // AND Estado_Epidemiologico__c != 'Alta'
            ORDER BY Cuidarnos_Muestra_Result_Date__c ASC
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Covid19__c> lstCuidarnosCovid){
        for (Covid19__c objCovid19: lstCuidarnosCovid) {
            try {
                objCovid19.Cuidarnos_Comunidad_Status__c = 'Archivado';            
                objCovid19.Cuidarnos_Comunidad_Date__c = DateTime.now();
                objCovid19.Archive_Date__c = DateTime.now();
                objCovid19.Estado_Epidemiologico__c = 'Alta';

                PRM_Cuidarnos.saveUserObservationsInSalesforce(objCovid19.Citizen__c, 'Archivado/Alta automática transcurrido 7 días de Detectado.');
            } catch (Exception e) {
                System.debug('An exception occurred: ' + e.getMessage());
            }
        }
        update lstCuidarnosCovid;
    }

    global void finish(Database.BatchableContext BC) {
    }
}