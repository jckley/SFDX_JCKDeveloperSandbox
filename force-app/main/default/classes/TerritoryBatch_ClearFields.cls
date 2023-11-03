global class TerritoryBatch_ClearFields implements Database.Batchable<sObject>,Database.Stateful {

    public Boolean doChain;

    global TerritoryBatch_ClearFields() {
        this.doChain = true;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator([SELECT Id FROM Territorio_Administrativo__c]);

    }

    global void execute(Database.BatchableContext BC, List<Territorio_Administrativo__c> scope){
        List<Territorio_Administrativo__c> territoriosToUpdate = new List<Territorio_Administrativo__c>();
        for(Territorio_Administrativo__c thisTerritorio : scope){
            Territorio_Administrativo__c temTerritory = new Territorio_Administrativo__c();
            temTerritory.id = thisTerritorio.id;
            temTerritory.RiverId_Etario_Sub_16_Male__c = 0;
            temTerritory.RiverId_Etario_Centennials_Male__c = 0;
            temTerritory.RiverId_Etario_Millennials_Male__c = 0;
            temTerritory.RiverId_Etario_Generacion_X_Male__c = 0;
            temTerritory.RiverId_Etario_Baby_Boomers_Male__c = 0;
            temTerritory.RiverId_Etario_Generacion_Silenciosa_M__c = 0;

            temTerritory.RiverId_Etario_Sub_16_Female__c = 0;
            temTerritory.RiverId_Etario_Centennials_Female__c = 0;
            temTerritory.RiverId_Etario_Millennials_Female__c = 0;
            temTerritory.RiverId_Etario_Generacion_X_Female__c = 0;
            temTerritory.RiverId_Etario_Baby_Boomers_Female__c = 0;
            temTerritory.RiverId_Etario_Generacion_Silenciosa_F__c = 0;

            temTerritory.RiverId_Total_Ciudadanos__c = 0;
            temTerritory.RiverId_Total_Number_of_Males__c = 0;
            temTerritory.RiverId_Total_Number_of_Females__c = 0;
            
            temTerritory.RiverId_TotInc_Very_Low__c = 0;
            temTerritory.RiverId_TotInc_Low__c = 0;
            temTerritory.RiverId_TotInc_Medium__c = 0;
            temTerritory.RiverId_TotInc_High__c = 0;
            temTerritory.RiverId_TotInc_Very_High__c = 0;

            temTerritory.RiverId_TotOccu_Wage__c = 0;
            temTerritory.RiverId_TotOccu_Self_Employed__c = 0;
            temTerritory.RiverId_TotOccu_Retired__c = 0;
            temTerritory.RiverId_TotOccu_Not_Declared__c = 0;

            temTerritory.RiverId_Total_Edu_Primary__c = 0;
            temTerritory.RiverId_Total_Edu_Secondary__c = 0;
            temTerritory.RiverId_Total_Edu_Tertiary__c = 0;
            temTerritory.RiverId_Total_Edu_University__c = 0;

            temTerritory.RiverId_TotEco_Activities__c = '{}';

            territoriosToUpdate.add(temTerritory);
        }

        Update territoriosToUpdate;
    }

    global void finish(Database.BatchableContext BC) {
        //call batch que empieze a actualizar los territorios a los que los citizens pertenezcan. TerritoryBatch_AcumCitizens
        if(this.doChain) {
            TerritoryBatch_AcumCitizens batch = new TerritoryBatch_AcumCitizens();
            database.executeBatch(batch, 2000);
        }
    }


}