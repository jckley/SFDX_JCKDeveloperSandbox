global with sharing class TypeformRefreshToken_Schedulable implements Schedulable {
    global void execute(SchedulableContext objSchedulableContext) { 
        TypeformAPI.refreshToken();
    }
}