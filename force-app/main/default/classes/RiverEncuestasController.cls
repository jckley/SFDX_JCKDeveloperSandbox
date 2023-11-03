public class RiverEncuestasController {
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getGroupedEncuestas () {
        return [SELECT COUNT(Id) totalEncuestas, River_Name__c
                FROM RiverId_Polls__c
                GROUP BY River_Name__c];
    }
}