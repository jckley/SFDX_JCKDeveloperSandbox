public class TerritoryDetailController {
	
    @AuraEnabled(Cacheable=True)
    public static RemotingMessageHelper.TerritoryInfo retrieveTerritory(String strTerritoryId, String strCommunity) {
        List<Territorio_Administrativo__c> lstTerritory = null;
        List<Territorio_Administrativo__c> lstChildTerritories = null;
        RemotingMessageHelper.TerritoryInfo objTerritory = null;

        System.debug('retrieveTerritory [strTerritoryId : ' + strTerritoryId + '] ->');
        
        if(String.isNotBlank(strTerritoryId)) {
            lstTerritory = [SELECT 	Id, 
                                    Name, 
                                    Geocode__c,
                            		ParentId__r.Name, 
                            		ParentId__c,
                            		Total_Economic_Activities__c, 
                            		Nivel_Administrativo__c, 
                            		Total_Ciudadanos__c, 
                            		Total_Number_of_Males__c, 
                            		Total_Number_of_Females__c,    
                            		Etario_Sub_16_Total__c,
                            		Etario_Centennials_Total__c,
                            		Etario_Millennials_Total__c,
                            		Etario_Generacion_X_Total__c,
                            		Etario_Baby_Boomers_Total__c,
                            		Etario_Generacion_Silenciosa_Total__c,
                            		Total_Education_Level_Primary__c,
                            		Total_Education_Level_Secondary__c,
                            		Total_Education_Level_Tertiary__c,
                            		Total_Education_Level_University_Degree__c,
                            		Total_Occupation_Type_Self_Employed__c,
                            		Total_Occupation_Type_Wage_Earned__c,
                            		Total_Occupation_Type_Retired__c,
                            		Total_Occupation_Type_Not_Declared__c,
                            		Total_Income_Range_Very_High__c,
                            		Total_Income_Range_High__c,
                            		Total_Income_Range_Medium__c,
                            		Total_Income_Range_Low__c,
                            		Total_Income_Range_Very_Low__c,
                                    RiverId_Total_Ciudadanos__c,
                                    RiverId_Total_Number_of_Males__c, 
                                    RiverId_Total_Number_of_Females__c,
                                    RiverId_Total_Edu_Primary__c,
                                    RiverId_Total_Edu_Secondary__c,
                                    RiverId_Total_Edu_Tertiary__c,
                                    RiverId_Total_Edu_University__c,
                                    RiverId_TotInc_Very_Low__c,
                                    RiverId_TotInc_Low__c,
                                    RiverId_TotInc_Medium__c,
                                    RiverId_TotInc_High__c,
                                    RiverId_TotInc_Very_High__c,
                                    RiverId_TotOccu_Wage__c,
                                    RiverId_TotOccu_Self_Employed__c,
                                    RiverId_TotOccu_Retired__c,
                                    RiverId_TotOccu_Not_Declared__c,
                                    RiverId_TotEco_Activities__c
                            FROM Territorio_Administrativo__c
                            WHERE Id =: strTerritoryId];    
            
            System.debug('retrieveTerritory [lstTerritory : ' + lstTerritory + ']');
            if(!lstTerritory.IsEmpty()) {
                lstChildTerritories = [SELECT Id, Name, Total_Ciudadanos__c, 
                                                    RiverId_Total_Ciudadanos__c                                  
                                       FROM Territorio_Administrativo__c
                                       WHERE ParentId__c =: strTerritoryId]; 
                
                objTerritory = new RemotingMessageHelper.TerritoryInfo(lstTerritory[0], strCommunity);
                System.debug('retrieveTerritory [objTerritory : ' + objTerritory + ']');
                
                if( String.isNotBlank(URL.getSalesforceBaseUrl().toExternalForm()) && String.isNotBlank(Site.getPathPrefix()) ) {
                    objTerritory.parentlink = String.format('{0}{1}{2}', new String[] { URL.getSalesforceBaseUrl().toExternalForm(),Site.getPathPrefix().substring(0, Site.getPathPrefix().length() -1 ), objTerritory.parentId });
                } else {
                    objTerritory.parentlink = String.format('/{0}', new String[] {objTerritory.parentId });                    
                }

                System.debug('objTerritory.parentlink : ' + objTerritory.parentlink);

                if(!lstChildTerritories.isEmpty()) {
                    objTerritory.loadGeographicDistribution(lstChildTerritories);
                }
            }

            if(UserInfo.getUserRoleId() == [SELECT Id FROM UserRole WHERE Name = 'Ecuador'].Id) {
                objTerritory.educationLevels.clear();
                objTerritory.incomeranges.clear();
                objTerritory.occupationTypes.clear();
                objTerritory.economicactivities.clear(); 
            }
        }
        
        System.debug('retrieveTerritory [' + objTerritory + '] <-');
        return objTerritory;
    }



    public Territorio_Administrativo__c territory {get; set;}
    public String terrId {get; set;}
    public TerritoryWrapper2 terrWrap {get; set;}
    
    public TerritoryDetailController(){
        
        terrId = apexpages.currentpage().getparameters().get('id');

        //Terrirory Main information
        Set<String> territoryInfo = new Set<String>{'Nivel_Administrativo__c', 'Level0Name__c', 'Level1Name__c', 'Level2Name__c', 'Level3Name__c', 'Level4Name__c',
            'ParentId__c','ParentId__r.Name',
            'ParentId__r.ParentId__c','ParentId__r.ParentId__r.Name',
            'ParentId__r.ParentId__r.ParentId__c','ParentId__r.ParentId__r.ParentId__r.Name',
            'ParentId__r.ParentId__r.ParentId__r.ParentId__c','ParentId__r.ParentId__r.ParentId__r.ParentId__r.Name'};

        //Total Contact information
        Set<String> contactInfo = new Set<String>{'Total_Ciudadanos__c', 'Total_Emails__c', 'Total_Moviles__c', 'Total_Telefonos_FIjos__c'};

        //Total Social information 
        Set<String> socialInfo = new Set<String>{'Total_Facebook__c', 'Total_Instagram__c', 'Total_Linkedin__c', 'Total_Twitter__c', 'Social_Profiles__c'};

        //Total Social information 
        Set<String> ageRangeInfo = new Set<String>{'Total_de_Hombres_de_0_a_15__c', 'Total_de_Hombres_de_16_a_17__c', 'Total_de_Hombres_de_18_a_24__c', 'Total_de_Hombres_de_25_a_39__c', 'Total_de_Hombres_de_40_a_64__c', 'Total_Hombres_de_65plus__c', 'Total_Mujeres_de_0_a_15__c', 'Total_Mujeres_de_16_a_17__c', 'Total_Mujeres_de_18_a_24__c', 'Total_Mujeres_de_25_a_39__c', 'Total_Mujeres_de_40_a_64__c', 'Total_Mujeres_de_65plus__c'};
		Set<String> ageRangeInfo2 = new Set<String>{'Etario_Baby_Boomers_Female__c','Etario_Baby_Boomers_Male__c','Etario_Baby_Boomers_Total__c','Etario_Centennials_Female__c','Etario_Centennials_Male__c','Etario_Centennials_Total__c','Etario_Generacion_Silenciosa_Female__c','Etario_Generacion_Silenciosa_Male__c','Etario_Generacion_Silenciosa_Total__c','Etario_Generacion_X_Female__c','Etario_Generacion_X_Male__c','Etario_Generacion_X_Total__c','Etario_Millennials_Female__c','Etario_Millennials_Male__c','Etario_Millennials_Total__c','Etario_Sub_16_Female__c','Etario_Sub_16_Male__c','Etario_Sub_16_Total__c'};

        Set<String> actividadesEconomicas2 = new Set<String>{'Total_Economic_Activities__c'};

        /* Query building block */

        List<String> fldnames = new List<String>();
        fldnames.addAll(territoryInfo);
        fldnames.addAll(contactInfo);
        fldnames.addAll(socialInfo);
        fldnames.addAll(ageRangeInfo);
        fldnames.addAll(ageRangeInfo2);
        fldnames.addAll(actividadesEconomicas2);
        
        String queryString = 'SELECT Id, Name, ';
        queryString +=   String.join(fldnames, ',');
        
        queryString += ' FROM Territorio_Administrativo__c WHERE Id =: terrId';
        territory = Database.query(queryString);
        
        /* Query building block */
        
        terrWrap = new TerritoryWrapper2(territory);
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        sessionPart.put('ComesFrom', 'URL');
        System.debug(sessionPart.get('ComesFrom'));
    }
    
    public TerritoryDetailController(ApexPages.StandardController stdController){
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        terrId = stdController.getId();
        String terrIdURL = apexpages.currentpage().getparameters().get('terrId');
        if(terrIdURL != NULL && terrId == NULL){
            sessionPart.put('ComesFrom', 'URL');
            terrId = terrIdURL;
        } else {
            sessionPart.put('ComesFrom', 'Standard');
        }
        if(String.isBlank(terrId)) {
            terrId = [SELECT ID FROM Territorio_Administrativo__c WHERE Name = 'Argentina' AND Nivel_Administrativo__c = 0 LIMIT 1].Id;
        }
        //Terrirory Main information
        Set<String> territoryInfo = new Set<String>{'Nivel_Administrativo__c', 'Level0Name__c', 'Level1Name__c', 'Level2Name__c', 'Level3Name__c', 'Level4Name__c',
            'ParentId__c','ParentId__r.Name',
            'ParentId__r.ParentId__c','ParentId__r.ParentId__r.Name',
            'ParentId__r.ParentId__r.ParentId__c','ParentId__r.ParentId__r.ParentId__r.Name',
            'ParentId__r.ParentId__r.ParentId__r.ParentId__c','ParentId__r.ParentId__r.ParentId__r.ParentId__r.Name'};

        //Total Contact information
        Set<String> contactInfo = new Set<String>{'Total_Ciudadanos__c', 'Total_Emails__c', 'Total_Moviles__c', 'Total_Telefonos_FIjos__c'};

        //Total Social information 
        Set<String> socialInfo = new Set<String>{'Total_Facebook__c', 'Total_Instagram__c', 'Total_Linkedin__c', 'Total_Twitter__c', 'Social_Profiles__c'};

        //Total Social information 
        Set<String> ageRangeInfo = new Set<String>{'Total_de_Hombres_de_0_a_15__c', 'Total_de_Hombres_de_16_a_17__c', 'Total_de_Hombres_de_18_a_24__c', 'Total_de_Hombres_de_25_a_39__c', 'Total_de_Hombres_de_40_a_64__c', 'Total_Hombres_de_65plus__c', 'Total_Mujeres_de_0_a_15__c', 'Total_Mujeres_de_16_a_17__c', 'Total_Mujeres_de_18_a_24__c', 'Total_Mujeres_de_25_a_39__c', 'Total_Mujeres_de_40_a_64__c', 'Total_Mujeres_de_65plus__c'};
        Set<String> ageRangeInfo2 = new Set<String>{'Etario_Baby_Boomers_Female__c','Etario_Baby_Boomers_Male__c','Etario_Baby_Boomers_Total__c','Etario_Centennials_Female__c','Etario_Centennials_Male__c','Etario_Centennials_Total__c','Etario_Generacion_Silenciosa_Female__c','Etario_Generacion_Silenciosa_Male__c','Etario_Generacion_Silenciosa_Total__c','Etario_Generacion_X_Female__c','Etario_Generacion_X_Male__c','Etario_Generacion_X_Total__c','Etario_Millennials_Female__c','Etario_Millennials_Male__c','Etario_Millennials_Total__c','Etario_Sub_16_Female__c','Etario_Sub_16_Male__c','Etario_Sub_16_Total__c'};

        Set<String> actividadesEconomicas2 = new Set<String>{'Total_Economic_Activities__c'};

        /* Query building block */
            
        List<String> fldnames = new List<String>();
        fldnames.addAll(territoryInfo);
        fldnames.addAll(contactInfo);
        fldnames.addAll(socialInfo);
        fldnames.addAll(ageRangeInfo);
        fldnames.addAll(ageRangeInfo2);
        fldnames.addAll(actividadesEconomicas2);
        
        String queryString = 'SELECT Id, Name, ';
        queryString +=   String.join(fldnames, ',');
        
        queryString += ' FROM Territorio_Administrativo__c WHERE Id =: terrId';
        territory = Database.query(queryString);
        
        /* Query building block */
        
        terrWrap = new TerritoryWrapper2(territory);
    }
    
    @AuraEnabled(Cacheable=True)
    public static TerritoryWrapper getTerritoryById(Id territoryId) {
        
        Territorio_Administrativo__c territory;
        TerritoryWrapper territoryWrapper = NULL;
        if(String.isNotBlank(territoryId)) {

        //Terrirory Main information
        Set<String> territoryInfo = new Set<String>{'Nivel_Administrativo__c', 'Level0Name__c', 'Level1Name__c', 'Level2Name__c', 'Level3Name__c', 'Level4Name__c',
            'ParentId__c','ParentId__r.Name',
            'ParentId__r.ParentId__c','ParentId__r.ParentId__r.Name',
            'ParentId__r.ParentId__r.ParentId__c','ParentId__r.ParentId__r.ParentId__r.Name',
            'ParentId__r.ParentId__r.ParentId__r.ParentId__c','ParentId__r.ParentId__r.ParentId__r.ParentId__r.Name'};

        //Total Contact information
        Set<String> contactInfo = new Set<String>{'Total_Ciudadanos__c', 'Total_Emails__c', 'Total_Moviles__c', 'Total_Telefonos_FIjos__c'};

        //Total Social information 
        Set<String> socialInfo = new Set<String>{'Total_Facebook__c', 'Total_Instagram__c', 'Total_Linkedin__c', 'Total_Twitter__c', 'Social_Profiles__c'};

        //Total Social information 
        Set<String> ageRangeInfo = new Set<String>{'Total_de_Hombres_de_0_a_15__c', 'Total_de_Hombres_de_16_a_17__c', 'Total_de_Hombres_de_18_a_24__c', 'Total_de_Hombres_de_25_a_39__c', 'Total_de_Hombres_de_40_a_64__c', 'Total_Hombres_de_65plus__c', 'Total_Mujeres_de_0_a_15__c', 'Total_Mujeres_de_16_a_17__c', 'Total_Mujeres_de_18_a_24__c', 'Total_Mujeres_de_25_a_39__c', 'Total_Mujeres_de_40_a_64__c', 'Total_Mujeres_de_65plus__c'};
            
		Set<String> ageRangeInfo2 = new Set<String>{'Etario_Baby_Boomers_Female__c','Etario_Baby_Boomers_Male__c','Etario_Baby_Boomers_Total__c','Etario_Centennials_Female__c','Etario_Centennials_Male__c','Etario_Centennials_Total__c','Etario_Generacion_Silenciosa_Female__c','Etario_Generacion_Silenciosa_Male__c','Etario_Generacion_Silenciosa_Total__c','Etario_Generacion_X_Female__c','Etario_Generacion_X_Male__c','Etario_Generacion_X_Total__c','Etario_Millennials_Female__c','Etario_Millennials_Male__c','Etario_Millennials_Total__c','Etario_Sub_16_Female__c','Etario_Sub_16_Male__c','Etario_Sub_16_Total__c'};
                           
        Set<String> actividadesEconomicas2 = new Set<String>{'Total_Economic_Activities__c'};

        Set<String> riverData = new Set<String>{
            'RiverId_Etario_Sub_16_Male__c','RiverId_Etario_Sub_16_Male__c','RiverId_Etario_Centennials_Male__c',
            'RiverId_Etario_Millennials_Male__c','RiverId_Etario_Generacion_X_Male__c','RiverId_Etario_Baby_Boomers_Male__c',
            'RiverId_Etario_Generacion_Silenciosa_M__c',        
            'RiverId_Etario_Sub_16_Female__c','RiverId_Etario_Centennials_Female__c','RiverId_Etario_Millennials_Female__c',
            'RiverId_Etario_Generacion_X_Female__c','RiverId_Etario_Baby_Boomers_Female__c','RiverId_Etario_Generacion_Silenciosa_F__c',
            'RiverId_Total_Ciudadanos__c'
        };

        List<String> fldnames = new List<String>();
		fldnames.addAll(territoryInfo);
		fldnames.addAll(contactInfo);
	    fldnames.addAll(socialInfo);
		fldnames.addAll(ageRangeInfo);
		fldnames.addAll(ageRangeInfo2);
        fldnames.addAll(actividadesEconomicas2);
        fldnames.addAll(riverData);

        String queryString = 'SELECT Id , Name, ';
        queryString += String.join(fldnames, ',');
        queryString += ' FROM Territorio_Administrativo__c WHERE Id =: territoryId';
        territory = Database.query(String.escapeSingleQuotes(queryString));

            territoryWrapper = new TerritoryWrapper(territory);
        }
        System.debug('territorio a mostrar: ' + territoryWrapper);
        return territoryWrapper;
    }
    
    @AuraEnabled
    public static TerritoryWrapper2 getTerritoryById2(Id territoryId) {        
        Territorio_Administrativo__c territory;
        TerritoryWrapper2 territoryWrapper = NULL;
        if(String.isNotBlank(territoryId)) {

        //Terrirory Main information
        Set<String> territoryInfo = new Set<String>{'Nivel_Administrativo__c', 'Level0Name__c', 'Level1Name__c', 'Level2Name__c', 'Level3Name__c', 'Level4Name__c',
            'ParentId__c','ParentId__r.Name',
            'ParentId__r.ParentId__c','ParentId__r.ParentId__r.Name',
            'ParentId__r.ParentId__r.ParentId__c','ParentId__r.ParentId__r.ParentId__r.Name',
            'ParentId__r.ParentId__r.ParentId__r.ParentId__c','ParentId__r.ParentId__r.ParentId__r.ParentId__r.Name'};

        //Total Contact information
        Set<String> contactInfo = new Set<String>{'Total_Ciudadanos__c', 'Total_Emails__c', 'Total_Moviles__c', 'Total_Telefonos_FIjos__c'};

        //Total Social information 
        Set<String> socialInfo = new Set<String>{'Total_Facebook__c', 'Total_Instagram__c', 'Total_Linkedin__c', 'Total_Twitter__c', 'Social_Profiles__c'};

        //Total Social information 
        Set<String> ageRangeInfo = new Set<String>{'Total_de_Hombres_de_0_a_15__c', 'Total_de_Hombres_de_16_a_17__c', 'Total_de_Hombres_de_18_a_24__c', 'Total_de_Hombres_de_25_a_39__c', 'Total_de_Hombres_de_40_a_64__c', 'Total_Hombres_de_65plus__c', 'Total_Mujeres_de_0_a_15__c', 'Total_Mujeres_de_16_a_17__c', 'Total_Mujeres_de_18_a_24__c', 'Total_Mujeres_de_25_a_39__c', 'Total_Mujeres_de_40_a_64__c', 'Total_Mujeres_de_65plus__c'};
            
		Set<String> ageRangeInfo2 = new Set<String>{'Etario_Baby_Boomers_Female__c','Etario_Baby_Boomers_Male__c','Etario_Baby_Boomers_Total__c','Etario_Centennials_Female__c','Etario_Centennials_Male__c','Etario_Centennials_Total__c','Etario_Generacion_Silenciosa_Female__c','Etario_Generacion_Silenciosa_Male__c','Etario_Generacion_Silenciosa_Total__c','Etario_Generacion_X_Female__c','Etario_Generacion_X_Male__c','Etario_Generacion_X_Total__c','Etario_Millennials_Female__c','Etario_Millennials_Male__c','Etario_Millennials_Total__c','Etario_Sub_16_Female__c','Etario_Sub_16_Male__c','Etario_Sub_16_Total__c'};

        Set<String> actividadesEconomicas2 = new Set<String>{'Total_Economic_Activities__c'};

        List<String> fldnames = new List<String>();
		fldnames.addAll(territoryInfo);
		fldnames.addAll(contactInfo);
	    fldnames.addAll(socialInfo);
		fldnames.addAll(ageRangeInfo);
		fldnames.addAll(ageRangeInfo2);
		fldnames.addAll(actividadesEconomicas2);

        String queryString = 'SELECT Id , Name, ';
        queryString += String.join(fldnames, ',');
        queryString += ' FROM Territorio_Administrativo__c WHERE Id =: territoryId';
            
        territory = Database.query(String.escapeSingleQuotes(queryString));
            
            territoryWrapper = new TerritoryWrapper2(territory);
        }
        System.debug('territorio a mostrar: ' + territoryWrapper);
        return territoryWrapper;
    }
    
    @AuraEnabled
    public static RemotingMessageHelper.SalesforceDoamins retrieveSalesforceDomains() {
        RemotingMessageHelper.SalesforceDoamins objDomains = null;
        List<Community_Config__mdt> lstSettings = null;
        String strSite = null;        
        
        System.debug('retrieveSalesforceDomains [] ->');
        
        objDomains = new RemotingMessageHelper.SalesforceDoamins();
        
        System.debug('retrieveSalesforceDomains [ URL : ' + URL.getCurrentRequestUrl().toExternalForm().toLowerCase() + ']');
        
        if(!Test.isRunningTest()) {
            strSite = [SELECT Id, Name 
                       FROM Network 
                       WHERE Id =: Network.getNetworkId()].Name;
        } else {
            strSite = 'Prosumia';
        }
        
        System.debug('retrieveSalesforceDomains [ strSite : ' + strSite + ']');
        
        lstSettings = [SELECT LEX_Domain__c, VF_Domain__c 
                       FROM Community_Config__mdt 
                       WHERE DeveloperName = : strSite];
        
        System.debug('retrieveSalesforceDomains [ lstSettings : ' + lstSettings + ']');

        if(!lstSettings.isEmpty()) {
            objDomains.LEX = lstSettings[0].LEX_Domain__c;
            objDomains.VF = lstSettings[0].VF_Domain__c;
        }
        
        System.debug('retrieveSalesforceDomains [' + objDomains + '] <-');
        return  objDomains;        
    }
    
    @AuraEnabled
    public static TerritoryWrapper getRootTerritoryInfo() {        
        RemotingMessageHelper.Territory objTerritory = NULL;
        TerritoryWrapper objTerritoryWrapper = NULL;
       	
        objTerritory = TerritoryHierarchyController.retrieveParentTerritory();
        objTerritoryWrapper = getTerritoryById(objTerritory.Id);
        
        return objTerritoryWrapper;
    }


}