global class TerritoryDataBatch_ClearFileds implements Database.Batchable<sObject>,Database.Stateful {
    public Boolean doChain;

    global TerritoryDataBatch_ClearFileds() {
        this.doChain = true;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator([SELECT Id, (SELECT id, gender__c FROM Territory_Data__r) FROM Territorio_Administrativo__c]);

    }

    global void execute(Database.BatchableContext BC, List<Territorio_Administrativo__c> scope){
        Set<Id> territoryDataRecordsToClearIds = new Set<Id> ();

        insertMissingTerritoryData(scope);

        clearOldTerritoryData(scope);

    }

    global void finish(Database.BatchableContext BC) {
        //call batch que empieze a actualizar los territorios a los que los citizens pertenezcan. TerritoryBatch_AcumCitizens
        if(this.doChain) {
            List<id> argentinaLvl2TerritoriesIds = TerritoryDataBatch_AcumCitizens.getSetOfLevel2ZonesForArgentina();
            TerritoryDataBatch_AcumCitizens batch = new TerritoryDataBatch_AcumCitizens(argentinaLvl2TerritoriesIds);
            database.executeBatch(batch, 2000);
        }
    }

    private static void insertMissingTerritoryData (List<Territorio_Administrativo__c> scope) {
        Map<Id, List<String>> missingTerritoryDataByTerritoryId = new Map<Id, List<String>> ();
        //put(territoryId,['M','F']) en caso que falten los 2

        for(Territorio_Administrativo__c thisTerritory : scope) {
            List<String> thisTerritoryMissingData = getMissingGenders(thisTerritory);

            if(thisTerritoryMissingData.size() != 0){
                missingTerritoryDataByTerritoryId.put(thisTerritory.id,thisTerritoryMissingData);
            }

        }


        if(!missingTerritoryDataByTerritoryId.isEmpty()){
            List<Datos_de_territorio__c> territoryDataToInsert = new List<Datos_de_territorio__c> ();

            for(Id thisId : missingTerritoryDataByTerritoryId.keySet()){
                List<String> missingDataGenders = missingTerritoryDataByTerritoryId.get(thisId);
                if(missingDataGenders.contains('M')){
                    territoryDataToInsert.add(
                        new Datos_de_territorio__c(
                            Territory__c = thisId,
                            gender__c = 'M'
                        )
                    );
                }

                if(missingDataGenders.contains('F')){
                    territoryDataToInsert.add(
                        new Datos_de_territorio__c(
                            Territory__c = thisId,
                            gender__c = 'F'
                        )
                    );
                }
            }

            insert territoryDataToInsert;
        }
    }

    private static List<String> getMissingGenders (Territorio_Administrativo__c territory) {
        List<String> missingGenders = new List<String> ();
        Boolean maleMissing = true;
        Boolean femaleMissing = true;

        if(territory.Territory_Data__r.size() == 0){
            missingGenders.add('M');
            missingGenders.add('F');
            return missingGenders;
        }

        for(Datos_de_territorio__c thisData : territory.Territory_Data__r){
            if(thisData.Gender__c == 'M'){
                maleMissing = false;
            }
            if(thisData.Gender__c == 'F'){
                femaleMissing = false;
            }
        }
        if(maleMissing){
            missingGenders.add('M');
        }
        if(femaleMissing){
            missingGenders.add('F');
        }
        return missingGenders;
    }

    private static void clearOldTerritoryData (List<Territorio_Administrativo__c> scope) {
        List<Datos_de_territorio__c> territoryDataToClear = new List<Datos_de_territorio__c>();

        for(Territorio_Administrativo__c thisTerritorio : scope){
            for(Datos_de_territorio__c thisTerritoryData : thisTerritorio.Territory_Data__r){
                territoryDataToClear.add(getClearTerritoryDataRecord(thisTerritoryData));
            }
        }
        if(territoryDataToClear.size() != 0){
            Update territoryDataToClear;
        }
    }

    private static Datos_de_territorio__c getClearTerritoryDataRecord (Datos_de_territorio__c recordToClear) {
        //me aseguro de mantener el genero, lookup, id y cosas asi si modificar en memoria el objeto en scope 
        Datos_de_territorio__c clearedRecord = recordToClear.clone(true, false, false, false);
        
        clearedRecord.Economic_Activities__c = '{}';

        clearedRecord.Income_Range_High__c = 0;
        clearedRecord.Income_Range_Low__c = 0;
        clearedRecord.Income_Range_Medium__c = 0;
        clearedRecord.Income_Range_Very_High__c = 0;
        clearedRecord.Income_Range_Very_Low__c = 0;

        clearedRecord.Occupation_Not_Declared__c = 0;
        clearedRecord.Occupation_Retired__c = 0;
        clearedRecord.Occupation_Self_Employed__c = 0;
        clearedRecord.Occupation_Wage_Earned__c = 0;

        clearedRecord.Education_Level_Primary__c = 0;
        clearedRecord.Education_Level_Secondary__c = 0;
        clearedRecord.Education_Level_Tertiary__c = 0;
        clearedRecord.Education_Level_University_Degree__c = 0;

        return clearedRecord;
    }
}