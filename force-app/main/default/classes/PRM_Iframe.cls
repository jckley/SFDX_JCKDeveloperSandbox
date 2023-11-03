public with sharing class PRM_Iframe {
    @AuraEnabled
    public static String retrieveIframeUrl() {
        String strIframeUrl = null;
        Map<String, Cuidarnos__mdt> mapCuidarnos = null;
        List<GroupMember> lstUserGroup = null;
        Cuidarnos__mdt objSettings = null;

        System.debug('retrieveIframeUrl [] ->');
        
        mapCuidarnos = retrieveCuidarnosSetting();
        lstUserGroup = retrieveGroups();
        
        if(! lstUserGroup.IsEmpty()) {
            for(GroupMember objGroupMember : lstUserGroup) {
                if(objGroupMember.Group != NULL && mapCuidarnos.containsKey(objGroupMember.Group.DeveloperName)) {
                    objSettings = mapCuidarnos.get(objGroupMember.Group.DeveloperName);
                    strIframeUrl = objSettings.Iframe_Url__c;

                    break;
                }
            }
        }

        System.debug('retrieveIframeUrl [' + strIframeUrl + '] <-');
        return strIframeUrl;
    }

    private static List<GroupMember> retrieveGroups(){ 
        List<GroupMember> lstUserGroup = null;

        System.debug('retrieveGroups [] ->');

        lstUserGroup = [SELECT Id, Group.DeveloperName, UserOrGroupId, SystemModstamp 
                        FROM GroupMember 
                        WHERE  UserOrGroupId = :UserInfo.getUserId()];


        System.debug('retrieveGroups [' + lstUserGroup + '] <-');
        return lstUserGroup;
    }

    private static Map<String, Cuidarnos__mdt> retrieveCuidarnosSetting(){
        Map<String, Cuidarnos__mdt> mapCuidarnos = null;
        List<Cuidarnos__mdt> lstCuidarnos = null;

        System.debug('retrieveCuidarnosSetting [] ->');

        mapCuidarnos = new Map<String, Cuidarnos__mdt>(); 
        lstCuidarnos = [SELECT DashboardId__c,Iframe_Url__c,DeveloperName
                        FROM Cuidarnos__mdt 
                        LIMIT 100];

        if(!lstCuidarnos.isEmpty()) {
            for(Cuidarnos__mdt objCuidarnos : lstCuidarnos) {
                mapCuidarnos.put(objCuidarnos.DeveloperName, objCuidarnos);
            }
        }

        System.debug('retrieveCuidarnosSetting [' + mapCuidarnos + '] <-');

        return mapCuidarnos;
    }
}