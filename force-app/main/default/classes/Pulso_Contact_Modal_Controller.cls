public class Pulso_Contact_Modal_Controller {
    @RemoteAction
    public static List<RemotingMessageHelper.Territory> retrieveTerritories(Integer intLevel, String strParentId) {
        List<RemotingMessageHelper.Territory> lstTerritories = null;
        List<Territorio_Administrativo__c> lstTerritoriesC = null;
         
        System.debug('retrieveTerritories [intLevel : ' + intLevel + ' - strParentId : ' + strParentId + '] ->');

        if(String.isNotBlank(strParentId)) {
            lstTerritoriesC = [SELECT Id, Name, Nivel_Administrativo__c 
                              FROM Territorio_Administrativo__c 
                              WHERE Nivel_Administrativo__c =: intLevel 
                              AND ParentId__c =: strParentId];
        } else {
            lstTerritoriesC = [SELECT Id, Name, Nivel_Administrativo__c 
                              FROM Territorio_Administrativo__c 
                              WHERE Nivel_Administrativo__c =: intLevel];
        }
        
        lstTerritories = new List<RemotingMessageHelper.Territory>();
        for(Territorio_Administrativo__c objTerritoryC : lstTerritoriesC) {
            lstTerritories.add(new RemotingMessageHelper.Territory(objTerritoryC));
        }
        
        System.debug('retrieveTerritories [' + lstTerritories + '] <-');

        return lstTerritories;
    }
    
    @RemoteAction
    public static void saveContact(String strJSON) {
        RemotingMessageHelper.PulsoContact objPulsoContact = null;
        Lead objLead = null;
        
        try {
            if(String.isNotBlank(strJSON)) {
                objPulsoContact = (RemotingMessageHelper.PulsoContact)JSON.deserialize(strJSON, RemotingMessageHelper.PulsoContact.class);
                objLead = objPulsoContact.toLead();
                
                upsert objLead Email;
            }            
        } catch(Exception Ex) {
            HelperFunctions.handleRuntimeException(Ex);
        }
    }
}