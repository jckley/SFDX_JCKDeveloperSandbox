public without sharing class Prosumer_AudienciaPageController {
  @AuraEnabled
  public static Map<String, String> getProsumerAudienceCriterias() {

    Account acc = [SELECT Sharing_Criteria__c, Prosumer_Sharing_Id__c, SAQL_Sharing_Criteria__c FROM account WHERE id = :getAccountFromUser()];
    Map<String, String> returnValues = new Map<String, String>();
    returnValues.put('criteria', acc.Sharing_Criteria__c);
    returnValues.put('sharingId', acc.Prosumer_Sharing_Id__c);
    returnValues.put('SAQL', acc.SAQL_Sharing_Criteria__c);
    
    return returnValues;
  }
  
  @AuraEnabled
  public static Map<String, Decimal> getUserCreditInformation() {
    Account acc = [SELECT Creditos_Email__c, Creditos_IVR__c, Creditos_SMS__c, Cantidad_Creditos__c FROM account WHERE id = :getAccountFromUser()];
    Map<String, Decimal> userFromAccountValues = new Map<String, Decimal>();
    userFromAccountValues.put('sms_cost', acc.Creditos_SMS__c);
    userFromAccountValues.put('ivr_cost', acc.Creditos_IVR__c);
    userFromAccountValues.put('email_cost', acc.Creditos_Email__c);
    userFromAccountValues.put('accountCredits', acc.Cantidad_Creditos__c);
    
    return userFromAccountValues;
  }

  @AuraEnabled
  public static Id getAccountFromUser () {
    Id userId = UserInfo.getUserId();
    User user = [SELECT accountId, profileId FROM user WHERE id = :userId];
    if (user.accountId == null) {
      List<Account> accs = [SELECT id FROM account WHERE name = 'PROSUMER ADMINS DEFAULT ACCOUNT'];
      if(accs.size()!= 0){
        return accs[0].id;
      }
      Account acc = new Account();
      acc.name = 'PROSUMER ADMINS DEFAULT ACCOUNT';
      insert acc;
      return acc.id;
    }
    return user.accountId;
  }

  /*
  public static void doAnalyticsQuery(String query) {
    String queryTEst =
      'q = load "0FbDa000000GGyWKAW/0FcDa0000017YnVKAU";' +
      'q = filter q by (Level1Name__c == "Buenos Aires" || Level1Name__c == "Mendoza");' +
      'q = filter q by MobilePhone is not null;' +
      'q = group q by all;' +
      'q = foreach q generate count(q) as \'count\';' +
      'q = limit q 2000;';

    System.debug(WaveApiService.makeQuery(queryTEst));
  }
  */
}