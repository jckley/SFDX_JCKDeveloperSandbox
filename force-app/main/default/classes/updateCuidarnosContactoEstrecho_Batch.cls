global  without sharing class updateCuidarnosContactoEstrecho_Batch  implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT Id , Citizen__c, Cuidarnos_Comunidad_Status__c , LastModifiedDate, Cuidarnos_Comunidad_Date__c, Estado_Epidemiologico__c, Contacto_Estrecho__c, Contacto_Estrecho_GUID__c
            FROM Covid19__c
            WHERE Contacto_Estrecho__c = True
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Covid19__c> lstCuidarnosCovid){
        for (Covid19__c objCovid19: lstCuidarnosCovid) {
            try {

                // UPDATE Status to DETECTABLE
                objCovid19.Cuidarnos_Muestra_Result__c = 'Detectable';
                objCovid19.Cuidarnos_Muestra_Result_Date__c = DateTime.now();
                objCovid19.Cuidarnos_Comunidad_Status__c = 'Detectable';
                objCovid19.Cuidarnos_Comunidad_Date__c = DateTime.now();
                
                // NOTIFY User
                PRM_Cuidarnos.saveUserObservationsInSalesforce(objCovid19.Citizen__c, 'El usuario fue notificado');
                PRM_Cuidarnos.publicNotifyUserSMSFuture(objCovid19.Citizen__c);
    
                // UPDATE status to NOTIFICADO
                objCovid19.Cuidarnos_Comunidad_Status__c = 'Notificado';
                objCovid19.Cuidarnos_Comunidad_Date__c = DateTime.now();
                objCovid19.Notificacion_Date__c = DateTime.now();

                // CLEAN Archive Date and Estado Epidemiologico
                objCovid19.Archive_Date__c = null;
                objCovid19.Estado_Epidemiologico__c = null;

                // ADD Observation Message
                String observation = 'Ciudadano en estado DETECTABLE por contacto estrecho.';
                if (!String.isBlank(objCovid19.Contacto_Estrecho_GUID__c)) {
                    List<Contact> lstContactoEstrecho = [SELECT Id, Name FROM Contact WHERE guid__c = :objCovid19.Contacto_Estrecho_GUID__c];
                    if (!lstContactoEstrecho.isEmpty()) {
                        observation = 'Ciudadano en estado DETECTABLE por contacto estrecho con ' + lstContactoEstrecho[0].Name;
                    }
                }
                PRM_Cuidarnos.saveUserObservationsInSalesforce(objCovid19.Citizen__c, observation);

                // CLEAN Contacto Estrecho to FALSE to avoid re-processing
                objCovid19.Contacto_Estrecho__c = false;
                objCovid19.Contacto_Estrecho_GUID__c = null;

                // UPDATE Covid19 Object
                update objCovid19;
                
            } catch (Exception e) {
                System.debug('An exception occurred: ' + e.getMessage());
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}