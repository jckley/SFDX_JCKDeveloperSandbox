global class TerritoryBatch_AcumLevel implements Database.Batchable<sObject>,Database.Stateful {
    Integer lvl;
    public Boolean doChain;

    //pendiente agregar: 
    //acumular desde un nodo, por ahi, que dado ese nodo, ponga ahi y hacia abajo todos los valores en 0
    //y hacia arriba, recorra el arbol restando el valor a los existentes

    global TerritoryBatch_AcumLevel(Integer lvl) {
        this.lvl = lvl;
        this.doChain = true;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        //parent id != null porque en ese caso no agrupo a nada
        return Database.getQueryLocator([SELECT Id, ParentId__c,
                                                RiverId_Total_Ciudadanos__c, RiverId_Total_Number_of_Males__c, RiverId_Total_Number_of_Females__c,
                                                RiverId_Etario_Sub_16_Male__c, RiverId_Etario_Centennials_Male__c, RiverId_Etario_Millennials_Male__c,
                                                RiverId_Etario_Generacion_X_Male__c, RiverId_Etario_Baby_Boomers_Male__c, RiverId_Etario_Generacion_Silenciosa_M__c,
                                                RiverId_Etario_Sub_16_Female__c, RiverId_Etario_Centennials_Female__c, RiverId_Etario_Millennials_Female__c,
                                                RiverId_Etario_Generacion_X_Female__c, RiverId_Etario_Baby_Boomers_Female__c, RiverId_Etario_Generacion_Silenciosa_F__c,
                                                RiverId_TotInc_Very_Low__c, RiverId_TotInc_Low__c, RiverId_TotInc_Medium__c, RiverId_TotInc_High__c, RiverId_TotInc_Very_High__c,
                                                RiverId_TotOccu_Wage__c, RiverId_TotOccu_Self_Employed__c, RiverId_TotOccu_Retired__c, RiverId_TotOccu_Not_Declared__c,
                                                RiverId_Total_Edu_Primary__c, RiverId_Total_Edu_Secondary__c, RiverId_Total_Edu_Tertiary__c, RiverId_Total_Edu_University__c,
                                                RiverId_TotEco_Activities__c
                                        FROM Territorio_Administrativo__c 
                                        WHERE Nivel_Administrativo__c =: this.lvl AND ParentId__c != null]);

    }

    global void execute(Database.BatchableContext BC, List<Territorio_Administrativo__c> scope){
        Map<Id, Territory_Wrapper> tempParentTerritoryAcumById = calculateTempValuesForThisParentsTerritories(scope);

        //aca se podria extraer algo, porque excepto el primer metodo, que en este caso acumula territorios a territorios
        //y en el otro batch acumula ciudadanos a territorios, todo el resto es igual.
        List<Territorio_Administrativo__c> oldTerritories = [SELECT RiverId_Total_Ciudadanos__c, RiverId_Total_Number_of_Males__c, RiverId_Total_Number_of_Females__c,
                                                                    RiverId_Etario_Sub_16_Male__c, RiverId_Etario_Centennials_Male__c, RiverId_Etario_Millennials_Male__c,
                                                                    RiverId_Etario_Generacion_X_Male__c, RiverId_Etario_Baby_Boomers_Male__c, RiverId_Etario_Generacion_Silenciosa_M__c,
                                                                    RiverId_Etario_Sub_16_Female__c, RiverId_Etario_Centennials_Female__c, RiverId_Etario_Millennials_Female__c,
                                                                    RiverId_Etario_Generacion_X_Female__c, RiverId_Etario_Baby_Boomers_Female__c, RiverId_Etario_Generacion_Silenciosa_F__c,
                                                                    RiverId_TotInc_Very_Low__c, RiverId_TotInc_Low__c, RiverId_TotInc_Medium__c, RiverId_TotInc_High__c, RiverId_TotInc_Very_High__c,
                                                                    RiverId_TotOccu_Wage__c, RiverId_TotOccu_Self_Employed__c, RiverId_TotOccu_Retired__c, RiverId_TotOccu_Not_Declared__c,
                                                                    RiverId_Total_Edu_Primary__c, RiverId_Total_Edu_Secondary__c, RiverId_Total_Edu_Tertiary__c, RiverId_Total_Edu_University__c,
                                                                    RiverId_TotEco_Activities__c
                                                    FROM Territorio_Administrativo__c
                                                    WHERE id IN: tempParentTerritoryAcumById.keySet()];

        
        List<Territorio_Administrativo__c> newUpdate = addTempValuesToExistingOnes(tempParentTerritoryAcumById ,oldTerritories);
        
        update newUpdate;

    }

    global void finish(Database.BatchableContext BC) {
        //llamar a este mismo batch, pero en el nivel inmediatamente superior TerritoryBatch_AcumLevel en this.lvl - 1,
        //siempre que this.lvl != 0
        if(this.doChain) {
            if(this.lvl != 0){
                TerritoryBatch_AcumLevel batch = new TerritoryBatch_AcumLevel(this.lvl-1);
                database.executeBatch(batch, 2000);
            }
        }
    }

    private Map<Id, Territory_Wrapper> calculateTempValuesForThisParentsTerritories (List<Territorio_Administrativo__c> scope) {
        Map<Id, Territory_Wrapper> tempParentTerritoryAcumById = new Map<Id, Territory_Wrapper> ();

        for(Territorio_Administrativo__c thisTerritoy : scope){
            if (!tempParentTerritoryAcumById.containsKey(thisTerritoy.ParentId__c)) {
                tempParentTerritoryAcumById.put(thisTerritoy.ParentId__c, new Territory_Wrapper());
            }

            Territory_Wrapper tempTerritoryWrapper = tempParentTerritoryAcumById.get(thisTerritoy.ParentId__c);
            
            tempTerritoryWrapper.acumNormalFields(thisTerritoy);
            tempTerritoryWrapper.acumActivityCountAuxMap(thisTerritoy);

        }
        
        return tempParentTerritoryAcumById;
    }

    private List<Territorio_Administrativo__c> addTempValuesToExistingOnes(Map<Id, Territory_Wrapper> tempTerritoryAcumById, List<Territorio_Administrativo__c> oldTerritories) {
        List<Territorio_Administrativo__c> newUpdate = new List<Territorio_Administrativo__c> ();
                                            
        for (Territorio_Administrativo__c thisOldTerritory : oldTerritories) {
            Territory_wrapper tempTerritoryWrapper = tempTerritoryAcumById.get(thisOldTerritory.Id);
            Territorio_Administrativo__c tempTerritoryAcum = tempTerritoryWrapper.territory;
            //copia los valores de los campos del sObject a otra direccion de memoria
            //de esa forma, se puede por ejemplo acumular con += sin modificar el "original"
            Territorio_Administrativo__c territoryToUpdate = thisOldTerritory.clone(true, false, false, false);

            territoryToUpdate.RiverId_Total_Ciudadanos__c += tempTerritoryAcum.RiverId_Total_Ciudadanos__c;
            territoryToUpdate.RiverId_Total_Number_of_Males__c += tempTerritoryAcum.RiverId_Total_Number_of_Males__c;
            territoryToUpdate.RiverId_Total_Number_of_Females__c += tempTerritoryAcum.RiverId_Total_Number_of_Females__c;

            territoryToUpdate.RiverId_Etario_Sub_16_Male__c += tempTerritoryAcum.RiverId_Etario_Sub_16_Male__c;
            territoryToUpdate.RiverId_Etario_Centennials_Male__c += tempTerritoryAcum.RiverId_Etario_Centennials_Male__c;
            territoryToUpdate.RiverId_Etario_Millennials_Male__c += tempTerritoryAcum.RiverId_Etario_Millennials_Male__c;
            territoryToUpdate.RiverId_Etario_Generacion_X_Male__c += tempTerritoryAcum.RiverId_Etario_Generacion_X_Male__c;
            territoryToUpdate.RiverId_Etario_Baby_Boomers_Male__c += tempTerritoryAcum.RiverId_Etario_Baby_Boomers_Male__c;
            territoryToUpdate.RiverId_Etario_Generacion_Silenciosa_M__c += tempTerritoryAcum.RiverId_Etario_Generacion_Silenciosa_M__c;

            territoryToUpdate.RiverId_Etario_Sub_16_Female__c += tempTerritoryAcum.RiverId_Etario_Sub_16_Female__c;
            territoryToUpdate.RiverId_Etario_Centennials_Female__c += tempTerritoryAcum.RiverId_Etario_Centennials_Female__c;
            territoryToUpdate.RiverId_Etario_Millennials_Female__c += tempTerritoryAcum.RiverId_Etario_Millennials_Female__c;
            territoryToUpdate.RiverId_Etario_Generacion_X_Female__c += tempTerritoryAcum.RiverId_Etario_Generacion_X_Female__c;
            territoryToUpdate.RiverId_Etario_Baby_Boomers_Female__c += tempTerritoryAcum.RiverId_Etario_Baby_Boomers_Female__c;
            territoryToUpdate.RiverId_Etario_Generacion_Silenciosa_F__c += tempTerritoryAcum.RiverId_Etario_Generacion_Silenciosa_F__c;

            territoryToUpdate.RiverId_TotInc_Very_Low__c += tempTerritoryAcum.RiverId_TotInc_Very_Low__c;
            territoryToUpdate.RiverId_TotInc_Low__c += tempTerritoryAcum.RiverId_TotInc_Low__c;
            territoryToUpdate.RiverId_TotInc_Medium__c += tempTerritoryAcum.RiverId_TotInc_Medium__c;
            territoryToUpdate.RiverId_TotInc_High__c += tempTerritoryAcum.RiverId_TotInc_High__c;
            territoryToUpdate.RiverId_TotInc_Very_High__c += tempTerritoryAcum.RiverId_TotInc_Very_High__c;

            territoryToUpdate.RiverId_TotOccu_Wage__c += tempTerritoryAcum.RiverId_TotOccu_Wage__c;
            territoryToUpdate.RiverId_TotOccu_Self_Employed__c += tempTerritoryAcum.RiverId_TotOccu_Self_Employed__c;
            territoryToUpdate.RiverId_TotOccu_Retired__c += tempTerritoryAcum.RiverId_TotOccu_Retired__c;
            territoryToUpdate.RiverId_TotOccu_Not_Declared__c += tempTerritoryAcum.RiverId_TotOccu_Not_Declared__c;

            territoryToUpdate.RiverId_Total_Edu_Primary__c += tempTerritoryAcum.RiverId_Total_Edu_Primary__c;
            territoryToUpdate.RiverId_Total_Edu_Secondary__c += tempTerritoryAcum.RiverId_Total_Edu_Secondary__c;
            territoryToUpdate.RiverId_Total_Edu_Tertiary__c += tempTerritoryAcum.RiverId_Total_Edu_Tertiary__c;
            territoryToUpdate.RiverId_Total_Edu_University__c += tempTerritoryAcum.RiverId_Total_Edu_University__c;

            Map<String,Integer> tempActivityCount = tempTerritoryWrapper.activityCount;
            Map<String, Integer> territoryToUpdateActivityCount = (Map<String, Integer>) JSON.deserialize(territoryToUpdate.RiverId_TotEco_Activities__c, Map<String, Integer>.class);

            for (String thisKey : tempActivityCount.keySet()) {
                if (!territoryToUpdateActivityCount.containsKey(thisKey)) {
                    territoryToUpdateActivityCount.put(thisKey,0);
                }
                Integer oldValue = territoryToUpdateActivityCount.get(thisKey);
                Integer newValue = oldValue + tempActivityCount.get(thisKey);
                territoryToUpdateActivityCount.put(thisKey,newValue);
            }

            territoryToUpdate.RiverId_TotEco_Activities__c = JSON.serialize(territoryToUpdateActivityCount);
        
            newUpdate.add(territoryToUpdate);
        }

        return newUpdate;
    }

    private class Territory_Wrapper{
        public Territorio_Administrativo__c territory;
        public Map<String,Integer> activityCount;

        public territory_wrapper () {
            Territorio_Administrativo__c temp = new Territorio_Administrativo__c ();

            temp.RiverId_Total_Ciudadanos__c = 0;
            temp.RiverId_Total_Number_of_Males__c = 0;
            temp.RiverId_Total_Number_of_Females__c = 0;
    
            temp.RiverId_Etario_Sub_16_Male__c = 0;
            temp.RiverId_Etario_Centennials_Male__c=0;
            temp.RiverId_Etario_Millennials_Male__c = 0;
            temp.RiverId_Etario_Generacion_X_Male__c = 0;
            temp.RiverId_Etario_Baby_Boomers_Male__c = 0;
            temp.RiverId_Etario_Generacion_Silenciosa_M__c = 0;
    
            temp.RiverId_Etario_Sub_16_Female__c = 0;
            temp.RiverId_Etario_Centennials_Female__c = 0;
            temp.RiverId_Etario_Millennials_Female__c = 0;
            temp.RiverId_Etario_Generacion_X_Female__c = 0;
            temp.RiverId_Etario_Baby_Boomers_Female__c = 0;
            temp.RiverId_Etario_Generacion_Silenciosa_F__c = 0;
            
            temp.RiverId_TotInc_Very_Low__c = 0;
            temp.RiverId_TotInc_Low__c = 0;
            temp.RiverId_TotInc_Medium__c = 0;
            temp.RiverId_TotInc_High__c = 0;
            temp.RiverId_TotInc_Very_High__c = 0;
    
            temp.RiverId_TotOccu_Wage__c = 0;
            temp.RiverId_TotOccu_Self_Employed__c = 0;
            temp.RiverId_TotOccu_Retired__c = 0;
            temp.RiverId_TotOccu_Not_Declared__c = 0;
    
            temp.RiverId_Total_Edu_Primary__c = 0;
            temp.RiverId_Total_Edu_Secondary__c = 0;
            temp.RiverId_Total_Edu_Tertiary__c = 0;
            temp.RiverId_Total_Edu_University__c = 0;
    
            temp.RiverId_TotEco_Activities__c = '{}';

            this.territory = temp;

            this.activityCount = new Map<String,Integer> ();
        }

        public void acumNormalFields (Territorio_Administrativo__c childTerritory) {
            this.territory.RiverId_Total_Ciudadanos__c += childTerritory.RiverId_Total_Ciudadanos__c;
            this.territory.RiverId_Total_Number_of_Males__c += childTerritory.RiverId_Total_Number_of_Males__c;
            this.territory.RiverId_Total_Number_of_Females__c += childTerritory.RiverId_Total_Number_of_Females__c;
    
            this.territory.RiverId_Etario_Sub_16_Male__c += childTerritory.RiverId_Etario_Sub_16_Male__c;
            this.territory.RiverId_Etario_Centennials_Male__c+= childTerritory.RiverId_Etario_Centennials_Male__c;
            this.territory.RiverId_Etario_Millennials_Male__c += childTerritory.RiverId_Etario_Millennials_Male__c;
            this.territory.RiverId_Etario_Generacion_X_Male__c += childTerritory.RiverId_Etario_Generacion_X_Male__c;
            this.territory.RiverId_Etario_Baby_Boomers_Male__c += childTerritory.RiverId_Etario_Baby_Boomers_Male__c;
            this.territory.RiverId_Etario_Generacion_Silenciosa_M__c += childTerritory.RiverId_Etario_Generacion_Silenciosa_M__c;
    
            this.territory.RiverId_Etario_Sub_16_Female__c += childTerritory.RiverId_Etario_Sub_16_Female__c;
            this.territory.RiverId_Etario_Centennials_Female__c += childTerritory.RiverId_Etario_Centennials_Female__c;
            this.territory.RiverId_Etario_Millennials_Female__c += childTerritory.RiverId_Etario_Millennials_Female__c;
            this.territory.RiverId_Etario_Generacion_X_Female__c += childTerritory.RiverId_Etario_Generacion_X_Female__c;
            this.territory.RiverId_Etario_Baby_Boomers_Female__c += childTerritory.RiverId_Etario_Baby_Boomers_Female__c;
            this.territory.RiverId_Etario_Generacion_Silenciosa_F__c += childTerritory.RiverId_Etario_Generacion_Silenciosa_F__c;

            this.territory.RiverId_TotInc_Very_Low__c += childTerritory.RiverId_TotInc_Very_Low__c;
            this.territory.RiverId_TotInc_Low__c += childTerritory.RiverId_TotInc_Low__c;
            this.territory.RiverId_TotInc_Medium__c += childTerritory.RiverId_TotInc_Medium__c;
            this.territory.RiverId_TotInc_High__c += childTerritory.RiverId_TotInc_High__c;
            this.territory.RiverId_TotInc_Very_High__c += childTerritory.RiverId_TotInc_Very_High__c;

            this.territory.RiverId_TotOccu_Wage__c += childTerritory.RiverId_TotOccu_Wage__c;
            this.territory.RiverId_TotOccu_Self_Employed__c += childTerritory.RiverId_TotOccu_Self_Employed__c;
            this.territory.RiverId_TotOccu_Retired__c += childTerritory.RiverId_TotOccu_Retired__c;
            this.territory.RiverId_TotOccu_Not_Declared__c += childTerritory.RiverId_TotOccu_Not_Declared__c;

            this.territory.RiverId_Total_Edu_Primary__c += childTerritory.RiverId_Total_Edu_Primary__c;
            this.territory.RiverId_Total_Edu_Secondary__c += childTerritory.RiverId_Total_Edu_Secondary__c;
            this.territory.RiverId_Total_Edu_Tertiary__c += childTerritory.RiverId_Total_Edu_Tertiary__c;
            this.territory.RiverId_Total_Edu_University__c += childTerritory.RiverId_Total_Edu_University__c;
        }

        public void acumActivityCountAuxMap (Territorio_Administrativo__c childTerritory) {
            if (String.isBlank(childTerritory.RiverId_TotEco_Activities__c)) {
                return;
            }

            Map<String, Integer> childTerritoryActivityCount = (Map<String, Integer>) JSON.deserialize(childTerritory.RiverId_TotEco_Activities__c, Map<String, Integer>.class);

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