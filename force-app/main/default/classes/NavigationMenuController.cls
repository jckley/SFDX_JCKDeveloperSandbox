public class NavigationMenuController {  
    @AuraEnabled
    public static List<NavigationMenuItem> getNavigationMenuItems(){
        String strNetworkId = Network.getNetworkId();
        String strProfile = null;
        List<NavigationMenuItem> lstNavigationItems = null;
        String strIframeUrl = null;
        Map<String, Cuidarnos__mdt> mapCuidarnos = null;
        List<GroupMember> lstUserGroup = null;
        Cuidarnos__mdt objSettings = null;
        Set<String> setMenuItems = null;

        System.debug('getNavigationMenuItems [' + strNetworkId + '] ->');
        
        mapCuidarnos = retrieveCuidarnosSetting();
        lstUserGroup = retrieveGroups();
        strNetworkId = Network.getNetworkId();
        lstNavigationItems = new List<NavigationMenuItem>();
        setMenuItems = new Set<String>();
        
        if(! lstUserGroup.IsEmpty()) {
            for(GroupMember objGroupMember : lstUserGroup) {
                if(objGroupMember.Group != NULL && mapCuidarnos.containsKey(objGroupMember.Group.DeveloperName)) {
                    objSettings = mapCuidarnos.get(objGroupMember.Group.DeveloperName);
                    break;
                }
            }
        }

        System.debug('getNavigationMenuItems [objSettings : ' + objSettings + ']');

        if(objSettings != NULL) {
            if(objSettings.DeveloperName == 'Cuidarnos_Test_Group' || objSettings.DeveloperName == 'Cuidarnos_Pilar') {
                setMenuItems = retrieveCuidarnosPilarMenu();

                System.debug('getNavigationMenuItems [setMenuItems : ' + setMenuItems + ']');
            }

            if(!setMenuItems.isEmpty()) {
                lstNavigationItems = [ SELECT Id, Label, Type, Target, Position, Status 
                                        FROM NavigationMenuItem 
                                        WHERE Status = 'Live' 
                                        //AND Type = 'SalesforceObject' 
                                        AND NavigationLinkSet.NetworkId = :strNetworkId
                                        AND Target IN :setMenuItems
                                        ORDER BY Position];
            }
        }

        System.debug('lstNavigationItems : ' + lstNavigationItems );
        return lstNavigationItems;
    }  

    private static Set<String> retrieveCuidarnosPilarMenu() {
        Set<String> setMenuItems = null;

        System.debug('retrieveCuidarnosPilarMenu[] ->');
        setMenuItems = new Set<String>();

        setMenuItems.add('/');
        setMenuItems.add('/listadoasintomaticos');
        setMenuItems.add('/listadosintomaticos');
        setMenuItems.add('/listadosospechosos');
        setMenuItems.add('/listadomuestras');
        setMenuItems.add('/listadoresultados');
        setMenuItems.add('/listadonotificaciones');
        setMenuItems.add('/listadoseguimiento');
        setMenuItems.add('/listadoarchivados');

        System.debug('retrieveCuidarnosPilarMenu[' + setMenuItems + '] <-');

        return setMenuItems;
    }
    /* v1.1
    @AuraEnabled
    public static List<NavigationMenuItem> getNavigationMenuItems(){
        String strNetworkId = Network.getNetworkId();
        String strProfile = null;
        List<NavigationMenuItem> lstNavigationItems = null;
        String strIframeUrl = null;
        Map<String, Cuidarnos__mdt> mapCuidarnos = null;
        List<GroupMember> lstUserGroup = null;
        Cuidarnos__mdt objSettings = null;
        Set<String> setMenuItems = null;

        System.debug('getNavigationMenuItems [' + strNetworkId + '] ->');
        
        mapCuidarnos = retrieveCuidarnosSetting();
        lstUserGroup = retrieveGroups();
        strNetworkId = Network.getNetworkId();
        lstNavigationItems = new List<NavigationMenuItem>();

        if(! lstUserGroup.IsEmpty()) {
            for(GroupMember objGroupMember : lstUserGroup) {
                if(objGroupMember.Group != NULL && mapCuidarnos.containsKey(objGroupMember.Group.DeveloperName)) {
                    objSettings = mapCuidarnos.get(objGroupMember.Group.DeveloperName);
                    break;
                }
            }
        }

        System.debug('getNavigationMenuItems [objSettings : ' + objSettings + ']');

        if(objSettings != NULL && (String.isNotBlank(objSettings.DashboardId__c) || String.isNotBlank(objSettings.Iframe_Url__c))) {
            setMenuItems = new Set<String>();
            if(String.isNotBlank(objSettings.Dashboard_Territorial__c)) {
                setMenuItems.add('/territorial');
            }

            if(String.isNotBlank(objSettings.Dashboard_Sintomas__c)) {
                setMenuItems.add('/sintomas');
            }

            if(String.isNotBlank(objSettings.DashboardId__c)) {
                setMenuItems.add('/dashboard');
            }

            if(String.isNotBlank(objSettings.Iframe_Url__c)) {
                setMenuItems.add('/mapa');
            }

            setMenuItems.add('/');

            System.debug('getNavigationMenuItems [setMenuItems : ' + setMenuItems + ']');

            lstNavigationItems = [ SELECT Id, Label, Type, Target, Position, Status 
                                    FROM NavigationMenuItem 
                                    WHERE Status = 'Live' 
                                    //AND Type = 'SalesforceObject' 
                                    AND NavigationLinkSet.NetworkId = :strNetworkId
                                    AND Target IN :setMenuItems
                                    ORDER BY Position];
        }

        System.debug('lstNavigationItems : ' + lstNavigationItems );
        return lstNavigationItems;
    }  
    */
    /*
    @AuraEnabled v1.0
    public static List<NavigationMenuItem> getNavigationMenuItems(){
        String strNetworkId = Network.getNetworkId();
        String strProfile = null;

        System.debug('strNetworkId : ' + strNetworkId );
        
        List<NavigationMenuItem> navigationItems = new List<NavigationMenuItem>();


        if( [SELECT Id, Group.Name, UserOrGroupId, SystemModstamp 
            FROM GroupMember 
            WHERE  UserOrGroupId = :UserInfo.getUserId()
            AND (
                Group.DeveloperName = 'Cuidarnos_Cordoba'
                OR Group.DeveloperName = 'Cuidarnos_Pilar'
                OR Group.DeveloperName = 'Cuidarnos_San_Antonio_de_Areco' 
            ) 
            LIMIT 10].size() > 0 ) {
            
                navigationItems = [SELECT Id, Label, Type, Target, Position, Status 
                            FROM NavigationMenuItem 
                            WHERE Status = 'Live' 
                            //AND Type = 'SalesforceObject' 
                            AND NavigationLinkSet.NetworkId = :strNetworkId
                            ORDER BY Position];
            }
        System.debug('navigationItems : ' + navigationItems );
        return navigationItems;
    }   */

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