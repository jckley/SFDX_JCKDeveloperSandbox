public class UpdateEdadFieldBatch implements Database.Batchable<sObject>{

    public String query1 = 'SELECT LastName,Birthdate,Edad__c FROM Contact WHERE birthdate != NULL';
    public String query2 = 'SELECT LastName,Birthdate,Edad__c FROM Contact WHERE Birthdate=THIS_WEEK';
    public boolean runForAll=false;
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        if (runForAll==True) {
            return Database.getQueryLocator(query1);
        } else {
            return Database.getQueryLocator(query2);
        }        
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> contacts) {                
        
        List<Contact> contToUpdate = new List<Contact>();
        for(Contact con : contacts) {
            
            date dt=con.Birthdate;
            Integer totaldays=dt.daysBetween(system.today());
			con.Edad__c=(integer)(math.Floor(totaldays/365.2425));
            contToUpdate.add(con);
        }
        update contToUpdate;
    }
    
    public void finish(Database.BatchableContext BC) {}

}