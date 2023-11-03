global class IncrementReport implements Schedulable {
   global void execute(SchedulableContext ctx) {
      System.debug('Entered Cron trigger');
      rptobj__c r = [SELECT Id, Name, reporttrigger__c FROM rptobj__c WHERE Name = 'ThisReport' LIMIT 1];
      r.reporttrigger__c += 1;
      System.debug('updating trigger to: ' + r.reporttrigger__c);
      update r;
      }   
}