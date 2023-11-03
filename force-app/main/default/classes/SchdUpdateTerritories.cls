global with sharing class SchdUpdateTerritories implements Schedulable{

    private String levelOName;

    global SchdUpdateTerritories(String levelOName){
        this.levelOName = levelOName;
    }

    global void execute(SchedulableContext ctx) {
    	runUpdate(2, levelOName);
    }

    global static void start(String levelOName){
        start('20', 'SUN', levelOName);
    }

    global static void start(String hour, String day, String levelOName){
        System.schedule('Update Territories', '0 0 ' + hour + ' ? * ' + day, new SchdUpdateTerritories(levelOName));
    }

    global static void runUpdate(Integer adminLevel, String levelOName){

        resetParentsTerritories(adminLevel-1, levelOName);
        
        List<Territorio_Administrativo__c> territories = new List<Territorio_Administrativo__c>();

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
                                    FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c = :adminLevel AND Level0Name__c = :levelOName]){
            
            territories.add(territory);

            if(territories.size() == 10){
                BatchUpdateTerritories batch = new BatchUpdateTerritories(territories, adminLevel, levelOName, true);
    	        database.executeBatch(batch, 2000);
                territories.clear();
            }
        }

        if(!territories.isEmpty()){
            BatchUpdateTerritories batch = new BatchUpdateTerritories(territories, adminLevel, levelOName, true);
            database.executeBatch(batch, 2000);
        }
        
    }
    
    private static void resetParentsTerritories(Integer adminLevel, String levelOName){

        List<Territorio_Administrativo__c> territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c, Total_Emails__c, Total_Ciudadanos__c, Total_Facebook__c, Total_Instagram__c, Total_Telefonos_FIjos__c, Total_Linkedin__c,
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
                                                                FROM Territorio_Administrativo__c WHERE Nivel_Administrativo__c <= :adminLevel AND Level0Name__c = :levelOName];

                                                        


        for(Territorio_Administrativo__c territory : territories){
            resetTerritory(territory);
        }

        update territories;

        BatchUpdateTerritories batch = new BatchUpdateTerritories(territories, adminLevel, levelOName);
        database.executeBatch(batch, 2000);

    }

    private static void resetTerritory(Territorio_Administrativo__c territory){
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
}