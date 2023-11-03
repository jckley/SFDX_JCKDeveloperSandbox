global class ContactsCSVBatch implements Database.Batchable<sObject>, Database.Stateful {
    global List<String> searchCriteria;
    String csvFileName= 'Contacts.csv';
    global String whereCondition;
    String CSVContent = 'Nombre,Identificador,UUID__c,Admin Level 1,Admin Level 2' + '\r\n';
    

    global ContactsCSVBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String dynamicQuery = 'SELECT Id, Name, UUID__c, BirthDate, Gender__c, Document_Number__c, Administrative_Level_1__c, Administrative_Level_2__c,' +  whereCondition + ' FROM Contact WHERE ' + whereCondition + ' IN :searchCriteria';
        system.debug(dynamicQuery);
        system.debug(searchCriteria);
        return Database.getQueryLocator(dynamicQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contacts) {                
        
        String comparing = '';
        for(Contact con : contacts) {
            if(con.Birthdate != NULL && con.Gender__c != NULL && con.Document_Number__c != NULL){
                CSVContent += con.Name + ',' + con.get(whereCondition) + ',' + con.UUID__c + ',' + con.Administrative_Level_1__c + ',' + con.Administrative_Level_2__c;
                CSVContent += '\r\n';
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvBlob = Blob.valueOf(CSVContent);
        csvAttc.setFileName(csvFileName);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {UserInfo.getUserEmail()};
       	String subject ='Resultado de busqueda de contactos';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Resultados de la busqueda de contactos');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }

}