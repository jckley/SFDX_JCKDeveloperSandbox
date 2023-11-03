global without sharing class PRM_Cuidarnos_GET_IVRNumeral8_Batch  implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('PRM_Cuidarnos_GET_IVRNumeral8_Batch [start] ->');
        return Database.getQueryLocator(
                [SELECT Id , Covid19__c, Covid19__R.Citizen__c, Paciente_Phone__c
                 FROM IVR_Calls_Numeral8__c
                 WHERE Status__c = 'POST_OK']
        );
    }

    global void execute(Database.BatchableContext BC, List<IVR_Calls_Numeral8__c> lstLogs){
        System.debug('PRM_Cuidarnos_GET_IVRNumeral8_Batch [execute] ->');
        if (!lstLogs.isEmpty()) {
            System.debug('PRM_Cuidarnos_GET_IVRNumeral8_Batch [calls getRequestIVR] ->');
            List<String> lstLogIds = new List<String>();
            for(IVR_Calls_Numeral8__c objLog: lstLogs) {
                lstLogIds.add(objLog.Id);
            }
            PRM_Cuidarnos.getRequestIVRNumeral8(lstLogIds);
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}