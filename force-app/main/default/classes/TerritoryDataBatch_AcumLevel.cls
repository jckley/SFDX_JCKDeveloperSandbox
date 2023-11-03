global class TerritoryDataBatch_AcumLevel implements Database.Batchable<sObject>,Database.Stateful {

    Integer lvl;
    public Boolean doChain;

    public TerritoryDataBatch_AcumLevel(Integer lvl) {
        this.lvl = lvl;
        this.doChain = true;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        //parent id != null porque en ese caso no agrupo a nada
        return Database.getQueryLocator([SELECT Id, ParentId__c,
                                            (SELECT id, Gender__c, Economic_Activities__c,
                                            Income_Range_High__c, Income_Range_Low__c, Income_Range_Medium__c,
                                            Income_Range_Very_High__c, Income_Range_Very_Low__c,
                                            Occupation_Not_Declared__c, Occupation_Retired__c, Occupation_Self_Employed__c,
                                            Occupation_Wage_Earned__c,
                                            Education_Level_Primary__c, Education_Level_Secondary__c, Education_Level_Tertiary__c,
                                            Education_Level_University_Degree__c
                                            FROM Territory_Data__r)
                                        FROM Territorio_Administrativo__c 
                                        WHERE Nivel_Administrativo__c =: this.lvl AND ParentId__c != null]);

    }

    global void execute(Database.BatchableContext BC, List<Territorio_Administrativo__c> scope){
        Map<String, TerritoryData_wrapper> tempParentTerritoryDataBy_ParentTerritoryWithGender = calculateTempValuesForThisParentsTerritories(scope);

        //aca se podria extraer algo, porque excepto el primer metodo, que en este caso acumula territorios a territorios
        //y en el otro batch acumula ciudadanos a territorios, todo el resto es igual.
        List<Datos_de_territorio__c> oldUpadatedTerritorieData = [
                                                                        SELECT id, TerritoryWithGenderKey__c, Gender__c,
                                                                        Income_Range_High__c, Income_Range_Low__c, Income_Range_Medium__c,
                                                                        Income_Range_Very_High__c, Income_Range_Very_Low__c,
                                                                        Occupation_Not_Declared__c, Occupation_Retired__c, Occupation_Self_Employed__c,
                                                                        Occupation_Wage_Earned__c,
                                                                        Education_Level_Primary__c, Education_Level_Secondary__c, Education_Level_Tertiary__c,
                                                                        Education_Level_University_Degree__c,
                                                                        Economic_Activities__c
                                                                        FROM Datos_de_territorio__c
                                                                        WHERE TerritoryWithGenderKey__c IN: tempParentTerritoryDataBy_ParentTerritoryWithGender.keySet()];

        
        List<Datos_de_territorio__c> newUpdate = addTempValuesToExistingOnes(tempParentTerritoryDataBy_ParentTerritoryWithGender,oldUpadatedTerritorieData);

        update newUpdate;

    }

    global void finish(Database.BatchableContext BC) {
        //llamar a este mismo batch, pero en el nivel inmediatamente superior TerritoryBatch_AcumLevel en this.lvl - 1,
        //siempre que this.lvl != 0
        if(this.doChain) {
            if(this.lvl != 0){
                TerritoryDataBatch_AcumLevel batch = new TerritoryDataBatch_AcumLevel(this.lvl-1);
                database.executeBatch(batch, 2000);
            }
        }
    }

    private Map<String, TerritoryData_wrapper> calculateTempValuesForThisParentsTerritories(List<Territorio_Administrativo__c> scope) {
        Map<String, TerritoryData_wrapper> tempParentTerritoryDataBy_ParentTerritoryWithGender = new Map<String, TerritoryData_wrapper> ();

        for(Territorio_Administrativo__c thisTerritory : scope){
            for(Datos_de_territorio__c thisTerritoryData : thisTerritory.Territory_Data__r){
                String keyFor_Parent_TerritoryData = thisTerritory.ParentId__c + thisTerritoryData.Gender__c.toUppercase();
                if(!tempParentTerritoryDataBy_ParentTerritoryWithGender.containsKey(keyFor_Parent_TerritoryData)){
                    tempParentTerritoryDataBy_ParentTerritoryWithGender.put(keyFor_Parent_TerritoryData, new TerritoryData_wrapper(thisTerritory.ParentId__c,thisTerritoryData.Gender__c));
                }

                TerritoryData_wrapper tempTerritoryDataWrapper = tempParentTerritoryDataBy_ParentTerritoryWithGender.get(keyFor_Parent_TerritoryData);

                tempTerritoryDataWrapper.acumNormalFields(thisTerritoryData);
                tempTerritoryDataWrapper.acumActivityCountAuxMap(thisTerritoryData);

            }
        }

        return tempParentTerritoryDataBy_ParentTerritoryWithGender;

    }

    private List<Datos_de_territorio__c> addTempValuesToExistingOnes(Map<String, TerritoryData_wrapper> tempTerritoryDataBy_TerritoryWithGender, List<Datos_de_territorio__c> oldUpadatedTerritorieData) {
        List<Datos_de_territorio__c> newUpdate = new List<Datos_de_territorio__c> ();
                                            
        for (Datos_de_territorio__c thisOldTerritoryData : oldUpadatedTerritorieData) {
            TerritoryData_wrapper tempTerritoryDataWrapper = tempTerritoryDataBy_TerritoryWithGender.get(thisOldTerritoryData.TerritoryWithGenderKey__c);

            Datos_de_territorio__c tempTerritoryAcum = tempTerritoryDataWrapper.territoryData;
            //copia los valores de los campos del sObject a otra direccion de memoria
            //de esa forma, se puede por ejemplo acumular con += sin modificar el "original"
            Datos_de_territorio__c newTerritoryData = thisOldTerritoryData.clone(true, false, false, false);

            newTerritoryData.Income_Range_High__c += tempTerritoryAcum.Income_Range_High__c;
            newTerritoryData.Income_Range_Low__c += tempTerritoryAcum.Income_Range_Low__c;
            newTerritoryData.Income_Range_Medium__c += tempTerritoryAcum.Income_Range_Medium__c;
            newTerritoryData.Income_Range_Very_High__c += tempTerritoryAcum.Income_Range_Very_High__c;
            newTerritoryData.Income_Range_Very_Low__c += tempTerritoryAcum.Income_Range_Very_Low__c;

            newTerritoryData.Occupation_Not_Declared__c += tempTerritoryAcum.Occupation_Not_Declared__c;
            newTerritoryData.Occupation_Retired__c += tempTerritoryAcum.Occupation_Retired__c;
            newTerritoryData.Occupation_Self_Employed__c += tempTerritoryAcum.Occupation_Self_Employed__c;
            newTerritoryData.Occupation_Wage_Earned__c += tempTerritoryAcum.Occupation_Wage_Earned__c;

            newTerritoryData.Education_Level_Primary__c += tempTerritoryAcum.Education_Level_Primary__c;
            newTerritoryData.Education_Level_Secondary__c += tempTerritoryAcum.Education_Level_Secondary__c;
            newTerritoryData.Education_Level_Tertiary__c += tempTerritoryAcum.Education_Level_Tertiary__c;
            newTerritoryData.Education_Level_University_Degree__c += tempTerritoryAcum.Education_Level_University_Degree__c;

            Map<String,Integer> tempActivityCount = tempTerritoryDataWrapper.activityCount;
            Map<String, Integer> newTerritoryActivityCount = (Map<String, Integer>) JSON.deserialize(newTerritoryData.Economic_Activities__c, Map<String, Integer>.class);

            for (String thisKey : tempActivityCount.keySet()) {
                if (!newTerritoryActivityCount.containsKey(thisKey)) {
                    newTerritoryActivityCount.put(thisKey,0);
                }
                Integer oldValue = newTerritoryActivityCount.get(thisKey);
                Integer newValue = oldValue + tempActivityCount.get(thisKey);
                newTerritoryActivityCount.put(thisKey,newValue);
            }

            newTerritoryData.Economic_Activities__c = JSON.serialize(newTerritoryActivityCount);

            newUpdate.add(newTerritoryData);
        }

        return newUpdate;
    }

    private class TerritoryData_wrapper {
        public Datos_de_territorio__c territoryData;
        public Map<String,Integer> activityCount;

        public territoryData_wrapper (String territorioAdministrativo, String gender) {
            Datos_de_territorio__c temp = new Datos_de_territorio__c ();

            temp.Gender__c = gender;
            temp.Territory__c = territorioAdministrativo;

            temp.Income_Range_Very_Low__c = 0;
            temp.Income_Range_Low__c = 0;
            temp.Income_Range_Medium__c = 0;
            temp.Income_Range_High__c = 0;
            temp.Income_Range_Very_High__c = 0;
    
            temp.Occupation_Wage_Earned__c = 0;
            temp.Occupation_Self_Employed__c = 0;
            temp.Occupation_Retired__c = 0;
            temp.Occupation_Not_Declared__c = 0;

            temp.Education_Level_Primary__c = 0;
            temp.Education_Level_Secondary__c = 0;
            temp.Education_Level_Tertiary__c = 0;
            temp.Education_Level_University_Degree__c = 0;
    
            temp.Economic_Activities__c = '{}';

            this.territoryData = temp;

            this.activityCount = new Map<String,Integer> ();
        }

        public void acumNormalFields (Datos_de_territorio__c territoryData){
            this.territoryData.Income_Range_Very_Low__c += territoryData.Income_Range_Very_Low__c;
            this.territoryData.Income_Range_Low__c += territoryData.Income_Range_Low__c;
            this.territoryData.Income_Range_Medium__c += territoryData.Income_Range_Medium__c;
            this.territoryData.Income_Range_High__c += territoryData.Income_Range_High__c;
            this.territoryData.Income_Range_Very_High__c += territoryData.Income_Range_Very_High__c;

            this.territoryData.Occupation_Wage_Earned__c += territoryData.Occupation_Wage_Earned__c;
            this.territoryData.Occupation_Self_Employed__c += territoryData.Occupation_Self_Employed__c;
            this.territoryData.Occupation_Retired__c += territoryData.Occupation_Retired__c;
            this.territoryData.Occupation_Not_Declared__c += territoryData.Occupation_Not_Declared__c;

            this.territoryData.Education_Level_Primary__c += territoryData.Education_Level_Primary__c;
            this.territoryData.Education_Level_Secondary__c += territoryData.Education_Level_Secondary__c;
            this.territoryData.Education_Level_Tertiary__c += territoryData.Education_Level_Tertiary__c;
            this.territoryData.Education_Level_University_Degree__c += territoryData.Education_Level_University_Degree__c;
        }

        public void acumActivityCountAuxMap (Datos_de_territorio__c territoryData) {
            if (String.isBlank(territoryData.Economic_Activities__c)) {
                return;
            }

            Map<String, Integer> childTerritoryActivityCount = (Map<String, Integer>) JSON.deserialize(territoryData.Economic_Activities__c, Map<String, Integer>.class);

            for(String thisActivity : childTerritoryActivityCount.keySet()){
                if(!this.activityCount.containsKey(thisActivity)){
                    this.activityCount.put(thisActivity,0);
                }
                Integer newValue = this.activityCount.get(thisActivity) + childTerritoryActivityCount.get(thisActivity);
                this.activityCount.put(thisActivity,newValue);
            }

        }

    }


}