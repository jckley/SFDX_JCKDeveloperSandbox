public class UpdateSearchCriteriaBatch implements Database.Batchable<sObject>{

    public String query = 'SELECT Birthdate, Gender__c, Document_Number__c, SearchCriteria__c FROM Contact WHERE SearchCriteria__c = NULL';
    public Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> contacts) {                
        
        List<Contact> contToUpdate = new List<Contact>();
        for(Contact con : contacts) {
            String searchCriteria = '';
            if(con.Birthdate != NULL){
                searchCriteria += Datetime.newInstance(con.Birthdate, Time.newInstance(1, 1, 1, 0)).format('dd/MM/yyyy');
            }
            searchCriteria += con.Gender__c;
            if(con.Document_Number__c != NULL){
            	searchCriteria += con.Document_Number__c.substring(con.Document_Number__c.length() - 3, con.Document_Number__c.length());   
            }
            con.SearchCriteria__c = searchCriteria;
            contToUpdate.add(con);
        }
        update contToUpdate;
    }
    
    public void finish(Database.BatchableContext BC) {}

}