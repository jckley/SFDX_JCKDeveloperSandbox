public without sharing class ChangeCountryController {
    public class CountryWrapper {
        @AuraEnabled
        public String country {get;set;}
        
        @AuraEnabled
        public Boolean isSelected {get;set;}

        @AuraEnabled
        public String public_group {get;set;}

        @AuraEnabled
        public String flag {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<CountryWrapper> retrieveCountries(){
        List<Country_Configuration__mdt> lstCountryConfiguration = null;
        Set<String> setGroupName = null;
        Map<String, GroupMember> mapUserGroupMember = null;
        List<CountryWrapper> lstCountryWrapper = null;
        CountryWrapper objCountryWrapper = null;
        
        System.debug(LoggingLevel.INFO, 'retrieveCountries [] ->');

        lstCountryConfiguration = Country_Configuration__mdt.getAll().values();
        lstCountryWrapper = new List<CountryWrapper>();

        if(!lstCountryConfiguration.IsEmpty()) {
            setGroupName = retrieveAvailableCountries(lstCountryConfiguration);
            mapUserGroupMember = retrieveUserGroups(setGroupName);  
            
            for(Country_Configuration__mdt objCountry : lstCountryConfiguration) {
                if(setGroupName.contains(objCountry.Public_Group__c)) {
                    objCountryWrapper = new CountryWrapper();
                    objCountryWrapper.country = objCountry.MasterLabel;
                    objCountryWrapper.flag = objCountry.Flag__c;
                    objCountryWrapper.public_group = objCountry.Public_Group__c;                    
                    objCountryWrapper.isSelected = mapUserGroupMember.containsKey(objCountry.Public_Group__c);

                    lstCountryWrapper.add(objCountryWrapper);
                }
            }
        }

        System.debug(LoggingLevel.INFO, 'retrieveCountries [' + lstCountryWrapper + '] <-');

        return lstCountryWrapper;
    }

    @AuraEnabled
    public static String changeCountryInSF(String strGroupName) {
        List<Country_Configuration__mdt> lstCountryConfiguration = null;
        Set<String> setGroupName = null;
        List<GroupMember> lstGroupMember = null;
        GroupMember objGroupMember = null;
        List<Group> lstGroup = null;

        System.debug(LoggingLevel.INFO, 'changeCountryInSF [strGroupName : ' + strGroupName + '] ->');

        lstCountryConfiguration = Country_Configuration__mdt.getAll().values();

        System.debug(LoggingLevel.INFO, 'changeCountryInSF [lstCountryConfiguration : ' + lstCountryConfiguration + '] ->');

        if(!lstCountryConfiguration.IsEmpty()) {
            setGroupName = retrieveAvailableCountries(lstCountryConfiguration);
            System.debug(LoggingLevel.INFO, 'changeCountryInSF [setGroupName : ' + setGroupName + '] ->');

            lstGroupMember = [SELECT Id FROM GroupMember WHERE UserOrGroupId =: UserInfo.getUserId() AND Group.DeveloperName IN : setGroupName AND Group.Type = 'Regular'];
            delete lstGroupMember;

            lstGroup = [SELECT Id FROM Group WHERE DeveloperName =: strGroupName AND Type = 'Regular'];
            System.debug(LoggingLevel.INFO, 'changeCountryInSF [lstGroup : ' + lstGroup + '] ->');

            if(!lstGroup.IsEmpty()) {
                objGroupMember = new GroupMember();
                objGroupMember.UserOrGroupId = UserInfo.getUserId();
                objGroupMember.GroupId = lstGroup[0].Id;
    
                insert objGroupMember;
            } else {
                throw new AuraHandledException('Pais no configurado correctamente!');
            }
        }

        System.debug(LoggingLevel.INFO, 'retrieveCountries [' + strGroupName + '] <-');

        return strGroupName;
    }

    private static Map<String,GroupMember> retrieveUserGroups(Set<String> setGroupName) {
        Map<String, GroupMember> mapUserGroupMember = null;
        List<GroupMember> lstGroupMember = null;

        System.debug(LoggingLevel.INFO, 'retrieveUserGroups [setGroupName : ' + setGroupName + '] ->');

        mapUserGroupMember = new Map<String, GroupMember>();
        if(!setGroupName.IsEmpty()) {
            lstGroupMember = [  SELECT Id, Group.DeveloperName, UserOrGroupId, SystemModstamp 
                                FROM GroupMember 
                                WHERE Group.DeveloperName IN :setGroupName
                                AND UserOrGroupId =: UserInfo.getUserId()];
            for(GroupMember objGroupMember : lstGroupMember) {
                mapUserGroupMember.put(objGroupMember.Group.DeveloperName, objGroupMember);
            }
        }

        System.debug(LoggingLevel.INFO, 'retrieveUserGroups [' + mapUserGroupMember + '] <-');
        return mapUserGroupMember;        
    }

    public static Set<String> retrieveAvailableCountries(List<Country_Configuration__mdt> lstCountryConfiguration) {
        Set<String> setGroupName = null;

        System.debug(LoggingLevel.INFO, 'retrieveAvailableCountries [lstCountryConfiguration : ' + lstCountryConfiguration + '] ->');

        setGroupName = new Set<String>();     

        if(lstCountryConfiguration != null && !lstCountryConfiguration.IsEmpty()) {
            for(Country_Configuration__mdt objCountryConfiguration : lstCountryConfiguration) {
                if(objCountryConfiguration.Active__c) {
                    setGroupName.add(objCountryConfiguration.Public_Group__c);
                }
            }
        }

        System.debug(LoggingLevel.INFO, 'retrieveAvailableCountries [' + setGroupName + '] <-');

        return setGroupName;
    }
}