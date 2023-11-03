@RestResource(urlMapping='/prosumerivr/stats/')
global class ProsumerIvrRESTInterface {
    global class Stats {
        global String id {get; set;}
        global String name {get; set;}
        global String type {get; set;}
        global String status {get; set;}
        global String from_date {get; set;}
        global String until_date {get; set;}
        global Integer processed_cases {get; set;}
        global Integer contacted_cases {get; set;}
        global Double processed_percent {get; set;}
        global Integer total_cases {get; set;}
    }
    
    @HttpGet 
    global static String isAlive() {
        return 'isAlive!';
    }

    @HttpPost
    global static Integer updateCampanias(List<Stats> lstStats) {
        List<Campania__c> campanias_to_update = new List<Campania__c>();

        List<String> sondeos_campaign_ids = new List<String>();
        for (Stats stat : lstStats) {
            sondeos_campaign_ids.add(stat.id);
        }

        List<Campania__c> campanias = new List<Campania__c>();
        campanias = [
            SELECT Id, Prosumer_Cantidad_Enviados__c, Prosumer_Cantidad_Entregados__c, Prosumer_Cantidad_No_Entregados__c, Prosumer_Sondeos_IVR_Campaign_Id__c, Prosumer_Estado__c
            FROM Campania__c 
            WHERE Prosumer_Sondeos_IVR_Campaign_Id__c in :sondeos_campaign_ids
            AND Prosumer_Estado__c <> 'Cerrado'
        ];
 
        Map<String, Campania__c> campanias_map = new Map<String, Campania__c>();
        for (Campania__c campania : campanias) {
            campanias_map.put(campania.Prosumer_Sondeos_IVR_Campaign_Id__c, campania);
        }

        for (Stats stat : lstStats) {
            Campania__c campania = campanias_map.get(stat.id);

            if (campania == null)
                continue;

            campania.Prosumer_Cantidad_Enviados__c = stat.processed_cases;
            campania.Prosumer_Cantidad_Entregados__c = stat.contacted_cases;
            campania.Prosumer_Cantidad_No_Entregados__c = stat.processed_cases - stat.contacted_cases;
            campania.Prosumer_Estado__c = (stat.status == 'Finished') ? 'Cerrado' : 'Campania Sondeos en Ejecución';

            campanias_to_update.add(campania);
        }

        DateTime dt = System.Now().addHours(-12);
        LIST<Campania__c> campanias_sin_cerrar = [
            SELECT Id, Prosumer_Cantidad_Enviados__c, Prosumer_Cantidad_Entregados__c, Prosumer_Cantidad_No_Entregados__c, Mobile_Connect_Campaign_Id__c, Message_Tracking_Last_Update__c, Prosumer_Estado__c
            FROM Campania__c 
            WHERE Prosumer_Estado__c in (NULL, 'En ejecucion', 'Send Automation en ejecución', 'Send Automation Iniciado', 'Export Finalizado OK')
            AND Prosumer_Sondeos_IVR_Campaign_Id__c <> null
            AND Prosumer_Sondeos_IVR_Campaign_Id__c NOT IN :sondeos_campaign_ids
            AND ((Message_Tracking_Last_Update__c = null AND CreatedDate < :dt) OR (Message_Tracking_Last_Update__c < :dt))
        ];

        for (Campania__c campania : campanias_sin_cerrar) {
            campania.Prosumer_Estado__c = 'Cerrado';
            campanias_to_update.add(campania);
        }

        if (campanias_to_update.size() > 0)
            update campanias_to_update;

        return 0;
    }

}