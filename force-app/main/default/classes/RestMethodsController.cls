public class RestMethodsController {
    public static List<RemotingMessageHelper.CitizenFound> retrieveCuits(RemotingMessageHelper.CUITRequest objRequest) {
        List<Contact> lstContacts = null;
        List<RemotingMessageHelper.CitizenFound> lstCitizensFound = null;
        String strSOQL = null;
        Integer intBirthYear = null;
        Integer intBirthMonth = null;
        Integer intBirthDay = null;
        Integer intAdFiProfileId = null;
        String strName = null;
        String strFirstName = null;
        String strLastName = null;
        String strEmail = null; 
        String strGender = null; 
        
        System.debug('retrieveCuits [ objRequest : ' + objRequest + ' ] -> ');
                        
        lstCitizensFound = new List<RemotingMessageHelper.CitizenFound>();
        
        if(objRequest != NULL) {
            strSOQL = 'SELECT Name, FirstName, LastName, Administrative_Level_1__c, Administrative_Level_2__c, Administrative_Level_3__c, Administrative_Level_4__c, Birthdate, Cuil_Number__c, Gender__c, ADFi_Profile_ID__c ';
            strSOQL += 'FROM Contact ';
            strSOQL += 'WHERE Id <> NULL ';
            
            if( String.isNotBlank(objRequest.FullName)) {
                strName = objRequest.FullName;
                     
                strSOQL += ' AND Name LIKE \'%' + String.escapeSingleQuotes(strName) + '%\' ';                    
            }
            
            if( String.isNotBlank(objRequest.FirstName)) {
                strFirstName = objRequest.FirstName;
                     
                strSOQL += ' AND FirstName LIKE \'%' + String.escapeSingleQuotes(strFirstName) + '%\' ';                    
            }
            
            if(String.isNotBlank(objRequest.LastName)) {
                strLastName = objRequest.LastName;
                
                strSOQL += ' AND LastName = :strLastName ';
            }
            
            if(String.isNotBlank(objRequest.Email)) {
                strEmail = objRequest.Email;
                
                strSOQL += ' AND Email = :strEmail ';
            }
            
            if(String.isNotBlank(objRequest.Gender)) {
                strGender = objRequest.Gender;
                
                strSOQL += ' AND Gender__c  = :strGender ';
            }
            
            if(objRequest.BirthYear != NULL) {
                intBirthYear = objRequest.BirthYear;
                strSOQL += ' AND CALENDAR_YEAR(BirthDate) = :intBirthYear ';
            }
            if(objRequest.BirthMonth != NULL) {
                intBirthMonth = objRequest.BirthMonth;
                strSOQL += ' AND CALENDAR_MONTH(BirthDate) = :intBirthMonth ';
            }
            
            if(objRequest.BirthDay != NULL) {
                intBirthDay = objRequest.BirthDay;
                strSOQL += ' AND DAY_IN_MONTH(BirthDate) = :intBirthDay ';
            }
            
            if(objRequest.AdFiProfileId != NULL) {
                intAdFiProfileId = objRequest.AdFiProfileId;
                strSOQL += ' AND ADFi_Profile_ID__c= :intAdFiProfileId ';
            }
            
            strSOQL += 'LIMIT 6';
            
            System.debug('retrieveCuits [ strSOQL : ' + strSOQL + ' ]');
            
            lstContacts = Database.query(strSOQL);
            
            if(!lstContacts.isEmpty()) {
                for(Contact objContact : lstContacts) {
                    lstCitizensFound.add(new RemotingMessageHelper.CitizenFound(objContact));
                }
            }
        }
        System.debug('retrieveCuits [ ' + lstCitizensFound + ' ] <- ');
        
        return lstCitizensFound;
    }
}