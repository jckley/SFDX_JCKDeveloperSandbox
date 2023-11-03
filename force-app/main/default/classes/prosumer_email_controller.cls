public class prosumer_email_controller {
  @AuraEnabled
  public static Prosumer_Email__c getEmailRecord(Id emailid) {
      return [SELECT id, name, Email_JSON__c, HTML__c 
                FROM Prosumer_Email__c 
                WHERE id = :emailid];
  }

  @AuraEnabled
  public static List<Prosumer_Email__c> getEmailList() {
    return [SELECT id, name, Email_JSON__c, HTML__c FROM Prosumer_Email__c WHERE account__c =: Prosumer_AudienciaPageController.getAccountFromUser() ORDER BY LastModifiedDate DESC];
  }

  @AuraEnabled
  public static Prosumer_Email__c updateEmailRecord(Id emailid, String htmlString, String jsonObject) {
    Prosumer_Email__c emailRecord = new Prosumer_Email__c ();
    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonObject);
    emailRecord.name = (String) jsonMap.get('nombreDelMail');
    emailRecord.Email_JSON__c = jsonObject;
    emailRecord.id = emailid;
    emailRecord.html__c = htmlString;
    update emailRecord;
    return emailRecord;
  }

  @AuraEnabled
  public static Id createEmailRecord(String htmlString, String jsonObject) {
    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonObject);
    Prosumer_Email__c emailRecord = new Prosumer_Email__c ();
    emailRecord.name = (String) jsonMap.get('nombreDelMail');
    emailRecord.Email_JSON__c = jsonObject;
    emailRecord.account__c = Prosumer_AudienciaPageController.getAccountFromUser();
    emailRecord.html__c = htmlString;

    insert emailRecord;
    
    return emailRecord.id;
  } 
}