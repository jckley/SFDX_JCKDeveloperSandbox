global  without sharing class PRM_Cuidarnos_POST_IVRNumeral8_Batch  implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('PRM_Cuidarnos_POST_IVRNumeral8_Batch [start] ->');
        return Database.getQueryLocator(
                [SELECT Id , Citizen__c, Cuidarnos_Comunidad_Status__c , LastModifiedDate, Cuidarnos_Comunidad_Date__c, Riesgo__c, proactiva_risk__c, Mobile_Phone__c
                 FROM Covid19__c
                 WHERE Cuidarnos_Comunidad_Status__c IN ('Seguimiento COH', 'Seguimiento')
                 AND Riesgo__c = 'Bajo'
                 AND Mobile_Phone__c != NULL]
        );
    }


    global void execute(Database.BatchableContext BC, List<Covid19__c> lstCuidarnosCovid){
        System.debug('PRM_Cuidarnos_POST_IVRNumeral8_Batch [execute] ->');
        if (!lstCuidarnosCovid.isEmpty()) {
            System.debug('PRM_Cuidarnos_POST_IVRNumeral8_Batch [calls postRequestIVR] ->');
            PRM_Cuidarnos.postRequestIVRNumeral8(lstCuidarnosCovid);
        }
    }


    global void finish(Database.BatchableContext BC) {

    }
}