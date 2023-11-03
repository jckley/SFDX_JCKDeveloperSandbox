public class AdFi_ConnectedPeopleController {
	@AuraEnabled
    public static RemotingMessageHelper.Citizen[] retrieveRandomConnectedPeople(Integer intCitizensToRetrieve) {
     	List<RemotingMessageHelper.Citizen> lstCitizens = NULL;
        RemotingMessageHelper.Citizen objCitizen = NULL;
        Integer intRandom = NULL;
        Integer intLimit = NULL;
        Integer intRecordCount = null;
        List<Contact> lstContacts = null;
        System.debug('retrieveRandomConnectedPeople [ intCitizensToRetrieve : ' + intCitizensToRetrieve + '] ->');
       
        System.debug('retrieveRandomConnectedPeople [ intLimit : ' + intLimit + ']');
        System.debug('retrieveRandomConnectedPeople [ intRandom : ' + intRandom + ']');
        
        intRecordCount = Database.countQuery('SELECT COUNT() FROM Contact WHERE ADFi_Profile_ID__c <> NULL'); 
        intRecordCount = (intRecordCount > 2000)?2000:intRecordCount;
        
        intLimit = Integer.valueOf(intCitizensToRetrieve);
        intRandom = (Math.random() * (intRecordCount - intLimit)).intValue();
        intRandom = (intRandom < 0)?0:intRandom;
        
        lstContacts = [SELECT Id, FirstName, LastName, Email, MobilePhone, PhotoUrl_legacy__c
                       FROM Contact
                       WHERE ADFi_Profile_ID__c <> NULL    
                       //AND PhotoUrl_legacy__c <> NULL
                       LIMIT :intLimit
                       OFFSET :intRandom];
          
        lstCitizens = new List<RemotingMessageHelper.Citizen>();
        for(Contact objContactC : lstContacts) {
            objCitizen = new RemotingMessageHelper.Citizen(objContactC);
            lstCitizens.add(objCitizen);            
        }
        
        System.debug('retrieveRandomConnectedPeople [ ' + lstCitizens + '] <-');

        return lstCitizens;
    }
 }