global class TerritoryBatch_AcumCitizens implements Database.Batchable<sObject>,Database.Stateful {
    public Boolean doChain;

    global TerritoryBatch_AcumCitizens() {
        this.doChain = true;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT Id, Gender__c, Birthdate, Territorio_Administrativo__c, Ingreso__c, Education_Level__c, Condicion_de_ingreso__c, actividades_economicas__c
            FROM Contact 
            WHERE Is_RiverId_Citizen__c = true
            ORDER BY Territorio_Administrativo__c]);

        /* en caso de querer pasarle query strings:

        String query = 'SELECT Id, Gender__c, Birthdate, Territorio_Administrativo__c ' + 
                'FROM Contact ' +
                'WHERE Is_RiverId_Citizen__c = true AND Administrative_Level_3__c = \'La Plata\'';
        
        return Database.getQueryLocator(query);

        */
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){
        Map<Id, Territory_wrapper> tempTerritoryAcumById = calculateTempValuesForThisCitizens(scope);

        //aca los campos tienen que venir no nulos de la vase de datos. Ya sea por el batch anterior, o por el valor default configurado en el object manager
        List<Territorio_Administrativo__c> oldUpadatedTerritories = [SELECT RiverId_Total_Ciudadanos__c, RiverId_Total_Number_of_Males__c, RiverId_Total_Number_of_Females__c,
                                                    RiverId_Etario_Sub_16_Male__c, RiverId_Etario_Centennials_Male__c, RiverId_Etario_Millennials_Male__c,
                                                    RiverId_Etario_Generacion_X_Male__c, RiverId_Etario_Baby_Boomers_Male__c, RiverId_Etario_Generacion_Silenciosa_M__c,
                                                    RiverId_Etario_Sub_16_Female__c, RiverId_Etario_Centennials_Female__c, RiverId_Etario_Millennials_Female__c,
                                                    RiverId_Etario_Generacion_X_Female__c, RiverId_Etario_Baby_Boomers_Female__c, RiverId_Etario_Generacion_Silenciosa_F__c,
                                                    RiverId_TotInc_Very_Low__c, RiverId_TotInc_Low__c, RiverId_TotInc_Medium__c, RiverId_TotInc_High__c, RiverId_TotInc_Very_High__c,
                                                    RiverId_TotOccu_Wage__c, RiverId_TotOccu_Self_Employed__c, RiverId_TotOccu_Retired__c, RiverId_TotOccu_Not_Declared__c,
                                                    RiverId_Total_Edu_Primary__c, RiverId_Total_Edu_Secondary__c, RiverId_Total_Edu_Tertiary__c, RiverId_Total_Edu_University__c,
                                                    RiverId_TotEco_Activities__c
                                                    FROM Territorio_Administrativo__c
                                                    WHERE id IN: tempTerritoryAcumById.keySet()];

        List<Territorio_Administrativo__c> newUpdate = addTempValuesToExistingOnes(tempTerritoryAcumById,oldUpadatedTerritories);
        
        update newUpdate;

    }

    global void finish(Database.BatchableContext BC) {
        //call batch que empieze a acumular territorios TerritoryBatch_AcumLevel con el territorio de "mas abajo"
        if(this.doChain) {
            TerritoryBatch_AcumLevel batch = new TerritoryBatch_AcumLevel(4);
            database.executeBatch(batch, 2000);
        }
    }

    private Map<Id, Territory_wrapper> calculateTempValuesForThisCitizens (List<Contact> scope) {
        Map<Id, Territory_wrapper> tempTerritoryById = new Map<Id, Territory_wrapper> ();

        for(Contact thisCitizen : scope){
            if (!tempTerritoryById.containsKey(thisCitizen.Territorio_Administrativo__c)) {
                tempTerritoryById.put(thisCitizen.Territorio_Administrativo__c, new Territory_wrapper());
            }

            Territory_wrapper tempTerritoryAcum = tempTerritoryById.get(thisCitizen.Territorio_Administrativo__c);

            tempTerritoryAcum.acumIngreso(thisCitizen);
            tempTerritoryAcum.acumEducacion(thisCitizen);
            tempTerritoryAcum.acumGeneroYEdad(thisCitizen);
            tempTerritoryAcum.acumOcupacion(thisCitizen);
            tempTerritoryAcum.acumActividadesEconomicas(thisCitizen);
            tempTerritoryAcum.acumTotalCitizenCount();
            
        }

        return tempTerritoryById;
    }

    private List<Territorio_Administrativo__c> addTempValuesToExistingOnes(Map<Id, Territory_wrapper> tempTerritoryAcumById, List<Territorio_Administrativo__c> oldUpadatedTerritories) {
        List<Territorio_Administrativo__c> newUpdate = new List<Territorio_Administrativo__c> ();
                                            
        for (Territorio_Administrativo__c thisOldTerritory : oldUpadatedTerritories) {
            Territory_wrapper tempTerritoryWrapper = tempTerritoryAcumById.get(thisOldTerritory.Id);
            Territorio_Administrativo__c tempTerritoryAcum = tempTerritoryWrapper.territory;
            //copia los valores de los campos del sObject a otra direccion de memoria
            //de esa forma, se puede por ejemplo acumular con += sin modificar el "original"
            Territorio_Administrativo__c newTerritory = thisOldTerritory.clone(true, false, false, false);

            newTerritory.RiverId_Total_Ciudadanos__c += tempTerritoryAcum.RiverId_Total_Ciudadanos__c;
            newTerritory.RiverId_Total_Number_of_Males__c += tempTerritoryAcum.RiverId_Total_Number_of_Males__c;
            newTerritory.RiverId_Total_Number_of_Females__c += tempTerritoryAcum.RiverId_Total_Number_of_Females__c;

            newTerritory.RiverId_Etario_Sub_16_Male__c += tempTerritoryAcum.RiverId_Etario_Sub_16_Male__c;
            newTerritory.RiverId_Etario_Centennials_Male__c += tempTerritoryAcum.RiverId_Etario_Centennials_Male__c;
            newTerritory.RiverId_Etario_Millennials_Male__c += tempTerritoryAcum.RiverId_Etario_Millennials_Male__c;
            newTerritory.RiverId_Etario_Generacion_X_Male__c += tempTerritoryAcum.RiverId_Etario_Generacion_X_Male__c;
            newTerritory.RiverId_Etario_Baby_Boomers_Male__c += tempTerritoryAcum.RiverId_Etario_Baby_Boomers_Male__c;
            newTerritory.RiverId_Etario_Generacion_Silenciosa_M__c += tempTerritoryAcum.RiverId_Etario_Generacion_Silenciosa_M__c;

            newTerritory.RiverId_Etario_Sub_16_Female__c += tempTerritoryAcum.RiverId_Etario_Sub_16_Female__c;
            newTerritory.RiverId_Etario_Centennials_Female__c += tempTerritoryAcum.RiverId_Etario_Centennials_Female__c;
            newTerritory.RiverId_Etario_Millennials_Female__c += tempTerritoryAcum.RiverId_Etario_Millennials_Female__c;
            newTerritory.RiverId_Etario_Generacion_X_Female__c += tempTerritoryAcum.RiverId_Etario_Generacion_X_Female__c;
            newTerritory.RiverId_Etario_Baby_Boomers_Female__c += tempTerritoryAcum.RiverId_Etario_Baby_Boomers_Female__c;
            newTerritory.RiverId_Etario_Generacion_Silenciosa_F__c += tempTerritoryAcum.RiverId_Etario_Generacion_Silenciosa_F__c;

            newTerritory.RiverId_TotInc_Very_Low__c += tempTerritoryAcum.RiverId_TotInc_Very_Low__c;
            newTerritory.RiverId_TotInc_Low__c += tempTerritoryAcum.RiverId_TotInc_Low__c;
            newTerritory.RiverId_TotInc_Medium__c += tempTerritoryAcum.RiverId_TotInc_Medium__c;
            newTerritory.RiverId_TotInc_High__c += tempTerritoryAcum.RiverId_TotInc_High__c;
            newTerritory.RiverId_TotInc_Very_High__c += tempTerritoryAcum.RiverId_TotInc_Very_High__c;

            newTerritory.RiverId_TotOccu_Wage__c += tempTerritoryAcum.RiverId_TotOccu_Wage__c;
            newTerritory.RiverId_TotOccu_Self_Employed__c += tempTerritoryAcum.RiverId_TotOccu_Self_Employed__c;
            newTerritory.RiverId_TotOccu_Retired__c += tempTerritoryAcum.RiverId_TotOccu_Retired__c;
            newTerritory.RiverId_TotOccu_Not_Declared__c += tempTerritoryAcum.RiverId_TotOccu_Not_Declared__c;

            newTerritory.RiverId_Total_Edu_Primary__c += tempTerritoryAcum.RiverId_Total_Edu_Primary__c;
            newTerritory.RiverId_Total_Edu_Secondary__c += tempTerritoryAcum.RiverId_Total_Edu_Secondary__c;
            newTerritory.RiverId_Total_Edu_Tertiary__c += tempTerritoryAcum.RiverId_Total_Edu_Tertiary__c;
            newTerritory.RiverId_Total_Edu_University__c += tempTerritoryAcum.RiverId_Total_Edu_University__c;

            Map<String,Integer> tempActivityCount = tempTerritoryWrapper.activityCount;
            Map<String, Integer> newTerritoryActivityCount = (Map<String, Integer>) JSON.deserialize(newTerritory.RiverId_TotEco_Activities__c, Map<String, Integer>.class);

            for (String thisKey : tempActivityCount.keySet()) {
                if (!newTerritoryActivityCount.containsKey(thisKey)) {
                    newTerritoryActivityCount.put(thisKey,0);
                }
                Integer oldValue = newTerritoryActivityCount.get(thisKey);
                Integer newValue = oldValue + tempActivityCount.get(thisKey);
                newTerritoryActivityCount.put(thisKey,newValue);
            }

            newTerritory.RiverId_TotEco_Activities__c = JSON.serialize(newTerritoryActivityCount);

            newUpdate.add(newTerritory);
        }

        return newUpdate;
    }

    private class Territory_wrapper {
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

        public void acumIngreso (Contact thisCitizen) {
            String ingreso = thisCitizen.Ingreso__c;

            if(ingreso == 'Muy Bajo'){
                this.territory.RiverId_TotInc_Very_Low__c ++;
            }
            if(ingreso == 'Bajo'){
                this.territory.RiverId_TotInc_Low__c ++;
            }
            if(ingreso == 'Medio'){
                this.territory.RiverId_TotInc_Medium__c ++;
            }
            if(ingreso == 'Alto'){
                this.territory.RiverId_TotInc_High__c ++;
            }
            if(ingreso == 'Muy Alto'){
                this.territory.RiverId_TotInc_Very_High__c ++;
            }
        }

        public void acumEducacion (Contact thisCitizen) {
            String educacion = thisCitizen.Education_Level__c;

            if(educacion != null){
                if(educacion.toUpperCase().contains('PRIMARIO')){
                    this.territory.RiverId_Total_Edu_Primary__c ++;
                }
                if(educacion.toUpperCase().contains('SECUNDARIO')){
                    this.territory.RiverId_Total_Edu_Secondary__c ++;
                }
                if(educacion.toUpperCase().contains('TERCIARIO')){
                    this.territory.RiverId_Total_Edu_Tertiary__c ++;
                }
                if(educacion.toUpperCase().contains('UNIVERSITARIO')){
                    this.territory.RiverId_Total_Edu_University__c ++;
                } 
            }
        }

        public void acumGeneroYEdad (Contact thisCitizen) {

            Boolean isMale = thisCitizen.Gender__c.toUpperCase().equals('M');
            Boolean isFemale = thisCitizen.Gender__c.toUpperCase().equals('F');
            Integer year = thisCitizen.Birthdate.year();
            String rangoEtario;

            final String BABY_BOOMERS = 'BABY_BOOMERS';
            final String CENTENNIALS = 'CENTENNIALS';
            final String GENERACION_X = 'GENERACION_X';
            final String GENERACION_SILENCIOSA = 'GENERACION_SILENCIOSA';
            final String MILLENIALS = 'MILLENIALS';
            final String SUB_16 = 'SUB_16';

            
            
            if(year <= 1948){
                rangoEtario = GENERACION_SILENCIOSA;
            }

            if(year <= 1964 && year > 1948){
                rangoEtario = BABY_BOOMERS;
            }

            if(year <= 1979 && year > 1964){
                rangoEtario = GENERACION_X;
            }

            if(year <= 1994 && year > 1979){
                rangoEtario = MILLENIALS;
            }

            if(year <= 2004 && year > 1994){
                rangoEtario = CENTENNIALS;
            }
            
            if(year > 2004){
                rangoEtario = SUB_16;
            }

            if (isMale) {
                this.territory.RiverId_Total_Number_of_Males__c ++;
            }
            if(isMale && rangoEtario.equals(GENERACION_SILENCIOSA)){
                this.territory.RiverId_Etario_Generacion_Silenciosa_M__c ++;
            }
            if(isMale && rangoEtario.equals(BABY_BOOMERS)){
                this.territory.RiverId_Etario_Baby_Boomers_Male__c ++;
            }
            if(isMale && rangoEtario.equals(GENERACION_X)){
                this.territory.RiverId_Etario_Generacion_X_Male__c ++;
            } 
            if(isMale && rangoEtario.equals(MILLENIALS)){
                this.territory.RiverId_Etario_Millennials_Male__c ++;
            }
            if(isMale && rangoEtario.equals(CENTENNIALS)){
                this.territory.RiverId_Etario_Centennials_Male__c ++;
            }
            if(isMale && rangoEtario.equals(SUB_16)) {
                this.territory.RiverId_Etario_Sub_16_Male__c ++;
            }


            if(isFemale){
                    this.territory.RiverId_Total_Number_of_Females__c ++;
            }
            if(isFemale && rangoEtario.equals(GENERACION_SILENCIOSA)){
                this.territory.RiverId_Etario_Generacion_Silenciosa_F__c ++;
            }
            if(isFemale && rangoEtario.equals(BABY_BOOMERS)){
                this.territory.RiverId_Etario_Baby_Boomers_Female__c ++;
            }
            if(isFemale && rangoEtario.equals(GENERACION_X)){
                this.territory.RiverId_Etario_Generacion_X_Female__c ++;
            }
            if(isFemale && rangoEtario.equals(MILLENIALS)){
                this.territory.RiverId_Etario_Millennials_Female__c ++;
            }
            if(isFemale && rangoEtario.equals(CENTENNIALS)){
                this.territory.RiverId_Etario_Centennials_Female__c ++;
            }
            if(isFemale && rangoEtario.equals(SUB_16)){
                this.territory.RiverId_Etario_Sub_16_Female__c ++;
            }
            
        }

        public void acumTotalCitizenCount () {
            this.territory.RiverId_Total_Ciudadanos__c ++;
        }

        public void acumOcupacion (Contact thisCitizen) {
            String ocupacion = thisCitizen.Condicion_de_ingreso__c;

            if(ocupacion == null){
                this.territory.RiverId_TotOccu_Not_Declared__c ++;
                return;
            }
            if(ocupacion.contains('Asalariado')){
                this.territory.RiverId_TotOccu_Wage__c ++;
            }
            
            if(ocupacion.contains('Cuenta propia') || 
                ocupacion.contains('Cooperativas y precaria')
            ){
                this.territory.RiverId_TotOccu_Self_Employed__c ++;
            }

            if(ocupacion.contains('Jubilados y pensionados')){
                this.territory.RiverId_TotOccu_Retired__c ++;
            }
        }

        public void acumActividadesEconomicas (Contact thisCitizen) {
            if (String.isBlank(thisCitizen.actividades_economicas__c)) {
                return;
            }

            List<String> lstActividadesEconomicas = thisCitizen.actividades_economicas__c.split(';');

            for (String thisActivity : lstActividadesEconomicas) {

                if(!this.activityCount.containsKey(thisActivity)){
                    this.activityCount.put(thisActivity,0);
                }
                Integer oldValue = this.activityCount.get(thisActivity);

                this.activityCount.put(thisActivity, oldValue + 1);
            }
        }
    }
}