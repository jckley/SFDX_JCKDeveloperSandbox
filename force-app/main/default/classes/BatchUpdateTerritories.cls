global inherited sharing class BatchUpdateTerritories implements Database.Batchable<sObject>, Database.Stateful  {
    
    private static String BABY_BOOMERS = 'BABY_BOOMERS';
    private static String CENTENNIALS = 'CENTENNIALS';
    private static String GENERACION_X = 'GENERACION_X';
    private static String GENERACION_SILENCIOSA = 'GENERACION_SILENCIOSA';
    private static String MILLENIALS = 'MILLENIALS';
    private static String SUB_16 = 'SUB_16';
    private static String WAGE_EARNER = 'Asalariado';
    private static String SELF_EMPLOYED = 'Cuenta propia';
    private static String NOT_DECLARED = 'Asalariado';
    private static String RETIRED = 'Jubilados y pensionados';
    private static String SELF_EMPLOYED_2 = 'Cooperativas y precaria';
    private List<Territorio_Administrativo__c> territories;
    private Map<String, Territorio_Administrativo__c> territories0;
    private Map<String, Territorio_Administrativo__c> territories1;
    private Map<String, Territorio_Administrativo__c> territories2;
    private Map<String, Territorio_Administrativo__c> territories3;
    private Map<String, Territorio_Administrativo__c> territories4;
    private String levelOName;
    private Integer adminLevel;
    private Boolean processTree;
    
    global BatchUpdateTerritories(Integer adminLevel, String levelOName){
        this.adminLevel = adminLevel;
        this.levelOName = levelOName;

        territories0 = new Map<String, Territorio_Administrativo__c>();
        territories1 = new Map<String, Territorio_Administrativo__c>();
        territories2 = new Map<String, Territorio_Administrativo__c>();
        territories3 = new Map<String, Territorio_Administrativo__c>();
        territories4 = new Map<String, Territorio_Administrativo__c>();

    }

    global BatchUpdateTerritories(List<Territorio_Administrativo__c> territories, Integer adminLevel, String levelOName){
        init(territories, adminLevel, levelOName, false);
    }

    global BatchUpdateTerritories(List<Territorio_Administrativo__c> territories, Integer adminLevel, String levelOName, Boolean processTree){
        init(territories, adminLevel, levelOName, processTree);
    }

    private void init(List<Territorio_Administrativo__c> territories, Integer adminLevel, String levelOName, Boolean processTree){
        this.adminLevel = adminLevel;
        this.levelOName = levelOName;
        this.territories = territories;
        this.processTree = processTree;

        territories0 = new Map<String, Territorio_Administrativo__c>();
        territories1 = new Map<String, Territorio_Administrativo__c>();
        territories2 = new Map<String, Territorio_Administrativo__c>();
        territories3 = new Map<String, Territorio_Administrativo__c>();
        territories4 = new Map<String, Territorio_Administrativo__c>();

    }

    /*
    global BatchUpdateTerritories(List<Territorio_Administrativo__c> territories){
        this.territories = territories;
    }
    */
    global Database.QueryLocator start(Database.BatchableContext BC){

        Set<String> territoriesId = new Set<String>();
        
        for(Territorio_Administrativo__c territory : territories){
            territoriesId.add(territory.Id);
        }

        if(processTree){

            if(adminLevel == 4){

                for(Territorio_Administrativo__c territory : [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c, Total_Emails__c, Total_Ciudadanos__c, Total_Facebook__c, Total_Instagram__c, Total_Telefonos_FIjos__c, Total_Linkedin__c,
                                                            Total_Moviles__c, Total_Twitter__c, Etario_Generacion_Silenciosa_Male__c, Etario_Generacion_Silenciosa_Female__c, Etario_Generacion_Silenciosa_Total__c,
                                                            Etario_Baby_Boomers_Male__c, Etario_Baby_Boomers_Female__c, Etario_Baby_Boomers_Total__c, Etario_Generacion_X_Male__c, Etario_Generacion_X_Female__c,
                                                            Etario_Generacion_X_Total__c, Etario_Millennials_Male__c, Etario_Millennials_Female__c, Etario_Millennials_Total__c, Etario_Centennials_Male__c,
                                                            Etario_Centennials_Female__c, Etario_Centennials_Total__c, Etario_Sub_16_Male__c, Etario_Sub_16_Female__c, Etario_Sub_16_Total__c,
                                                            Total_de_Hombres_de_0_a_15__c, Total_Mujeres_de_0_a_15__c, Total_Number_of_00_15_year_olds__c, Total_de_Hombres_de_16_a_17__c,
                                                            Total_Mujeres_de_16_a_17__c, Total_Number_of_16_17_year_olds__c, Total_de_Hombres_de_18_a_24__c, Total_Mujeres_de_18_a_24__c, Total_Number_of_18_24_year_olds__c,
                                                            Total_de_Hombres_de_25_a_39__c, Total_Mujeres_de_25_a_39__c, Total_Number_of_25_39_year_olds__c, Total_de_Hombres_de_40_a_64__c,
                                                            Total_Mujeres_de_40_a_64__c, Total_Number_of_40_64_year_olds__c, Total_Hombres_de_65plus__c, Total_Mujeres_de_65plus__c,
                                                            Total_Number_of_65_year_olds__c, Total_Number_of_Males__c, Total_Number_of_Females__c, Total_Income_Range_Very_Low__c,
                                                            Total_Income_Range_Low__c, Total_Income_Range_Medium__c, Total_Income_Range_High__c, Total_Income_Range_Very_High__c, Total_Education_Level_University_Degree__c,
                                                            Total_Education_Level_Primary__c, Total_Education_Level_Secondary__c, Total_Education_Level_Tertiary__c, Total_Occupation_Type_Not_Declared__c,
                                                            Total_Occupation_Type_Retired__c, Total_Occupation_Type_Self_Employed__c, Total_Occupation_Type_Wage_Earned__c,
                                                            Total_Economic_Activities__c 
                                                    FROM Territorio_Administrativo__c WHERE Id IN :territoriesId]){
            
                    
                    initTerritory(territory, territoriesId);
                    
                }

            } else if(adminLevel == 3){

                for(Territorio_Administrativo__c territory : [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c, Total_Emails__c, Total_Ciudadanos__c, Total_Facebook__c, Total_Instagram__c, Total_Telefonos_FIjos__c, Total_Linkedin__c,
                                                            Total_Moviles__c, Total_Twitter__c, Etario_Generacion_Silenciosa_Male__c, Etario_Generacion_Silenciosa_Female__c, Etario_Generacion_Silenciosa_Total__c,
                                                            Etario_Baby_Boomers_Male__c, Etario_Baby_Boomers_Female__c, Etario_Baby_Boomers_Total__c, Etario_Generacion_X_Male__c, Etario_Generacion_X_Female__c,
                                                            Etario_Generacion_X_Total__c, Etario_Millennials_Male__c, Etario_Millennials_Female__c, Etario_Millennials_Total__c, Etario_Centennials_Male__c,
                                                            Etario_Centennials_Female__c, Etario_Centennials_Total__c, Etario_Sub_16_Male__c, Etario_Sub_16_Female__c, Etario_Sub_16_Total__c,
                                                            Total_de_Hombres_de_0_a_15__c, Total_Mujeres_de_0_a_15__c, Total_Number_of_00_15_year_olds__c, Total_de_Hombres_de_16_a_17__c,
                                                            Total_Mujeres_de_16_a_17__c, Total_Number_of_16_17_year_olds__c, Total_de_Hombres_de_18_a_24__c, Total_Mujeres_de_18_a_24__c, Total_Number_of_18_24_year_olds__c,
                                                            Total_de_Hombres_de_25_a_39__c, Total_Mujeres_de_25_a_39__c, Total_Number_of_25_39_year_olds__c, Total_de_Hombres_de_40_a_64__c,
                                                            Total_Mujeres_de_40_a_64__c, Total_Number_of_40_64_year_olds__c, Total_Hombres_de_65plus__c, Total_Mujeres_de_65plus__c,
                                                            Total_Number_of_65_year_olds__c, Total_Number_of_Males__c, Total_Number_of_Females__c, Total_Income_Range_Very_Low__c,
                                                            Total_Income_Range_Low__c, Total_Income_Range_Medium__c, Total_Income_Range_High__c, Total_Income_Range_Very_High__c, Total_Education_Level_University_Degree__c,
                                                            Total_Education_Level_Primary__c, Total_Education_Level_Secondary__c, Total_Education_Level_Tertiary__c, Total_Occupation_Type_Not_Declared__c,
                                                            Total_Occupation_Type_Retired__c, Total_Occupation_Type_Self_Employed__c, Total_Occupation_Type_Wage_Earned__c,
                                                            Total_Economic_Activities__c 
                                                    FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c >= :adminLevel AND (Id IN :territoriesId OR ParentId__c IN :territoriesId)]){
            
            
                    initTerritory(territory, territoriesId);
                                        
                }

            } else if(adminLevel == 2){

                for(Territorio_Administrativo__c territory : [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c, Total_Emails__c, Total_Ciudadanos__c, Total_Facebook__c, Total_Instagram__c, Total_Telefonos_FIjos__c, Total_Linkedin__c,
                                                            Total_Moviles__c, Total_Twitter__c, Etario_Generacion_Silenciosa_Male__c, Etario_Generacion_Silenciosa_Female__c, Etario_Generacion_Silenciosa_Total__c,
                                                            Etario_Baby_Boomers_Male__c, Etario_Baby_Boomers_Female__c, Etario_Baby_Boomers_Total__c, Etario_Generacion_X_Male__c, Etario_Generacion_X_Female__c,
                                                            Etario_Generacion_X_Total__c, Etario_Millennials_Male__c, Etario_Millennials_Female__c, Etario_Millennials_Total__c, Etario_Centennials_Male__c,
                                                            Etario_Centennials_Female__c, Etario_Centennials_Total__c, Etario_Sub_16_Male__c, Etario_Sub_16_Female__c, Etario_Sub_16_Total__c,
                                                            Total_de_Hombres_de_0_a_15__c, Total_Mujeres_de_0_a_15__c, Total_Number_of_00_15_year_olds__c, Total_de_Hombres_de_16_a_17__c,
                                                            Total_Mujeres_de_16_a_17__c, Total_Number_of_16_17_year_olds__c, Total_de_Hombres_de_18_a_24__c, Total_Mujeres_de_18_a_24__c, Total_Number_of_18_24_year_olds__c,
                                                            Total_de_Hombres_de_25_a_39__c, Total_Mujeres_de_25_a_39__c, Total_Number_of_25_39_year_olds__c, Total_de_Hombres_de_40_a_64__c,
                                                            Total_Mujeres_de_40_a_64__c, Total_Number_of_40_64_year_olds__c, Total_Hombres_de_65plus__c, Total_Mujeres_de_65plus__c,
                                                            Total_Number_of_65_year_olds__c, Total_Number_of_Males__c, Total_Number_of_Females__c, Total_Income_Range_Very_Low__c,
                                                            Total_Income_Range_Low__c, Total_Income_Range_Medium__c, Total_Income_Range_High__c, Total_Income_Range_Very_High__c, Total_Education_Level_University_Degree__c,
                                                            Total_Education_Level_Primary__c, Total_Education_Level_Secondary__c, Total_Education_Level_Tertiary__c, Total_Occupation_Type_Not_Declared__c,
                                                            Total_Occupation_Type_Retired__c, Total_Occupation_Type_Self_Employed__c, Total_Occupation_Type_Wage_Earned__c,
                                                            Total_Economic_Activities__c 
                                                    FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c >= :adminLevel AND (Id IN :territoriesId OR ParentId__c IN :territoriesId OR ParentId__r.ParentId__c IN :territoriesId)]){
            
                    initTerritory(territory, territoriesId);
                                        
                }

            }

        } else {

            for(Territorio_Administrativo__c territory : [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c, Total_Emails__c, Total_Ciudadanos__c, Total_Facebook__c, Total_Instagram__c, Total_Telefonos_FIjos__c, Total_Linkedin__c,
                                                            Total_Moviles__c, Total_Twitter__c, Etario_Generacion_Silenciosa_Male__c, Etario_Generacion_Silenciosa_Female__c, Etario_Generacion_Silenciosa_Total__c,
                                                            Etario_Baby_Boomers_Male__c, Etario_Baby_Boomers_Female__c, Etario_Baby_Boomers_Total__c, Etario_Generacion_X_Male__c, Etario_Generacion_X_Female__c,
                                                            Etario_Generacion_X_Total__c, Etario_Millennials_Male__c, Etario_Millennials_Female__c, Etario_Millennials_Total__c, Etario_Centennials_Male__c,
                                                            Etario_Centennials_Female__c, Etario_Centennials_Total__c, Etario_Sub_16_Male__c, Etario_Sub_16_Female__c, Etario_Sub_16_Total__c,
                                                            Total_de_Hombres_de_0_a_15__c, Total_Mujeres_de_0_a_15__c, Total_Number_of_00_15_year_olds__c, Total_de_Hombres_de_16_a_17__c,
                                                            Total_Mujeres_de_16_a_17__c, Total_Number_of_16_17_year_olds__c, Total_de_Hombres_de_18_a_24__c, Total_Mujeres_de_18_a_24__c, Total_Number_of_18_24_year_olds__c,
                                                            Total_de_Hombres_de_25_a_39__c, Total_Mujeres_de_25_a_39__c, Total_Number_of_25_39_year_olds__c, Total_de_Hombres_de_40_a_64__c,
                                                            Total_Mujeres_de_40_a_64__c, Total_Number_of_40_64_year_olds__c, Total_Hombres_de_65plus__c, Total_Mujeres_de_65plus__c,
                                                            Total_Number_of_65_year_olds__c, Total_Number_of_Males__c, Total_Number_of_Females__c, Total_Income_Range_Very_Low__c,
                                                            Total_Income_Range_Low__c, Total_Income_Range_Medium__c, Total_Income_Range_High__c, Total_Income_Range_Very_High__c, Total_Education_Level_University_Degree__c,
                                                            Total_Education_Level_Primary__c, Total_Education_Level_Secondary__c, Total_Education_Level_Tertiary__c, Total_Occupation_Type_Not_Declared__c,
                                                            Total_Occupation_Type_Retired__c, Total_Occupation_Type_Self_Employed__c, Total_Occupation_Type_Wage_Earned__c,
                                                            Total_Economic_Activities__c 
                                                    FROM Territorio_Administrativo__c WHERE Id IN :territoriesId]){
            
            
                if(territory.Nivel_Administrativo__c == 0){
                    territories0.put(territory.Id, territory);
                } else if(territory.Nivel_Administrativo__c == 1){
                    territories1.put(territory.Id, territory);
                } else if(territory.Nivel_Administrativo__c == 2){
                    territories2.put(territory.Id, territory);
                } else if(territory.Nivel_Administrativo__c == 3){
                    territories3.put(territory.Id, territory);
                } else if(territory.Nivel_Administrativo__c == 4){
                    territories4.put(territory.Id, territory);
                }
                
            }
        
        }

        return Database.getQueryLocator([SELECT Id, Birthdate, Age_f_x__c, Education_Level__c, Gender__c, Ingreso__c, Profession__c, 
                                                    Tiene_Email__c, Tiene_Moviles__c, Tiene_Telefonos_Fijos__c, Tiene_Facebook__c, 
                                                    Tiene_Instagram__c, Tiene_Linkedin__c, Tiene_Twitter__c, Territorio_Administrativo__c, 
                                                    condicion_de_ingreso__c, actividades_economicas__c
                                            FROM Contact 
                                            WHERE Territorio_Administrativo__c != null AND Territorio_Administrativo__c IN :territoriesId]);

        
    }
   
    global void execute(Database.BatchableContext BC, List<Contact> scope){
    	
        for(Contact citizen : scope){
            try{
                processCitizen(citizen);
            } catch(Exception e){
                System.debug('BatchUpdateTerritories error: ' + e.getLineNumber() + ' - ' +e.getMessage());
            }
            
        }

    }

    global void finish(Database.BatchableContext BC) {

        List<Territorio_Administrativo__c> territoriesUpdate = new List<Territorio_Administrativo__c>();
        
        if(processTree){
            for(Territorio_Administrativo__c territory : [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c, Total_Emails__c, Total_Ciudadanos__c, Total_Facebook__c, Total_Instagram__c, Total_Telefonos_FIjos__c, Total_Linkedin__c,
                                                            Total_Moviles__c, Total_Twitter__c, Etario_Generacion_Silenciosa_Male__c, Etario_Generacion_Silenciosa_Female__c, Etario_Generacion_Silenciosa_Total__c,
                                                            Etario_Baby_Boomers_Male__c, Etario_Baby_Boomers_Female__c, Etario_Baby_Boomers_Total__c, Etario_Generacion_X_Male__c, Etario_Generacion_X_Female__c,
                                                            Etario_Generacion_X_Total__c, Etario_Millennials_Male__c, Etario_Millennials_Female__c, Etario_Millennials_Total__c, Etario_Centennials_Male__c,
                                                            Etario_Centennials_Female__c, Etario_Centennials_Total__c, Etario_Sub_16_Male__c, Etario_Sub_16_Female__c, Etario_Sub_16_Total__c,
                                                            Total_de_Hombres_de_0_a_15__c, Total_Mujeres_de_0_a_15__c, Total_Number_of_00_15_year_olds__c, Total_de_Hombres_de_16_a_17__c,
                                                            Total_Mujeres_de_16_a_17__c, Total_Number_of_16_17_year_olds__c, Total_de_Hombres_de_18_a_24__c, Total_Mujeres_de_18_a_24__c, Total_Number_of_18_24_year_olds__c,
                                                            Total_de_Hombres_de_25_a_39__c, Total_Mujeres_de_25_a_39__c, Total_Number_of_25_39_year_olds__c, Total_de_Hombres_de_40_a_64__c,
                                                            Total_Mujeres_de_40_a_64__c, Total_Number_of_40_64_year_olds__c, Total_Hombres_de_65plus__c, Total_Mujeres_de_65plus__c,
                                                            Total_Number_of_65_year_olds__c, Total_Number_of_Males__c, Total_Number_of_Females__c, Total_Income_Range_Very_Low__c,
                                                            Total_Income_Range_Low__c, Total_Income_Range_Medium__c, Total_Income_Range_High__c, Total_Income_Range_Very_High__c, Total_Education_Level_University_Degree__c,
                                                            Total_Education_Level_Primary__c, Total_Education_Level_Secondary__c, Total_Education_Level_Tertiary__c, Total_Occupation_Type_Not_Declared__c,
                                                            Total_Occupation_Type_Retired__c, Total_Occupation_Type_Self_Employed__c, Total_Occupation_Type_Wage_Earned__c,
                                                            Total_Economic_Activities__c 
                                                      FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c < :adminLevel AND Level0Name__c = :levelOName FOR UPDATE]){
            
                    if(territory.Nivel_Administrativo__c == 0){
                        territories0.put(territory.Id, territory);
                    } else if(territory.Nivel_Administrativo__c == 1){
                        territories1.put(territory.Id, territory);
                    } else if(territory.Nivel_Administrativo__c == 2){
                        territories2.put(territory.Id, territory);
                    } else if(territory.Nivel_Administrativo__c == 3){
                        territories3.put(territory.Id, territory);
                    } else if(territory.Nivel_Administrativo__c == 4){
                        territories4.put(territory.Id, territory);
                    }

            }

            if(!territories4.isEmpty()){
                for(Territorio_Administrativo__c territory4 : territories4.values()){
                    processTerritory(territories3.get(territory4.ParentId__c), territory4);
                }
            }
                
            for(Territorio_Administrativo__c territory3 : territories3.values()){
                processTerritory(territories2.get(territory3.ParentId__c), territory3);
            }

            Territorio_Administrativo__c territory0;
            Territorio_Administrativo__c territory1;
    
            for(Territorio_Administrativo__c territory2 : territories2.values()){
                territory1 = territories1.get(territory2.ParentId__c);
                processTerritory(territory1, territory2);
                territory0 = territories0.get(territory1.ParentId__c);
                processTerritory(territory0, territory2);
            }
            
        } else{

            for(Territorio_Administrativo__c territory1 : territories1.values()){
                processTerritory(territories0.get(territory1.ParentId__c), territory1);
            }

        }
        
        territoriesUpdate.addAll(territories4.values());
        territoriesUpdate.addAll(territories3.values());
        territoriesUpdate.addAll(territories2.values());
        territoriesUpdate.addAll(territories1.values());
        territoriesUpdate.addAll(territories0.values());
        
        update territoriesUpdate;

    }

    private void processCitizen(Contact citizen){

        Territorio_Administrativo__c territory;

        if(territories4.containsKey(citizen.Territorio_Administrativo__c)){
            territory = territories4.get(citizen.Territorio_Administrativo__c);
        } else if(territories3.containsKey(citizen.Territorio_Administrativo__c)){
            territory = territories3.get(citizen.Territorio_Administrativo__c);
        } else if(territories2.containsKey(citizen.Territorio_Administrativo__c)){
            territory = territories2.get(citizen.Territorio_Administrativo__c);
        } else if(territories1.containsKey(citizen.Territorio_Administrativo__c)){
            territory = territories1.get(citizen.Territorio_Administrativo__c);
        } else if(territories0.containsKey(citizen.Territorio_Administrativo__c)){
            territory = territories0.get(citizen.Territorio_Administrativo__c);
        }

        if(territory != null){

            Boolean hasGender = citizen.Gender__c != null;
            Boolean isMale = hasGender ? citizen.Gender__c.toUpperCase().equals('M') : null;
            Integer age = citizen.Age_f_x__c.intValue();
            Integer year = citizen.Birthdate.year();
            String rangoEtario;

            if(year < 1949){
                rangoEtario = GENERACION_SILENCIOSA;
            } else if(year <= 1964){
                rangoEtario = BABY_BOOMERS;
            } else if(year <= 1979){
                rangoEtario = GENERACION_X;
            } else if(year <= 1994){
                rangoEtario = MILLENIALS;
            } else if(year <= 2004){
                rangoEtario = CENTENNIALS;
            } else {
                rangoEtario = SUB_16;
            }

            territory.Total_Ciudadanos__c += 1;

            if(citizen.Tiene_Email__c){
                territory.Total_Emails__c += 1;
            }

            if(citizen.Tiene_Facebook__c){
                territory.Total_Facebook__c += 1;
            }

            if(citizen.Tiene_Instagram__c){
                territory.Total_Instagram__c += 1;
            }

            if(citizen.Tiene_Telefonos_Fijos__c){
                territory.Total_Telefonos_FIjos__c += 1;
            }

            if(citizen.Tiene_Linkedin__c){
                territory.Total_Linkedin__c += 1;
            }

            if(citizen.Tiene_Moviles__c){
                territory.Total_Moviles__c += 1;
            }

            if(citizen.Tiene_Twitter__c){
                territory.Total_Twitter__c += 1;
            }

            if(hasGender){

                if(isMale){

                    if(rangoEtario.equals(GENERACION_SILENCIOSA)){
                        territory.Etario_Generacion_Silenciosa_Male__c += 1;
                        territory.Etario_Generacion_Silenciosa_Total__c += 1;
                    } else if(rangoEtario.equals(BABY_BOOMERS)){
                        territory.Etario_Baby_Boomers_Male__c += 1;
                        territory.Etario_Baby_Boomers_Total__c += 1;
                    } else if(rangoEtario.equals(GENERACION_X)){
                        territory.Etario_Generacion_X_Male__c += 1;
                        territory.Etario_Generacion_X_Total__c += 1;
                    } else if(rangoEtario.equals(MILLENIALS)){
                        territory.Etario_Millennials_Male__c += 1;
                        territory.Etario_Millennials_Total__c += 1;
                    } else if(rangoEtario.equals(CENTENNIALS)){
                        territory.Etario_Centennials_Male__c += 1;
                        territory.Etario_Centennials_Total__c += 1;
                    } else {
                        territory.Etario_Sub_16_Male__c += 1;
                        territory.Etario_Sub_16_Total__c += 1;
                    }

                    if(age <= 15){
                        territory.Total_de_Hombres_de_0_a_15__c += 1;
                        territory.Total_Number_of_00_15_year_olds__c += 1;
                    } else if(age <= 17){
                        territory.Total_de_Hombres_de_16_a_17__c += 1;
                        territory.Total_Number_of_16_17_year_olds__c += 1;
                    } else if(age <= 24){
                        territory.Total_de_Hombres_de_18_a_24__c += 1;
                        territory.Total_Number_of_18_24_year_olds__c += 1;
                    } else if(age <= 39){
                        territory.Total_de_Hombres_de_25_a_39__c += 1;
                        territory.Total_Number_of_25_39_year_olds__c += 1;
                    } else if(age <= 64){
                        territory.Total_de_Hombres_de_40_a_64__c += 1;
                        territory.Total_Number_of_40_64_year_olds__c += 1;
                    } else {
                        territory.Total_Hombres_de_65plus__c += 1;
                        territory.Total_Number_of_65_year_olds__c += 1;
                    }

                    territory.Total_Number_of_Males__c += 1;

                } else {

                    if(rangoEtario.equals(GENERACION_SILENCIOSA)){
                        territory.Etario_Generacion_Silenciosa_Female__c += 1;
                        territory.Etario_Generacion_Silenciosa_Total__c += 1;
                    } else if(rangoEtario.equals(BABY_BOOMERS)){
                        territory.Etario_Baby_Boomers_Female__c += 1;
                        territory.Etario_Baby_Boomers_Total__c += 1;
                    } else if(rangoEtario.equals(GENERACION_X)){
                        territory.Etario_Generacion_X_Female__c += 1;
                        territory.Etario_Generacion_X_Total__c += 1;
                    } else if(rangoEtario.equals(MILLENIALS)){
                        territory.Etario_Millennials_Female__c += 1;
                        territory.Etario_Millennials_Total__c += 1;
                    } else if(rangoEtario.equals(CENTENNIALS)){
                        territory.Etario_Centennials_Female__c += 1;
                        territory.Etario_Centennials_Total__c += 1;
                    } else {
                        territory.Etario_Sub_16_Female__c += 1;
                        territory.Etario_Sub_16_Total__c += 1;
                    }

                    if(age <= 15){
                        territory.Total_Mujeres_de_0_a_15__c += 1;
                        territory.Total_Number_of_00_15_year_olds__c += 1;
                    } else if(age <= 17){
                        territory.Total_Mujeres_de_16_a_17__c += 1;
                        territory.Total_Number_of_16_17_year_olds__c += 1;
                    } else if(age <= 24){
                        territory.Total_Mujeres_de_18_a_24__c += 1;
                        territory.Total_Number_of_18_24_year_olds__c += 1;
                    } else if(age <= 39){
                        territory.Total_Mujeres_de_25_a_39__c += 1;
                        territory.Total_Number_of_25_39_year_olds__c += 1;
                    } else if(age <= 64){
                        territory.Total_Mujeres_de_40_a_64__c += 1;
                        territory.Total_Number_of_40_64_year_olds__c += 1;
                    } else {
                        territory.Total_Mujeres_de_65Plus__c += 1;
                        territory.Total_Number_of_65_year_olds__c += 1;
                    }

                    territory.Total_Number_of_Females__c += 1;

                }

            }

            if(citizen.Ingreso__c != null){
                if(citizen.Ingreso__c.equals('Muy Bajo')){
                    territory.Total_Income_Range_Very_Low__c += 1;
                } else if(citizen.Ingreso__c.equals('Bajo')){
                    territory.Total_Income_Range_Low__c += 1;
                } else if(citizen.Ingreso__c.equals('Medio')){
                    territory.Total_Income_Range_Medium__c += 1;
                } else if(citizen.Ingreso__c.equals('Alto')){
                    territory.Total_Income_Range_High__c += 1;
                } else if(citizen.Ingreso__c.equals('Muy Alto')){
                    territory.Total_Income_Range_Very_High__c += 1;
                }
            }

            if(citizen.Education_Level__c  != null){
                if(citizen.Education_Level__c.toUpperCase().contains('PRIMARIO')){
                    territory.Total_Education_Level_Primary__c += 1;
                } else if(citizen.Education_Level__c.toUpperCase().contains('SECUNDARIO')){
                    territory.Total_Education_Level_Secondary__c += 1;
                } else if(citizen.Education_Level__c.toUpperCase().contains('TERCIARIO')){
                    territory.Total_Education_Level_Tertiary__c += 1;
                } else if(citizen.Education_Level__c.toUpperCase().contains('UNIVERSITARIO')){
                    territory.Total_Education_Level_University_Degree__c += 1;
                } 
            }

            // ***************************************
            // BEGIN: Economic Activities
            // ***************************************

            // System.debug('BatchUpdateTerritories [ Total_Economic_Activities__c (BEFORE): ' + territory.Total_Economic_Activities__c  +  ']');
            // System.debug('BatchUpdateTerritories [ actividades_economicas__c : ' + citizen.actividades_economicas__c  +  ']');

            List<String> lstTotalEconomicActivities = String.isNotBlank(territory.Total_Economic_Activities__c) ? territory.Total_Economic_Activities__c.split(';') : new List<String>();
            List<String> lstActividadesEconomicas = String.isNotBlank(citizen.actividades_economicas__c) ? citizen.actividades_economicas__c.split(';') : new List<String>();
            for (Integer i = 0 ; i < lstActividadesEconomicas.size() ; i++) {
                // System.debug('BatchUpdateTerritories [ lstActividadesEconomicas : ' + lstActividadesEconomicas[i]  +  ']');
                // System.debug('BatchUpdateTerritories [ lstTotalEconomicActivities.size() : ' + lstTotalEconomicActivities.size()  +  ']');
                Boolean found = false;
                for (Integer j = 0 ; j < lstTotalEconomicActivities.size() && found == false; j++) {

                    List<String> actividad_total = lstTotalEconomicActivities[j].split(':');
                    String actividad = actividad_total[0];
                    Integer total = Integer.valueOf(actividad_total[1]);

                    found = (actividad == lstActividadesEconomicas[i]);
                    if (found) {
                        lstTotalEconomicActivities[j] = actividad + ':' + String.valueOf(total + 1);
                    }
                }
                if (found == false) {
                    lstTotalEconomicActivities.add(lstActividadesEconomicas[i]+':1');
                }

            }
            if (lstTotalEconomicActivities.size() > 0) {
                territory.Total_Economic_Activities__c = String.join(lstTotalEconomicActivities, ';');
            }
            // System.debug('BatchUpdateTerritories [ Total_Economic_Activities__c (AFTER): ' + territory.Total_Economic_Activities__c  +  ']');

            // END: Economic Activities
        }
        
        if(citizen.Condicion_de_ingreso__c == null){
            territory.Total_Occupation_Type_Not_Declared__c += 1;
        } else {
            territory.Total_Occupation_Type_Retired__c += citizen.Condicion_de_ingreso__c.contains(RETIRED) ? 1 : 0;
            territory.Total_Occupation_Type_Self_Employed__c += citizen.Condicion_de_ingreso__c.contains(SELF_EMPLOYED) || citizen.Condicion_de_ingreso__c.contains(SELF_EMPLOYED_2) ? 1 : 0;
            territory.Total_Occupation_Type_Wage_Earned__c += citizen.Condicion_de_ingreso__c.contains(WAGE_EARNER) ? 1 : 0;
        }
        

    }

    private void processTerritory(Territorio_Administrativo__c parentTerritory, Territorio_Administrativo__c territory){

        parentTerritory.Total_Emails__c += territory.Total_Emails__c;
        parentTerritory.Etario_Baby_Boomers_Female__c += territory.Etario_Baby_Boomers_Female__c;
        parentTerritory.Etario_Baby_Boomers_Male__c += territory.Etario_Baby_Boomers_Male__c;
        parentTerritory.Etario_Baby_Boomers_Total__c += territory.Etario_Baby_Boomers_Total__c;
        parentTerritory.Etario_Centennials_Female__c += territory.Etario_Centennials_Female__c;
        parentTerritory.Etario_Centennials_Male__c += territory.Etario_Centennials_Male__c;
        parentTerritory.Etario_Centennials_Total__c += territory.Etario_Centennials_Total__c;
        parentTerritory.Etario_Generacion_Silenciosa_Total__c += territory.Etario_Generacion_Silenciosa_Total__c;
        parentTerritory.Etario_Generacion_Silenciosa_Female__c += territory.Etario_Generacion_Silenciosa_Female__c;
        parentTerritory.Etario_Generacion_Silenciosa_Male__c += territory.Etario_Generacion_Silenciosa_Male__c;
        parentTerritory.Etario_Generacion_X_Female__c += territory.Etario_Generacion_X_Female__c;
        parentTerritory.Etario_Generacion_X_Male__c += territory.Etario_Generacion_X_Male__c;
        parentTerritory.Etario_Generacion_X_Total__c += territory.Etario_Generacion_X_Total__c;
        parentTerritory.Etario_Millennials_Female__c += territory.Etario_Millennials_Female__c;
        parentTerritory.Etario_Millennials_Male__c += territory.Etario_Millennials_Male__c;
        parentTerritory.Etario_Millennials_Total__c += territory.Etario_Millennials_Total__c;
        parentTerritory.Etario_Sub_16_Female__c += territory.Etario_Sub_16_Female__c;
        parentTerritory.Etario_Sub_16_Male__c += territory.Etario_Sub_16_Male__c;
        parentTerritory.Etario_Sub_16_Total__c += territory.Etario_Sub_16_Total__c;
        parentTerritory.Total_Facebook__c += territory.Total_Facebook__c;
        parentTerritory.Total_Instagram__c += territory.Total_Instagram__c;
        parentTerritory.Total_Telefonos_FIjos__c += territory.Total_Telefonos_FIjos__c;
        parentTerritory.Total_Linkedin__c += territory.Total_Linkedin__c;
        parentTerritory.Total_Moviles__c += territory.Total_Moviles__c;
        parentTerritory.Total_Number_of_00_15_year_olds__c += territory.Total_Number_of_00_15_year_olds__c;
        parentTerritory.Total_Number_of_16_17_year_olds__c += territory.Total_Number_of_16_17_year_olds__c;
        parentTerritory.Total_Number_of_65_year_olds__c += territory.Total_Number_of_65_year_olds__c;
        parentTerritory.Total_Number_of_18_24_year_olds__c += territory.Total_Number_of_18_24_year_olds__c;
        parentTerritory.Total_Number_of_25_39_year_olds__c += territory.Total_Number_of_25_39_year_olds__c;
        parentTerritory.Total_Number_of_40_64_year_olds__c += territory.Total_Number_of_40_64_year_olds__c;
        parentTerritory.Total_Number_of_Males__c += territory.Total_Number_of_Males__c;
        parentTerritory.Total_Number_of_Females__c += territory.Total_Number_of_Females__c;
        parentTerritory.Total_Ciudadanos__c += territory.Total_Ciudadanos__c;
        parentTerritory.Total_Education_Level_University_Degree__c += territory.Total_Education_Level_University_Degree__c;
        parentTerritory.Total_de_Hombres_de_0_a_15__c += territory.Total_de_Hombres_de_0_a_15__c;
        parentTerritory.Total_de_Hombres_de_16_a_17__c += territory.Total_de_Hombres_de_16_a_17__c;
        parentTerritory.Total_de_Hombres_de_18_a_24__c += territory.Total_de_Hombres_de_18_a_24__c;
        parentTerritory.Total_de_Hombres_de_25_a_39__c += territory.Total_de_Hombres_de_25_a_39__c;
        parentTerritory.Total_de_Hombres_de_40_a_64__c += territory.Total_de_Hombres_de_40_a_64__c;
        parentTerritory.Total_Education_Level_Primary__c += territory.Total_Education_Level_Primary__c;
        parentTerritory.Total_Education_Level_Secondary__c += territory.Total_Education_Level_Secondary__c;
        parentTerritory.Total_Education_Level_Tertiary__c += territory.Total_Education_Level_Tertiary__c;
        parentTerritory.Total_Hombres_de_65plus__c += territory.Total_Hombres_de_65plus__c;
        parentTerritory.Total_Income_Range_High__c += territory.Total_Income_Range_High__c;
        parentTerritory.Total_Income_Range_Low__c += territory.Total_Income_Range_Low__c;
        parentTerritory.Total_Income_Range_Medium__c += territory.Total_Income_Range_Medium__c;
        parentTerritory.Total_Income_Range_Very_High__c += territory.Total_Income_Range_Very_High__c;
        parentTerritory.Total_Income_Range_Very_Low__c += territory.Total_Income_Range_Very_Low__c;
        parentTerritory.Total_Mujeres_de_65Plus__c += territory.Total_Mujeres_de_65Plus__c;
        parentTerritory.Total_Mujeres_de_0_a_15__c += territory.Total_Mujeres_de_0_a_15__c;
        parentTerritory.Total_Mujeres_de_16_a_17__c += territory.Total_Mujeres_de_16_a_17__c;
        parentTerritory.Total_Mujeres_de_18_a_24__c += territory.Total_Mujeres_de_18_a_24__c;
        parentTerritory.Total_Mujeres_de_25_a_39__c += territory.Total_Mujeres_de_25_a_39__c;
        parentTerritory.Total_Mujeres_de_40_a_64__c += territory.Total_Mujeres_de_40_a_64__c;
        parentTerritory.Total_Occupation_Type_Not_Declared__c += territory.Total_Occupation_Type_Not_Declared__c;
        parentTerritory.Total_Occupation_Type_Retired__c += territory.Total_Occupation_Type_Retired__c;
        parentTerritory.Total_Occupation_Type_Self_Employed__c += territory.Total_Occupation_Type_Self_Employed__c;
        parentTerritory.Total_Occupation_Type_Wage_Earned__c += territory.Total_Occupation_Type_Wage_Earned__c;
        parentTerritory.Total_Twitter__c += territory.Total_Twitter__c;


        // ************************************************
        // BEGIN: SUM of Economic Activities
        // ************************************************

        // System.debug('BatchUpdateTerritories processTerritory [ Parent Total_Economic_Activities__c (BEFORE): ' + parentTerritory.Total_Economic_Activities__c  +  ']');
        // System.debug('BatchUpdateTerritories processTerritory [ Child  Total_Economic_Activities__c (BEFORE): ' + territory.Total_Economic_Activities__c  +  ']');

        List<String> lstTotalEconomicActivities_parent = String.isNotBlank(parentTerritory.Total_Economic_Activities__c) ? parentTerritory.Total_Economic_Activities__c.split(';') : new List<String>();
        List<String> lstTotalEconomicActivities_child  = String.isNotBlank(territory.Total_Economic_Activities__c) ? territory.Total_Economic_Activities__c.split(';') : new List<String>();
        for (Integer i = 0 ; i < lstTotalEconomicActivities_child.size() ; i++) {
            // System.debug('BatchUpdateTerritories [ lstTotalEconomicActivities_child : ' + lstTotalEconomicActivities_child[i]  +  ']');
            Boolean found = false;

            List<String> child_activity_total = lstTotalEconomicActivities_child[i].split(':');
            String child_activity = child_activity_total[0];
            Integer child_total = Integer.valueOf(child_activity_total[1]);

            for (Integer j = 0 ; j < lstTotalEconomicActivities_parent.size() && found == false; j++) {

                List<String> parent_activity_total = lstTotalEconomicActivities_parent[j].split(':');
                String parent_activity = parent_activity_total[0];
                Integer parent_total = Integer.valueOf(parent_activity_total[1]);

                found = (parent_activity == child_activity);
                if (found) {
                    lstTotalEconomicActivities_parent[j] = parent_activity + ':' + String.valueOf(parent_total + child_total);
                }
            }
            if (found == false) {
                lstTotalEconomicActivities_parent.add(lstTotalEconomicActivities_child[i]);
            }

        }
        if (lstTotalEconomicActivities_parent.size() > 0) {
            parentTerritory.Total_Economic_Activities__c = String.join(lstTotalEconomicActivities_parent , ';');
        }

        // System.debug('BatchUpdateTerritories processTerritory [ Child  Total_Economic_Activities__c (AFTER): ' + territory.Total_Economic_Activities__c  +  ']');

        // END: SUM of Economic Activities

    }
    
    private void resetTerritory(Territorio_Administrativo__c territory){
        
        //territory = new Territorio_Administrativo__c(Id = territory.Id, Nivel_Administrativo__c = territory.Nivel_Administrativo__c, ParentId__c = territory.ParentId__c);

        territory.Total_Emails__c = 0;
        territory.Etario_Baby_Boomers_Female__c = 0;
        territory.Etario_Baby_Boomers_Male__c = 0;
        territory.Etario_Baby_Boomers_Total__c = 0;
        territory.Etario_Centennials_Female__c = 0;
        territory.Etario_Centennials_Male__c = 0;
        territory.Etario_Centennials_Total__c = 0;
        territory.Etario_Generacion_Silenciosa_Total__c = 0;
        territory.Etario_Generacion_Silenciosa_Female__c = 0;
        territory.Etario_Generacion_Silenciosa_Male__c = 0;
        territory.Etario_Generacion_X_Female__c = 0;
        territory.Etario_Generacion_X_Male__c = 0;
        territory.Etario_Generacion_X_Total__c = 0;
        territory.Etario_Millennials_Female__c = 0;
        territory.Etario_Millennials_Male__c = 0;
        territory.Etario_Millennials_Total__c = 0;
        territory.Etario_Sub_16_Female__c = 0;
        territory.Etario_Sub_16_Male__c = 0;
        territory.Etario_Sub_16_Total__c = 0;
        territory.Total_Facebook__c = 0;
        territory.Total_Instagram__c = 0;
        territory.Total_Telefonos_FIjos__c = 0;
        territory.Total_Linkedin__c = 0;
        territory.Total_Moviles__c = 0;
        territory.Total_Number_of_00_15_year_olds__c = 0;
        territory.Total_Number_of_16_17_year_olds__c = 0;
        territory.Total_Number_of_65_year_olds__c = 0;
        territory.Total_Number_of_18_24_year_olds__c = 0;
        territory.Total_Number_of_25_39_year_olds__c = 0;
        territory.Total_Number_of_40_64_year_olds__c = 0;
        territory.Total_Number_of_Males__c = 0;
        territory.Total_Number_of_Females__c= 0;
        territory.Total_Ciudadanos__c = 0;
        territory.Total_Education_Level_University_Degree__c = 0;
        territory.Total_de_Hombres_de_0_a_15__c = 0;
        territory.Total_de_Hombres_de_16_a_17__c = 0;
        territory.Total_de_Hombres_de_18_a_24__c = 0;
        territory.Total_de_Hombres_de_25_a_39__c = 0;
        territory.Total_de_Hombres_de_40_a_64__c = 0;
        territory.Total_Education_Level_Primary__c = 0;
        territory.Total_Education_Level_Secondary__c = 0;
        territory.Total_Education_Level_Tertiary__c = 0;
        territory.Total_Hombres_de_65plus__c = 0;
        territory.Total_Income_Range_High__c = 0;
        territory.Total_Income_Range_Low__c = 0;
        territory.Total_Income_Range_Medium__c = 0;
        territory.Total_Income_Range_Very_High__c = 0;
        territory.Total_Income_Range_Very_Low__c = 0;
        territory.Total_Mujeres_de_65Plus__c = 0;
        territory.Total_Mujeres_de_0_a_15__c = 0;
        territory.Total_Mujeres_de_16_a_17__c = 0;
        territory.Total_Mujeres_de_18_a_24__c = 0;
        territory.Total_Mujeres_de_25_a_39__c = 0;
        territory.Total_Mujeres_de_40_a_64__c = 0;
        territory.Total_Occupation_Type_Not_Declared__c = 0;
        territory.Total_Occupation_Type_Retired__c = 0;
        territory.Total_Occupation_Type_Self_Employed__c = 0;
        territory.Total_Occupation_Type_Wage_Earned__c = 0;
        territory.Total_Twitter__c = 0;

        territory.Total_Economic_Activities__c = '';

    }

    private void initTerritory(Territorio_Administrativo__c territory, Set<String> territoriesId){
        resetTerritory(territory);

        territoriesId.add(territory.Id);

        if(territory.Nivel_Administrativo__c == 0){
            territories0.put(territory.Id, territory);
        } else if(territory.Nivel_Administrativo__c == 1){
            territories1.put(territory.Id, territory);
        } else if(territory.Nivel_Administrativo__c == 2){
            territories2.put(territory.Id, territory);
        } else if(territory.Nivel_Administrativo__c == 3){
            territories3.put(territory.Id, territory);
        } else if(territory.Nivel_Administrativo__c == 4){
            territories4.put(territory.Id, territory);
        }
    }
    
}