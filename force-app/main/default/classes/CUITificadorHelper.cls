public class CUITificadorHelper {
    public static void cuitificateLead(Lead objLead) {
        List<Contact> lstContact = null;
        Contact objContact = null;
        
        try {
            lstContact = cuitificateByEmailBirthYear(objLead);
            
            if(lstContact == NULL || lstContact.size() != 1) {
                lstContact = cuitificateByFirstNameLastNameBirthDate(objLead);
            } 
            
            if(lstContact == NULL || lstContact.size() != 1) {
                lstContact = cuitificateByEmailBirthDate(objLead);
            } 
            
            if(lstContact != NULL && lstContact.size() == 1) {
                objLead.Citizen__c = lstContact[0].Id;
                update objLead;
            }
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);
        }
    }
    
    private static List<Contact> cuitificateByEmailBirthYear(Lead objLead) {
        List<Contact> lstContact = null;
        Integer intYear = NULL;
        
        System.debug('cuitificateByEmailBirthYear [ objLead : ' + objLead + '] ->');
        if(objLead != NULL && String.isNotBlank(objLead.Email) && objLead.Birthdate__c != NULL) {
            intYear = objLead.Birthdate__c.year();
            
            lstContact = [SELECT Id 
                          FROM Contact
                          WHERE Email =: objLead.Email 
                          AND CALENDAR_YEAR(BirthDate) =: intYear];
            
        }
        
        System.debug('cuitificateByEmailBirthYear [' + lstContact + '] <-');

        return lstContact;        
    }
    
    private static List<Contact> cuitificateByFirstNameLastNameBirthDate(Lead objLead) {
        List<Contact> lstContact = null;
        
        System.debug('cuitificateByFirstNameLastNameBirthDate [ objLead : ' + objLead + '] ->');
                
        if(objLead != NULL && String.isNotBlank(objLead.FirstName) && String.isNotBlank(objLead.LastName) && objLead.Birthdate__c != NULL) {
            lstContact = [SELECT Id 
                          FROM Contact
                          WHERE FirstName =: objLead.FirstName 
                          AND LastName =: objLead.LastName
                          AND BirthDate =: objLead.Birthdate__c];
        }
        
        System.debug('cuitificateByFirstNameLastNameBirthDate [' + lstContact + '] <-');

        return lstContact;     
    }
    
    private static List<Contact> cuitificateByEmailBirthDate(Lead objLead) {
        List<Contact> lstContact = null;
        
        System.debug('cuitificateByEmailBirthDate [ objLead : ' + objLead + '] ->');

        if(objLead != NULL && String.isNotBlank(objLead.Email) && objLead.Birthdate__c != NULL) {
            lstContact = [SELECT Id 
                          FROM Contact
                          WHERE Email =: objLead.Email 
                          AND BirthDate =: objLead.Birthdate__c];
        }
        
        System.debug('cuitificateByEmailBirthDate [' + lstContact + '] <-');

        return lstContact;      
    } 
}