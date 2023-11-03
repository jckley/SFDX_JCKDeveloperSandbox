@isTest
public class TerritoryDataBatchTest {
  @TestSetup
  static void makeData() {
    Territorio_Administrativo__c terr0 = new Territorio_Administrativo__c();
    terr0.Location_UUID__c = 'ARGTEST 0';
    terr0.Nivel_Administrativo__c = 0;
    terr0.Name = 'TEST 0';
    insert terr0;

    /*Test Setup */
    Territorio_Administrativo__c terr1 = new Territorio_Administrativo__c();
    terr1.Location_UUID__c = 'ARGTEST 1';
    terr1.Nivel_Administrativo__c = 1;
    terr1.Name = 'TEST 1';
    terr1.ParentId__c = terr0.Id;
    insert terr1;

    Territorio_Administrativo__c terr2 = new Territorio_Administrativo__c();
    terr2.Location_UUID__c = 'ARGTEST 2';
    terr2.Nivel_Administrativo__c = 2;
    terr2.Name = 'TEST 2';
    terr2.ParentId__c = terr1.Id;
    insert terr2;

    Territorio_Administrativo__c terr3 = new Territorio_Administrativo__c();
    terr3.Location_UUID__c = 'ARGTEST 3';
    terr3.Nivel_Administrativo__c = 3;
    terr3.Name = 'TEST 3';
    terr3.ParentId__c = terr2.Id;
    insert terr3;

    Territorio_Administrativo__c terr4_1 = new Territorio_Administrativo__c();
    terr4_1.Location_UUID__c = 'ARGTEST 4_1';
    terr4_1.Nivel_Administrativo__c = 4;
    terr4_1.Name = 'TEST 4_1';
    terr4_1.ParentId__c = terr3.Id;
    insert terr4_1;

    Territorio_Administrativo__c terr4_2 = new Territorio_Administrativo__c();
    terr4_2.Location_UUID__c = 'ARGTEST 4_2';
    terr4_2.Nivel_Administrativo__c = 4;
    terr4_2.Name = 'TEST 4_2';
    terr4_2.ParentId__c = terr3.Id;
    insert terr4_2;

    List<Contact> citizens = new List<Contact>();

    Contact con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1231';
    con.Territorio_Administrativo__c = terr4_1.Id;
    con.Birthdate = Date.newInstance(1948, 7, 15);
    con.Gender__c = 'M';
    con.Ingreso__c = 'Muy Bajo';
    con.Education_Level__c = 'Primario';
    con.Condicion_de_ingreso__c = 'Asalariado';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    con.actividades_economicas__c = 'Fuerzas de seguridad;Salud';
    citizens.add(con);

    con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1232';
    con.Territorio_Administrativo__c = terr4_1.Id;
    con.Birthdate = Date.newInstance(1964, 7, 15);
    con.Gender__c = 'M';
    con.Ingreso__c = 'Bajo';
    con.Education_Level__c = 'Secundario';
    con.Condicion_de_ingreso__c = 'Cooperativas y precaria';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    con.actividades_economicas__c = 'Educación';
    citizens.add(con);

    con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1233';
    con.Territorio_Administrativo__c = terr4_1.Id;
    con.Birthdate = Date.newInstance(1979, 7, 15);
    con.Gender__c = 'M';
    con.Ingreso__c = 'Medio';
    con.Education_Level__c = 'Terciario';
    con.Condicion_de_ingreso__c = 'Jubilados y pensionados';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    con.actividades_economicas__c = 'Fuerzas de seguridad;Salud;Comercio';
    citizens.add(con);

    con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1234';
    con.Territorio_Administrativo__c = terr4_1.Id;
    con.Birthdate = Date.newInstance(1994, 7, 15);
    con.Gender__c = 'M';
    con.Ingreso__c = 'Alto';
    con.Education_Level__c = 'Universitario';
    con.Condicion_de_ingreso__c = 'Cuenta propia';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    con.actividades_economicas__c = 'Fuerzas de seguridad';
    citizens.add(con);

    con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1235';
    con.Territorio_Administrativo__c = terr4_1.Id;
    con.Birthdate = Date.newInstance(2004, 7, 15);
    con.Gender__c = 'M';
    con.Ingreso__c = 'Muy Alto';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    citizens.add(con);

    con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1236';
    con.Territorio_Administrativo__c = terr4_1.Id;
    con.Birthdate = Date.newInstance(2030, 7, 15);
    con.Gender__c = 'M';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    citizens.add(con);

    con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1237';
    con.Territorio_Administrativo__c = terr4_1.Id;
    con.Birthdate = Date.newInstance(1930, 7, 15);
    con.Gender__c = 'F';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    citizens.add(con);

    con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1238';
    con.Territorio_Administrativo__c = terr4_1.Id;
    con.Birthdate = Date.newInstance(1949, 7, 15);
    con.Gender__c = 'F';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    citizens.add(con);

    con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1239';
    con.Territorio_Administrativo__c = terr4_1.Id;
    con.Birthdate = Date.newInstance(1965, 7, 15);
    con.Gender__c = 'F';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    citizens.add(con);

    con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1230';
    con.Territorio_Administrativo__c = terr4_1.Id;
    con.Birthdate = Date.newInstance(1980, 7, 15);
    con.Gender__c = 'F';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    citizens.add(con);

    con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1231';
    con.Territorio_Administrativo__c = terr4_2.Id;
    con.Birthdate = Date.newInstance(1995, 7, 15);
    con.Gender__c = 'F';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    con.actividades_economicas__c = 'Comercio';
    citizens.add(con);

    con = new Contact();
    con.SearchCriteria__c = '22/01/2001F609';
    con.LastName = 'Test';
    con.guid__c = '1232';
    con.Territorio_Administrativo__c = terr4_2.Id;
    con.Birthdate = Date.newInstance(2005, 7, 15);
    con.Gender__c = 'F';
    con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Argentino')
      .getRecordTypeId();
    con.actividades_economicas__c = 'Comercio';
    citizens.add(con);

    insert citizens;
  }

  @isTest
  public static void test_clearFields() {
    Territorio_Administrativo__c territory = [
      SELECT id
      FROM Territorio_Administrativo__c
      WHERE name = 'TEST 0'
    ];

    Datos_de_territorio__c dt = new Datos_de_territorio__c();
    dt.Territory__c = territory.Id;
    dt.gender__c = 'M';

    dt.Economic_Activities__c = '{"test1":12, "test2":1}';

    dt.Income_Range_High__c = 1;
    dt.Income_Range_Low__c = 2;
    dt.Income_Range_Medium__c = 3;
    dt.Income_Range_Very_High__c = 4;
    dt.Income_Range_Very_Low__c = 5;

    dt.Occupation_Not_Declared__c = 1;
    dt.Occupation_Retired__c = 2;
    dt.Occupation_Self_Employed__c = 3;
    dt.Occupation_Wage_Earned__c = 4;

    dt.Education_Level_Primary__c = 1;
    dt.Education_Level_Secondary__c = 2;
    dt.Education_Level_Tertiary__c = 3;
    dt.Education_Level_University_Degree__c = 4;

    insert dt;

    Test.startTest();
    TerritoryDataBatch_ClearFileds batch = new TerritoryDataBatch_ClearFileds();
    batch.doChain = false;
    database.executeBatch(batch, 2000);
    Test.stopTest();

    List<Territorio_Administrativo__c> territoriesWithClearedTerritoryData = [
      SELECT
        id,
        (
          SELECT
            gender__c,
            Economic_Activities__c,
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
            Education_Level_University_Degree__c
          FROM Territory_Data__r
        )
      FROM Territorio_Administrativo__c
    ];

    for (
      Territorio_Administrativo__c thisTerritory : territoriesWithClearedTerritoryData
    ) {
      Boolean pendingMale = true;
      Boolean pendingFemale = true;
      for (
        Datos_de_territorio__c thisTerritoryData : thisTerritory.Territory_Data__r
      ) {
        if (thisTerritoryData.gender__c == 'M') {
          pendingMale = false;
        }
        if (thisTerritoryData.gender__c == 'F') {
          pendingFemale = false;
        }

        System.assertEquals(
          0,
          thisTerritoryData.Income_Range_High__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );
        System.assertEquals(
          0,
          thisTerritoryData.Income_Range_Low__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );
        System.assertEquals(
          0,
          thisTerritoryData.Income_Range_Medium__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );
        System.assertEquals(
          0,
          thisTerritoryData.Income_Range_Very_High__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );
        System.assertEquals(
          0,
          thisTerritoryData.Income_Range_Very_Low__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );

        System.assertEquals(
          0,
          thisTerritoryData.Occupation_Not_Declared__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );
        System.assertEquals(
          0,
          thisTerritoryData.Occupation_Retired__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );
        System.assertEquals(
          0,
          thisTerritoryData.Occupation_Self_Employed__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );
        System.assertEquals(
          0,
          thisTerritoryData.Occupation_Wage_Earned__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );

        System.assertEquals(
          0,
          thisTerritoryData.Education_Level_Primary__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );
        System.assertEquals(
          0,
          thisTerritoryData.Education_Level_Secondary__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );
        System.assertEquals(
          0,
          thisTerritoryData.Education_Level_Tertiary__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );
        System.assertEquals(
          0,
          thisTerritoryData.Education_Level_University_Degree__c,
          'Los registros de territory data deben tener los campos seteados en 0.'
        );

        System.assertEquals(
          '{}',
          thisTerritoryData.Economic_Activities__c,
          'Las actividades economicas deben quedar seteadas a un JSON vacio {}'
        );
      }

      System.assertEquals(
        false,
        (pendingMale || pendingFemale),
        'Si el batch no encuentra un registro para male o female de territory data debe crearlo '
      );

      System.assertEquals(
        2,
        thisTerritory.Territory_Data__r.size(),
        'Si existe un registro creado previamente, el batch no debe repetirlo.' +
        ' Cada territorio debe quedar con solo 2 registros asociados de territory data.'
      );
    }
  }

  @isTest
  public static void test_acumCitizens() {
    Territorio_Administrativo__c territory4_1 = [
      SELECT id
      FROM Territorio_Administrativo__c
      WHERE name = 'TEST 4_1'
    ];

    Territorio_Administrativo__c territory4_2 = [
      SELECT id
      FROM Territorio_Administrativo__c
      WHERE name = 'TEST 4_2'
    ];

    List<Datos_de_territorio__c> dts = new List<Datos_de_territorio__c>();

    Datos_de_territorio__c dt = new Datos_de_territorio__c();
    dt.Territory__c = territory4_1.Id;
    dt.gender__c = 'M';
    dts.add(dt);

    dt = new Datos_de_territorio__c();
    dt.Territory__c = territory4_1.Id;
    dt.gender__c = 'F';
    dts.add(dt);

    dt = new Datos_de_territorio__c();
    dt.Territory__c = territory4_2.Id;
    dt.gender__c = 'M';
    dts.add(dt);

    dt = new Datos_de_territorio__c();
    dt.Territory__c = territory4_2.Id;
    dt.gender__c = 'F';
    //dejo agregados 5, para verificar que luego se le sumen las 2 que tienen citizens correctamente
    //como si fuera una segunda pasada de batch.
    dt.Occupation_Not_Declared__c = 5;
    dt.Economic_Activities__c = '{"test1":12, "test2":1}';
    dts.add(dt);

    insert (dts);

    Test.startTest();
    List<id> argentinaLvl2TerritoriesIds = TerritoryDataBatch_AcumCitizens.getSetOfLevel2ZonesForArgentina();
    TerritoryDataBatch_AcumCitizens batch = new TerritoryDataBatch_AcumCitizens(argentinaLvl2TerritoriesIds);
    batch.doChain = false;
    database.executeBatch(batch, 2000);
    Test.stopTest();

    Territorio_Administrativo__c territory4_1_WithData = [
      SELECT
        id,
        (
          SELECT
            gender__c,
            Economic_Activities__c,
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
            Education_Level_University_Degree__c
          FROM Territory_Data__r
        )
      FROM Territorio_Administrativo__c
      WHERE name = 'TEST 4_1'
    ];

    Territorio_Administrativo__c territory4_2_WithData = [
      SELECT
        id,
        (
          SELECT
            gender__c,
            Economic_Activities__c,
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
            Education_Level_University_Degree__c
          FROM Territory_Data__r
        )
      FROM Territorio_Administrativo__c
      WHERE name = 'TEST 4_2'
    ];

    Datos_de_territorio__c t1_male;
    Datos_de_territorio__c t1_female;
    Datos_de_territorio__c t2_male;
    Datos_de_territorio__c t2_female;

    for (
      Datos_de_territorio__c thisTd : territory4_1_WithData.Territory_Data__r
    ) {
      if (thisTd.gender__c == 'M') {
        t1_male = thisTd;
      }
      if (thisTd.gender__c == 'F') {
        t1_female = thisTd;
      }
    }
    for (
      Datos_de_territorio__c thisTd : territory4_2_WithData.Territory_Data__r
    ) {
      if (thisTd.gender__c == 'M') {
        t2_male = thisTd;
      }
      if (thisTd.gender__c == 'F') {
        t2_female = thisTd;
      }
    }

    //t2_male estaba vacio, no se crearon contactos a ese territorio.

    //t2_female se le crearon 2 contactos y tenia alguna data precargada:
    System.assertEquals(
      7,
      t2_female.Occupation_Not_Declared__c,
      'En este territory data, habia originalmente 5 ciudadanos contados. Y se crearon otros 2, ahora deben ser 7'
    );

    Map<String, Integer> cuentaActividades_t2_female = (Map<String, Integer>) JSON.deserialize(
      t2_female.Economic_Activities__c,
      Map<String, Integer>.class
    );

    System.assertEquals(
      12,
      cuentaActividades_t2_female.get('test1'),
      'El json de actividades, debe contener los valores existentes.'
    );

    System.assertEquals(
      1,
      cuentaActividades_t2_female.get('test2'),
      'El json de actividades, debe contener los valores existentes.'
    );

    System.assertEquals(
      2,
      cuentaActividades_t2_female.get('Comercio'),
      'El json de actividades, tambien debe agregar los datos de los contactos recorridos por el batch.'
    );

    //t1_male se le crearon 2 contactos y tenia alguna data precargada:

    System.assertEquals(
      1,
      t1_male.Income_Range_Very_Low__c,
      'Se creo 1 male con cada tipo de ingreso'
    );

    System.assertEquals(
      1,
      t1_male.Income_Range_Low__c,
      'Se creo 1 male con cada tipo de ingreso'
    );

    System.assertEquals(
      1,
      t1_male.Income_Range_Medium__c,
      'Se creo 1 male con cada tipo de ingreso'
    );

    System.assertEquals(
      1,
      t1_male.Income_Range_High__c,
      'Se creo 1 male con cada tipo de ingreso'
    );

    System.assertEquals(
      1,
      t1_male.Income_Range_Very_High__c,
      'Se creo 1 male con cada tipo de ingreso'
    );

    System.assertEquals(
      1,
      t1_male.Education_Level_Primary__c,
      'Se creo 1 male con cada tipo de educacion'
    );

    System.assertEquals(
      1,
      t1_male.Education_Level_Secondary__c,
      'Se creo 1 male con cada tipo de educacion'
    );

    System.assertEquals(
      1,
      t1_male.Education_Level_Tertiary__c,
      'Se creo 1 male con cada tipo de educacion'
    );

    System.assertEquals(
      1,
      t1_male.Education_Level_University_Degree__c,
      'Se creo 1 male con cada tipo de educacion'
    );

    System.assertEquals(
      2,
      t1_male.Occupation_Not_Declared__c,
      'Se crearon 2 male sin condicion de ingreso'
    );

    System.assertEquals(
      2,
      t1_male.Occupation_Self_Employed__c,
      'Se crearon 2 male que agrupan a self employed.'
    );

    System.assertEquals(
      1,
      t1_male.Occupation_Wage_Earned__c,
      'Se creo 1 male asalariado'
    );

    System.assertEquals(
      1,
      t1_male.Occupation_Retired__c,
      'Se creo 1 male jubilado'
    );

    //t1_female
    System.assertEquals(
      4,
      t1_female.Occupation_Not_Declared__c,
      'Las 4 female que agrupan a t1, no tienen ocupacion declarada'
    );
  }

  @isTest
  public static void test_acumTerritories() {
    List<Territorio_Administrativo__c> territorios = [
      SELECT id
      FROM Territorio_Administrativo__c
    ];

    List<Datos_de_territorio__c> tds = new List<Datos_de_territorio__c>();

    for (Territorio_Administrativo__c thisTerritory : territorios) {
      tds.add(
        new Datos_de_territorio__c(
          territory__c = thisTerritory.id,
          gender__c = 'M'
        )
      );
      tds.add(
        new Datos_de_territorio__c(
          territory__c = thisTerritory.id,
          gender__c = 'F'
        )
      );
    }

    insert tds;

    List<Datos_de_territorio__c> tdsWithData = new List<Datos_de_territorio__c>();

    Datos_de_territorio__c l4_1_male = [
      SELECT id
      FROM Datos_de_territorio__c
      WHERE gender__c = 'M' AND territory__r.name = 'TEST 4_1'
    ];
    Datos_de_territorio__c l4_2_male = [
      SELECT id
      FROM Datos_de_territorio__c
      WHERE gender__c = 'M' AND territory__r.name = 'TEST 4_2'
    ];
    Datos_de_territorio__c l4_1_female = [
      SELECT id
      FROM Datos_de_territorio__c
      WHERE gender__c = 'F' AND territory__r.name = 'TEST 4_1'
    ];

    //para los male, puse la misma cantidad en el los 2 territorios del ultimo nivel, asi que se deberia duplicar en el nivel 3
    l4_1_male.Economic_Activities__c = '{"test1":10, "test2":20}';

    l4_1_male.Income_Range_High__c = 1;

    tdsWithData.add(l4_1_male);

    l4_2_male.Economic_Activities__c = '{"test1":10}';

    l4_2_male.Income_Range_High__c = 1;

    tdsWithData.add(l4_2_male);

    //para los female, deje en 1 solo, asi que deberia ser la misma cantidad en el nivel 3
    l4_1_female.Economic_Activities__c = '{"test1":100}';

    l4_1_female.Income_Range_High__c = 10;

    tdsWithData.add(l4_1_female);

    update tdsWithData;

    Test.startTest();
    TerritoryDataBatch_AcumLevel batch = new TerritoryDataBatch_AcumLevel(4);
    batch.doChain = false;
    database.executeBatch(batch, 2000);
    Test.stopTest();

    Datos_de_territorio__c terr3_male = [
      SELECT
        id,
        Gender__c,
        Economic_Activities__c,
        Income_Range_High__c
      FROM Datos_de_territorio__c
      WHERE gender__c = 'M' AND territory__r.name = 'TEST 3'
    ];

    Datos_de_territorio__c terr3_female = [
        SELECT
          id,
          Gender__c,
          Economic_Activities__c,
          Income_Range_High__c
        FROM Datos_de_territorio__c
        WHERE gender__c = 'F' AND territory__r.name = 'TEST 3'
      ];

    System.assertEquals(
      2,
      terr3_male.Income_Range_High__c,
      'Al territorio de nivel 3, deben haber llegado 2 male de income high (se deben sumar los de los 2 territorios)'
    );

    System.assertEquals(
        10,
        terr3_female.Income_Range_High__c,
        'Al territorio de nivel 3, deben haber llegado 10 female de income high se debe mantener la cuenta del unico territorio con valores'
      );

    Map<String, Integer> cuentaActividadesMale = (Map<String, Integer>) JSON.deserialize(
        terr3_male.Economic_Activities__c,
      Map<String, Integer>.class
    );

    Map<String, Integer> cuentaActividadesFemale = (Map<String, Integer>) JSON.deserialize(
        terr3_female.Economic_Activities__c,
      Map<String, Integer>.class
    );

    System.assertEquals(
      100,
      cuentaActividadesFemale.get('test1'),
      'Para la actividad test1, en los datos de females, el unico valor que existe se debe haber mantendio: 100'
    );

    System.assertEquals(
        20,
        cuentaActividadesMale.get('test1'),
        'Para la actividad test1, en los datos de male, se deben haber sumado los valores y ahora dar: 20'
      );

      System.assertEquals(
        20,
        cuentaActividadesMale.get('test2'),
        'Para la actividad test2, en los datos de male, no se debe haber perdido el valor existente y seguir dando: 20'
      );
  }
/*
  @isTest
  public static void test_batchChaining_fullTerritoryTree() {
    List<Territorio_Administrativo__c> territories = [
      SELECT id
      FROM Territorio_Administrativo__c
    ];
    for (Territorio_Administrativo__c thisTerritory : territories) {
      thisTerritory.RiverId_Total_Ciudadanos__c = 200;
      thisTerritory.RiverId_TotEco_Activities__c = '{"Comercio":100000}';
    }

    update territories;

    Test.startTest();
    TerritoryBatch_ClearFields batch = new TerritoryBatch_ClearFields();
    database.executeBatch(batch, 2000);
    Test.stopTest();

    Territorio_Administrativo__c terr0 = [
      SELECT id, RiverId_Total_Ciudadanos__c, RiverId_TotEco_Activities__c
      FROM Territorio_Administrativo__c
      WHERE name = 'TEST 0'
    ];
    Territorio_Administrativo__c terr1 = [
      SELECT id, RiverId_Total_Ciudadanos__c, RiverId_TotEco_Activities__c
      FROM Territorio_Administrativo__c
      WHERE name = 'TEST 1'
    ];
    Territorio_Administrativo__c terr2 = [
      SELECT id, RiverId_Total_Ciudadanos__c, RiverId_TotEco_Activities__c
      FROM Territorio_Administrativo__c
      WHERE name = 'TEST 2'
    ];
    Territorio_Administrativo__c terr3 = [
      SELECT id, RiverId_Total_Ciudadanos__c, RiverId_TotEco_Activities__c
      FROM Territorio_Administrativo__c
      WHERE name = 'TEST 3'
    ];
    Territorio_Administrativo__c terr4_1 = [
      SELECT id, RiverId_Total_Ciudadanos__c, RiverId_TotEco_Activities__c
      FROM Territorio_Administrativo__c
      WHERE name = 'TEST 4_1'
    ];
    Territorio_Administrativo__c terr4_2 = [
      SELECT id, RiverId_Total_Ciudadanos__c, RiverId_TotEco_Activities__c
      FROM Territorio_Administrativo__c
      WHERE name = 'TEST 4_2'
    ];

    System.assertEquals(
      10,
      terr4_1.RiverId_Total_Ciudadanos__c,
      'Se le crearon 10 ciudadanos de river al territorio 4_1'
    );
    System.assertEquals(
      2,
      terr4_2.RiverId_Total_Ciudadanos__c,
      'Se le crearon 2 ciudadanos de river al territorio 4_2'
    );

    System.assertEquals(
      12,
      terr3.RiverId_Total_Ciudadanos__c,
      'El nivel 3 debe agrupar los ciudadanos del nivel 4, para un total de 12 ciudadanos.'
    );
    System.assertEquals(
      12,
      terr2.RiverId_Total_Ciudadanos__c,
      'Como no hay divisiones, el nivel 2 tiene que tener los mismos ciudadanos que el nivel 3.'
    );
    System.assertEquals(
      12,
      terr1.RiverId_Total_Ciudadanos__c,
      'Como no hay divisiones, el nivel 1 tiene que tener los mismos ciudadanos que el nivel 2.'
    );
    System.assertEquals(
      12,
      terr0.RiverId_Total_Ciudadanos__c,
      'Como no hay divisiones, el nivel 0 tiene que tener los mismos ciudadanos que el nivel 1.'
    );

    Map<String, Integer> cuentaActividades0 = (Map<String, Integer>) JSON.deserialize(
      terr0.RiverId_TotEco_Activities__c,
      Map<String, Integer>.class
    );
    Map<String, Integer> cuentaActividades1 = (Map<String, Integer>) JSON.deserialize(
      terr1.RiverId_TotEco_Activities__c,
      Map<String, Integer>.class
    );
    Map<String, Integer> cuentaActividades2 = (Map<String, Integer>) JSON.deserialize(
      terr2.RiverId_TotEco_Activities__c,
      Map<String, Integer>.class
    );
    Map<String, Integer> cuentaActividades3 = (Map<String, Integer>) JSON.deserialize(
      terr3.RiverId_TotEco_Activities__c,
      Map<String, Integer>.class
    );
    Map<String, Integer> cuentaActividades4_1 = (Map<String, Integer>) JSON.deserialize(
      terr4_1.RiverId_TotEco_Activities__c,
      Map<String, Integer>.class
    );
    Map<String, Integer> cuentaActividades4_2 = (Map<String, Integer>) JSON.deserialize(
      terr4_2.RiverId_TotEco_Activities__c,
      Map<String, Integer>.class
    );

    System.assertEquals(
      2,
      cuentaActividades4_2.get('Comercio'),
      'En el territorio 4_2 hay solo 2 ciudadanas con actividad comercio'
    );
    System.assertEquals(
      1,
      cuentaActividades4_1.get('Comercio'),
      'En el territorio 4_1 hay solo 1 ciudadano con actividad comercio'
    );

    System.assertEquals(
      3,
      cuentaActividades3.get('Comercio'),
      'En los territorios superiores se deben haber acumulado los 3 ciudadanos con comercio'
    );
    System.assertEquals(
      3,
      cuentaActividades2.get('Comercio'),
      'En los territorios superiores se deben haber acumulado los 3 ciudadanos con comercio'
    );
    System.assertEquals(
      3,
      cuentaActividades1.get('Comercio'),
      'En los territorios superiores se deben haber acumulado los 3 ciudadanos con comercio'
    );
    System.assertEquals(
      3,
      cuentaActividades0.get('Comercio'),
      'En los territorios superiores se deben haber acumulado los 3 ciudadanos con comercio'
    );
  }
*/
}