global class pulso_admin_generar_audiencia implements 
Database.Batchable<sObject>, Database.Stateful {
    //Class Constructor 
    global String query;
    global List<String> Ids;
    global String surveyId;
    global String dataExtension;
    global List<String> fields;
    global pulso_admin_generar_audiencia (String xsurveyId, List<String> xoptionsId, String xdataExtension){
        this.Ids = xoptionsId;
        this.surveyId = xsurveyId;
        this.dataExtension = xdataExtension;
        this.fields = new List<String>{'Nombre', 'eMail'};
        
        this.query = 'SELECT Id, Lead__r.FirstName, Lead__r.LastName, ' +
                            '(SELECT ID ' +
                            'FROM User_Survey_Answers__r ' +  
                            'WHERE Survey_Available_Option__c ' + 
                            'IN :Ids)' +
                    'FROM User_Survey__c ' + 
                    'WHERE Survey__c = :surveyId';
        System.debug(this.query);
    }
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }
    
    global Set<User_Survey__c> surveyUsers = new Set<User_Survey__c>();
    global void execute(Database.BatchableContext bc, List<User_Survey__c> scope) {
        // process each batch of records
        System.debug('Im in the execute function');
        for (User_Survey__c answer : scope) {
            if (answer.User_Survey_Answers__r.size() == Ids.size()) {
                surveyUsers.add(answer);
            }
            System.debug(answer);
            recordsProcessed += 1;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug(recordsProcessed + ' records processed!');
        System.debug('Set size = ' + surveyUsers.size());
        SendNuevaAudienciaToMC audiencia = new SendNuevaAudienciaToMC(dataExtension, surveyId, surveyUsers, fields);
        ID jobID = System.enqueueJob(audiencia);
    }
    
}