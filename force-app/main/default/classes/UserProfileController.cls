public with sharing class UserProfileController {

    @AuraEnabled(cacheable=true)
    public static List<User> retrieveUsers() {
        return [SELECT Id, Name, IsActive, ProfileId, Profile.Name, UserRoleId FROM User]; 
    }

    @AuraEnabled(cacheable=true)
    public static List<Profile> retrieveProfiles() {
        return [SELECT Id, Name FROM Profile]; 
    }
    
}