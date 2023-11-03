@RestResource(urlMapping='/prosumer/stats/')
global class ProsumerRESTInterface {
    global class Stats {
        global Integer intMCCampaignId  {get; set;}
        global String strMessage       {get; set;}
        global Integer intMessagesSent {get; set;}
        global Integer intMessagesDelivered {get; set;}
        global Integer intMessagesUndelivered {get; set;}
    }
    
    @HttpGet 
    global static String isAlive() {
        return 'isAlive!';
    }

    @HttpPost
    global static Integer updateCampanias(List<Stats> lstStats) {
        List<Campania__c> campanias_to_update = new List<Campania__c>();
        List<Stats> stats_not_found = new List<Stats>();

        List<Integer> mc_campaign_ids = new List<Integer>();
        for (Stats stat : lstStats) {
            mc_campaign_ids.add(stat.intMCCampaignId);
        }

        List<Campania__c> campanias = new List<Campania__c>();
        campanias = [
            SELECT Id, Prosumer_Cantidad_Enviados__c, Prosumer_Cantidad_Entregados__c, Prosumer_Cantidad_No_Entregados__c, Mobile_Connect_Campaign_Id__c, Message_Tracking_Last_Update__c, Prosumer_Estado__c
            FROM Campania__c 
            WHERE Mobile_Connect_Campaign_Id__c in :mc_campaign_ids
        ];

        for (Stats stat : lstStats) {
            Boolean found = false;

            for (Campania__c campania : campanias) {
                if (campania.Mobile_Connect_Campaign_Id__c == stat.intMCCampaignId) {
                    if (campania.Prosumer_Estado__c != 'Cerrado') {
                        campania.Prosumer_Cantidad_Enviados__c = stat.intMessagesSent;
                        campania.Prosumer_Cantidad_Entregados__c = stat.intMessagesDelivered;
                        campania.Prosumer_Cantidad_No_Entregados__c = stat.intMessagesUndelivered;
                        campania.Message_Tracking_Last_Update__c = DateTime.Now();
                        if ((Double)campania.Prosumer_Cantidad_Entregados__c / (Double)campania.Prosumer_Cantidad_Enviados__c > 0.8)
                            campania.Prosumer_Estado__c = 'Cerrado';
                        else 
                            campania.Prosumer_Estado__c = 'Send Automation en ejecución';
                        campanias_to_update.add(campania);
                    }
                    found = true;
                    break;
                }
            }

            if (!found) {
                stats_not_found.add(stat);
            }
        }

        List<Campania__c> campanias_sin_campaing_id = new List<Campania__c>();
        if (!stats_not_found.isEmpty()) {
            campanias_sin_campaing_id = [
                SELECT Id, Prosumer_Cantidad_Enviados__c, Prosumer_Cantidad_Entregados__c, Prosumer_Cantidad_No_Entregados__c, Mobile_Connect_Campaign_Id__c, Message_Tracking_Last_Update__c, Prosumer_Estado__c, Prosumer_Mensaje_SMS__c, CreatedDate
                FROM Campania__c 
                WHERE Mobile_Connect_Campaign_Id__c = NULL
            ];

            for (Stats stat : stats_not_found) {
                Campania__c best_campania;
                Integer min_distance = 1000000;
                for (Campania__c campania : campanias_sin_campaing_id) {
                    
                    if (String.isBlank(campania.Prosumer_Mensaje_SMS__c))
                        continue;
                    
                    Integer distance = stat.strMessage.getLevenshteinDistance(campania.Prosumer_Mensaje_SMS__c);
                    if (distance < min_distance) {
                        best_campania = campania;
                        min_distance = distance;
                    }
                }

                if (best_campania == null)
                    continue;

                best_campania.Prosumer_Cantidad_Enviados__c = stat.intMessagesSent;
                best_campania.Prosumer_Cantidad_Entregados__c = stat.intMessagesDelivered;
                best_campania.Prosumer_Cantidad_No_Entregados__c = stat.intMessagesUndelivered;
                best_campania.Mobile_Connect_Campaign_Id__c = stat.intMCCampaignId;
                best_campania.Message_Tracking_Last_Update__c = DateTime.Now();
                if ((Double)stat.intMessagesDelivered / (Double)stat.intMessagesSent > 0.8)
                    best_campania.Prosumer_Estado__c = 'Cerrado';
                else 
                    best_campania.Prosumer_Estado__c = 'Send Automation en ejecución';
                campanias_to_update.add(best_campania);
            }
        }

        DateTime dt = System.Now().addHours(-12);
        LIST<Campania__c> campanias_sin_cerrar = [
            SELECT Id, Prosumer_Cantidad_Enviados__c, Prosumer_Cantidad_Entregados__c, Prosumer_Cantidad_No_Entregados__c, Mobile_Connect_Campaign_Id__c, Message_Tracking_Last_Update__c, Prosumer_Estado__c
            FROM Campania__c 
            WHERE Prosumer_Estado__c in (NULL, 'En ejecucion', 'Send Automation en ejecución', 'Send Automation Iniciado', 'Export Finalizado OK') 
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