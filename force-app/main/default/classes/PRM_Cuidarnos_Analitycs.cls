public with sharing class PRM_Cuidarnos_Analitycs {
    @AuraEnabled
    public static Id retrieveDashboardId(String strDashboardType) {
        Id strDashboardId = null;
        Map<String, Cuidarnos__mdt> mapCuidarnos = null;
        List<GroupMember> lstUserGroup = null;
        Cuidarnos__mdt objSettings = null;

        System.debug('retrieveDashboardId [] ->');
        
        mapCuidarnos = retrieveCuidarnosSetting();
        lstUserGroup = retrieveGroups();
        
        if(! lstUserGroup.IsEmpty()) {
            for(GroupMember objGroupMember : lstUserGroup) {
                if(objGroupMember.Group != NULL && mapCuidarnos.containsKey(objGroupMember.Group.DeveloperName)) {
                    objSettings = mapCuidarnos.get(objGroupMember.Group.DeveloperName);
                    
                    switch on strDashboardType {
                        when 'Territorial' {
                            strDashboardId = objSettings.Dashboard_Territorial__c;                            
                        }
                        when 'Sintomas' {
                            strDashboardId = objSettings.Dashboard_Sintomas__c;                            
                        }
                        when 'Sanitario' {
                            strDashboardId = objSettings.DashboardId__c;                            
                        }
                    }

                    break;
                }
            }
        }

        System.debug('retrieveDashboardId [' + strDashboardId + '] <-');
        return strDashboardId;
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
        lstCuidarnos = [SELECT DashboardId__c,Iframe_Url__c,DeveloperName, Dashboard_Territorial__c , Dashboard_Sintomas__c
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