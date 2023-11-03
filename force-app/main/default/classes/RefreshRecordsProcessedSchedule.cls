global class RefreshRecordsProcessedSchedule  implements Schedulable {
   global void execute(SchedulableContext objSchedulableContext) {
       DateTime objToday = null;
       Set<Id> setUserPermission = null;       
       Set<Id> setProfilePermission = null;
       Map<Id, Permission_Type__c> mapPermissionType = null;
       List<Permission_Type__c> lstPermissionType = null;
       List<User> lstUsersWithPermissions = null;       
       List<User> lstUsersProfileWithPermissions = null;
       System.debug('SchedulableContext [objSchedulableContext : ' + objSchedulableContext + '] ->');
       
       if(!Test.isRunningTest()) {
           objToday = DateTime.now();           
       } else {
           objToday = DateTime.newInstance(2017, 1, 1);
       }
       
       lstPermissionType = [SELECT Profile_Id__c, UserId__c, Time__c, Records__c 
                            FROM Permission_Type__c 
                            WHERE (Profile_Id__c != NULL OR UserId__c != NULL) 
                            AND Time__c != NULL 
                            AND Records__c != NULL];
       
       if(!lstPermissionType.isEmpty()) {
           mapPermissionType = new Map<Id, Permission_Type__c>();
           setUserPermission = new Set<Id>();       
           setProfilePermission = new Set<Id>();
           
           for(Permission_Type__c objPermisionType : lstPermissionType) {
               if(objPermisionType.UserId__c != NULL) {
                   setUserPermission.add(objPermisionType.UserId__c);
                   mapPermissionType.put(objPermisionType.UserId__c, objPermisionType);
               } else if(objPermisionType.Profile_Id__c != NULL) {
                   setProfilePermission.add(objPermisionType.Profile_Id__c);
                   mapPermissionType.put(objPermisionType.Profile_Id__c, objPermisionType);
               }
           }
           
           lstUsersWithPermissions = [SELECT Records_Processed__c  
                                      FROM User 
                                      WHERE Id IN :setUserPermission];       
           lstUsersProfileWithPermissions = [SELECT Records_Processed__c  
                                             FROM User 
                                             WHERE Id NOT IN :setUserPermission 
                                             AND ProfileId IN :setProfilePermission];       

           if(objToday.day() == 1) {
               refreshMonthlyValues(mapPermissionType, lstUsersWithPermissions, lstUsersProfileWithPermissions);
           }
           
           if(objToday.format('EEEE') == 'Sunday') {
               refreshWeekyValues(mapPermissionType, lstUsersWithPermissions, lstUsersProfileWithPermissions);
           }
           
           refreshDailyValues(mapPermissionType, lstUsersWithPermissions, lstUsersProfileWithPermissions);
       } else {
           System.debug('SchedulableContext [No records to process]');
       }
              
       System.debug('SchedulableContext [objSchedulableContext : ' + objSchedulableContext + '] <-');
   }
    
    private void refreshMonthlyValues(Map<Id, Permission_Type__c> mapPermissionType, List<User> lstUsersWithPermissions, List<User> lstUsersProfileWithPermissions) {
        for(User objUser : lstUsersWithPermissions) {
            if(mapPermissionType.containsKey(objUser.Id) && mapPermissionType.get(objUser.Id).Time__c == 'Mensual') {
                objUser.Records_Processed__c = 0;
            }
        }
        
        for(User objUser : lstUsersProfileWithPermissions) {
            if(mapPermissionType.containsKey(objUser.Id) && mapPermissionType.get(objUser.Id).Time__c == 'Mensual') {
                objUser.Records_Processed__c = 0;
            }
        }
        
        update lstUsersWithPermissions;
        update lstUsersProfileWithPermissions;
    }
    
    private void refreshWeekyValues(Map<Id, Permission_Type__c> mapPermissionType, List<User> lstUsersWithPermissions, List<User> lstUsersProfileWithPermissions) {
        for(User objUser : lstUsersWithPermissions) {
            if(mapPermissionType.containsKey(objUser.Id) && mapPermissionType.get(objUser.Id).Time__c == 'Semanal') {
                objUser.Records_Processed__c = 0;
            }
        }
        
        for(User objUser : lstUsersProfileWithPermissions) {
            if(mapPermissionType.containsKey(objUser.Id) && mapPermissionType.get(objUser.Id).Time__c == 'Semanal') {
                objUser.Records_Processed__c = 0;
            }
        }
        
        update lstUsersWithPermissions;
        update lstUsersProfileWithPermissions;
    }
    
    private void refreshDailyValues(Map<Id, Permission_Type__c> mapPermissionType, List<User> lstUsersWithPermissions, List<User> lstUsersProfileWithPermissions) {
        for(User objUser : lstUsersWithPermissions) {
            if(mapPermissionType.containsKey(objUser.Id) && mapPermissionType.get(objUser.Id).Time__c == 'Diario') {
                objUser.Records_Processed__c = 0;
            }
        }
        
        for(User objUser : lstUsersProfileWithPermissions) {
            if(mapPermissionType.containsKey(objUser.Id) && mapPermissionType.get(objUser.Id).Time__c == 'Diario') {
                objUser.Records_Processed__c = 0;
            }
        }
        
        update lstUsersWithPermissions;
        update lstUsersProfileWithPermissions;
    }
}