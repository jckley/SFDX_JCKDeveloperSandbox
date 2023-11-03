global class TerritoryDataBatch_AcumCitizens implements Database.Batchable<sObject>, Database.Stateful {
  public Boolean doChain;
  public List<Id> lvl2TerritoriesDivition;
  public Boolean lastIteration;

  global TerritoryDataBatch_AcumCitizens() {
    this.lastIteration = false;
    this.doChain = true;
    this.lvl2TerritoriesDivition = new List<Id>();
  }

  global TerritoryDataBatch_AcumCitizens(List<Id> lvl2TerritoriesDivition) {
    this.lastIteration = false;
    this.doChain = true;
    this.lvl2TerritoriesDivition = lvl2TerritoriesDivition;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    //queda al menos un territorio a procesar en este batch
    if (lvl2TerritoriesDivition.size() > 0) {
      //remove modifica la lista y devuelve el valor eliminado.
      Id territoryToWorkId = this.lvl2TerritoriesDivition.remove(0);

      List<Id> thisTerritoryWithSubTerritories = getSetOfThisIdPlusChildsIds_ForLvl2Territory(territoryToWorkId);
      
      return Database.getQueryLocator(
        [
          SELECT
            Id,
            Gender__c,
            Birthdate,
            Territorio_Administrativo__c,
            Ingreso__c,
            Education_Level__c,
            Condicion_de_ingreso__c,
            actividades_economicas__c
          FROM Contact
          WHERE Territorio_Administrativo__c IN :thisTerritoryWithSubTerritories
        ]
      );
    }

    //terminados los citizens de territorios de nivel 2 o menos, procesamos los de nivel 1 o 2 y se pasa al proximo batch:
    this.lastIteration = true;
    List<Id> otherArgTerritoriesIds = getSetOfLvl1AndLvl0TerritoriesFromArgentina();
    return Database.getQueryLocator(
        [
          SELECT
            Id,
            Gender__c,
            Birthdate,
            Territorio_Administrativo__c,
            Ingreso__c,
            Education_Level__c,
            Condicion_de_ingreso__c,
            actividades_economicas__c
          FROM Contact
          WHERE Territorio_Administrativo__c IN :otherArgTerritoriesIds
        ]
      );

  }

  global void execute(Database.BatchableContext BC, List<Contact> scope) {
    System.debug('Entro a execute con un scope de: ' + scope.size());
    Map<String, TerritoryData_wrapper> tempTerritoryAcumBy_TerritoryWithGender = calculateTempValuesForThisCitizens(
      scope
    );
    
    System.debug('Creo algun wrapper temporario?: ' + tempTerritoryAcumBy_TerritoryWithGender.keySet().size());

    List<Datos_de_territorio__c> oldUpadatedTerritorieData = [
      SELECT
        id,
        TerritoryWithGenderKey__c,
        Gender__c,
        Income_Range_High__c,
        Income_Range_Low__c,
        Income_Range_Medium__c,
        Income_Range_Very_High__c,
        Income_Range_Very_Low__c,
        Occupation_Not_Declared__c,
        Occupation_Retired__c,
        Occupation_Self_Employed__c,
        Occupation_Wage_Earned__c,
        Education_Level_Primary__c,
        Education_Level_Secondary__c,
        Education_Level_Tertiary__c,
        Education_Level_University_Degree__c,
        Economic_Activities__c
      FROM Datos_de_territorio__c
      WHERE
        TerritoryWithGenderKey__c IN :tempTerritoryAcumBy_TerritoryWithGender.keySet()
    ];

    System.debug('territorios originales (deberian estar en 0): ' + oldUpadatedTerritorieData.size());
    if(oldUpadatedTerritorieData.size() > 0){
      System.debug('chusmeo un territory data si existe: ' + oldUpadatedTerritorieData[0].Occupation_Not_Declared__c);
      System.debug('chusmeo un territory data si existe: ' + oldUpadatedTerritorieData[0].Occupation_Retired__c);
      System.debug('chusmeo un territory data si existe: ' + oldUpadatedTerritorieData[0].Education_Level_Primary__c);
      System.debug('chusmeo un territory data si existe: ' + oldUpadatedTerritorieData[0].Occupation_Wage_Earned__c);
    }

    List<Datos_de_territorio__c> newUpdate = addTempValuesToExistingOnes(
      tempTerritoryAcumBy_TerritoryWithGender,
      oldUpadatedTerritorieData
    );
    System.debug('voy a updatear: ' + newUpdate.size());
    if(newUpdate.size() > 0){
      System.debug('chusmeo un territory data si existe: ' + newUpdate[0].Occupation_Not_Declared__c);
      System.debug('chusmeo un territory data si existe: ' + newUpdate[0].Occupation_Retired__c);
      System.debug('chusmeo un territory data si existe: ' + newUpdate[0].Education_Level_Primary__c);
      System.debug('chusmeo un territory data si existe: ' + newUpdate[0].Occupation_Wage_Earned__c);
    }
    
    update newUpdate;
  }

  global void finish(Database.BatchableContext BC) {
    if(lastIteration && this.doChain) {
        TerritoryDataBatch_AcumLevel nextBatch = new TerritoryDataBatch_AcumLevel(4);
        database.executeBatch(nextBatch, 2000);
        return;
    }
    
    if(!lastIteration){
        TerritoryDataBatch_AcumCitizens thisBatch_nextTerritory = new TerritoryDataBatch_AcumCitizens(this.lvl2TerritoriesDivition);
        database.executeBatch(thisBatch_nextTerritory, 2000);
    }
  }

  private Map<String, TerritoryData_wrapper> calculateTempValuesForThisCitizens(
    List<Contact> scope
  ) {
    Map<String, TerritoryData_wrapper> tempTerritoryByString = new Map<String, TerritoryData_wrapper>();

    for (Contact thisCitizen : scope) {
      //las key de tipo string de los mapas son case sesitive. En la formula del objeto ya dejo el genero en mayuscula y aca hago lo mismo para asegurarlo
      system.debug('Por procesar un ciudadano');
      String territoryDataKey =
        thisCitizen.Territorio_Administrativo__c +
        thisCitizen.Gender__c.toUppercase();

      if (!tempTerritoryByString.containsKey(territoryDataKey)) {
        tempTerritoryByString.put(
          territoryDataKey,
          new TerritoryData_wrapper(
            thisCitizen.Territorio_Administrativo__c,
            thisCitizen.Gender__c
          )
        );
      }

      TerritoryData_wrapper tempTerritoryAcum = tempTerritoryByString.get(
        territoryDataKey
      );

      tempTerritoryAcum.acumIngreso(thisCitizen);
      tempTerritoryAcum.acumOcupacion(thisCitizen);
      tempTerritoryAcum.acumEducacion(thisCitizen);
      tempTerritoryAcum.acumActividadesEconomicas(thisCitizen);

      system.debug('lo que se ve en el wrapper para este ciudadano: ' + tempTerritoryAcum.territoryData);
    }

    return tempTerritoryByString;
  }

  private List<Datos_de_territorio__c> addTempValuesToExistingOnes(
    Map<String, TerritoryData_wrapper> tempTerritoryDataBy_TerritoryWithGender,
    List<Datos_de_territorio__c> oldUpadatedTerritorieData
  ) {
    List<Datos_de_territorio__c> newUpdate = new List<Datos_de_territorio__c>();

    for (
      Datos_de_territorio__c thisOldTerritoryData : oldUpadatedTerritorieData
    ) {
      TerritoryData_wrapper tempTerritoryDataWrapper = tempTerritoryDataBy_TerritoryWithGender.get(
        thisOldTerritoryData.TerritoryWithGenderKey__c
      );

      Datos_de_territorio__c tempTerritoryAcum = tempTerritoryDataWrapper.territoryData;
      //copia los valores de los campos del sObject a otra direccion de memoria
      //de esa forma, se puede por ejemplo acumular con += sin modificar el "original"
      Datos_de_territorio__c newTerritoryData = thisOldTerritoryData.clone(
        true,
        false,
        false,
        false
      );

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

      Map<String, Integer> tempActivityCount = tempTerritoryDataWrapper.activityCount;
      Map<String, Integer> newTerritoryActivityCount = (Map<String, Integer>) JSON.deserialize(
        newTerritoryData.Economic_Activities__c,
        Map<String, Integer>.class
      );

      for (String thisKey : tempActivityCount.keySet()) {
        if (!newTerritoryActivityCount.containsKey(thisKey)) {
          newTerritoryActivityCount.put(thisKey, 0);
        }
        Integer oldValue = newTerritoryActivityCount.get(thisKey);
        Integer newValue = oldValue + tempActivityCount.get(thisKey);
        newTerritoryActivityCount.put(thisKey, newValue);
      }

      newTerritoryData.Economic_Activities__c = JSON.serialize(
        newTerritoryActivityCount
      );
      system.debug('agregue datos aca: ' + newTerritoryData.Occupation_Not_Declared__c);
      system.debug('agregue datos aca: ' + newTerritoryData.Occupation_Retired__c);
      system.debug('agregue datos aca: ' + newTerritoryData.Occupation_Self_Employed__c);
      system.debug('agregue datos aca: ' + newTerritoryData.Occupation_Wage_Earned__c);

      newUpdate.add(newTerritoryData);
    }

    return newUpdate;
  }

  private class TerritoryData_wrapper {
    public Datos_de_territorio__c territoryData;
    public Map<String, Integer> activityCount;

    public territoryData_wrapper(
      String territorioAdministrativo,
      String gender
    ) {
      Datos_de_territorio__c temp = new Datos_de_territorio__c();

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

      this.activityCount = new Map<String, Integer>();
    }

    public void acumIngreso(Contact thisCitizen) {
      String ingreso = thisCitizen.Ingreso__c;

      if (ingreso == 'Muy Bajo') {
        this.territoryData.Income_Range_Very_Low__c++;
      }
      if (ingreso == 'Bajo') {
        this.territoryData.Income_Range_Low__c++;
      }
      if (ingreso == 'Medio') {
        this.territoryData.Income_Range_Medium__c++;
      }
      if (ingreso == 'Alto') {
        this.territoryData.Income_Range_High__c++;
      }
      if (ingreso == 'Muy Alto') {
        this.territoryData.Income_Range_Very_High__c++;
      }
    }

    public void acumOcupacion(Contact thisCitizen) {
      String ocupacion = thisCitizen.Condicion_de_ingreso__c;

      if (ocupacion == null) {
        this.territoryData.Occupation_Not_Declared__c++;
        return;
      }
      if (ocupacion.contains('Asalariado')) {
        this.territoryData.Occupation_Wage_Earned__c++;
      }

      if (
        ocupacion.contains('Cuenta propia') ||
        ocupacion.contains('Cooperativas y precaria')
      ) {
        this.territoryData.Occupation_Self_Employed__c++;
      }

      if (ocupacion.contains('Jubilados y pensionados')) {
        this.territoryData.Occupation_Retired__c++;
      }
    }

    public void acumEducacion(Contact thisCitizen) {
      String educacion = thisCitizen.Education_Level__c;
      if (String.isBlank(educacion)) {
        return;
      }

      if (educacion.toUpperCase().contains('PRIMARIO')) {
        this.territoryData.Education_Level_Primary__c++;
      }
      if (educacion.toUpperCase().contains('SECUNDARIO')) {
        this.territoryData.Education_Level_Secondary__c++;
      }
      if (educacion.toUpperCase().contains('TERCIARIO')) {
        this.territoryData.Education_Level_Tertiary__c++;
      }
      if (educacion.toUpperCase().contains('UNIVERSITARIO')) {
        this.territoryData.Education_Level_University_Degree__c++;
      }
    }

    public void acumActividadesEconomicas(Contact thisCitizen) {
      if (String.isBlank(thisCitizen.actividades_economicas__c)) {
        return;
      }

      List<String> lstActividadesEconomicas = thisCitizen.actividades_economicas__c.split(
        ';'
      );

      for (String thisActivity : lstActividadesEconomicas) {
        if (!this.activityCount.containsKey(thisActivity)) {
          this.activityCount.put(thisActivity, 0);
        }
        Integer oldValue = this.activityCount.get(thisActivity);

        this.activityCount.put(thisActivity, oldValue + 1);
      }
    }
  }

  public static List<Id> getSetOfLevel2ZonesForArgentina() {
    List<Id> level2_ids = new List<Id>();
    for (Territorio_Administrativo__c thisTerritory : [
      SELECT id
      FROM Territorio_Administrativo__c
      WHERE Nivel_Administrativo__c = 2 AND Location_UUID__c LIKE 'ARG%'
    ]) {
      level2_ids.add(thisTerritory.id);
    }
    return level2_ids;
  }

  public static List<Id> getSetOfThisIdPlusChildsIds_ForLvl2Territory(
    Id level2TerritoryId
  ) {
    List<Id> level2AndBelow_ids = new List<Id>();
    for (Territorio_Administrativo__c thisTerritory : [
      SELECT id
      FROM Territorio_Administrativo__c
      WHERE
        (Id = :level2TerritoryId
        OR ParentId__c = :level2TerritoryId
        OR ParentId__r.ParentId__c = :level2TerritoryId)
        AND Location_UUID__c LIKE 'ARG%'
    ]) {
      level2AndBelow_ids.add(thisTerritory.id);
    }
    return level2AndBelow_ids;
  }

  public static List<Id> getSetOfLvl1AndLvl0TerritoriesFromArgentina() {
    List<Id> upperLevelsIds = new List<Id>();
    for (Territorio_Administrativo__c thisTerritory : [
      SELECT id
      FROM Territorio_Administrativo__c
      WHERE
        (Nivel_Administrativo__c = 1
        OR Nivel_Administrativo__c = 0)
        AND Location_UUID__c LIKE 'ARG%'
    ]) {
      upperLevelsIds.add(thisTerritory.id);
    }
    return upperLevelsIds;
  }
}