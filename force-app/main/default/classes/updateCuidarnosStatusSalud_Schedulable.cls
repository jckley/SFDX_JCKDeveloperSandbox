global class updateCuidarnosStatusSalud_Schedulable implements Schedulable{

    public static String CRON_EXP = '0 0 4 * * ?';

    global void execute(SchedulableContext objSchedulableContext) { 

        List<Covid19__c> lstCuidarnosCovid = [
            SELECT Id , Citizen__c, Cuidarnos_Comunidad_Status__c , LastModifiedDate,Cuidarnos_Comunidad_Date__c
            FROM Covid19__c
            WHERE Cuidarnos_Comunidad_Status__c = 'Sintomático'
            AND Cuidarnos_Comunidad_Date__c < LAST_N_DAYS:5
            LIMIT 15
        ];

        if(!lstCuidarnosCovid.IsEmpty()) {
            for (Covid19__c objCovid19: lstCuidarnosCovid) {
                PRM_Cuidarnos.updateStatusInSalesforce(objCovid19.Citizen__c, 'Descartado');
            }
        }

    }

}