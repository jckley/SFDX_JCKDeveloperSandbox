@isTest
public class TerritoryBatchTest {

    @TestSetup
    static void makeData(){
        Territorio_Administrativo__c terr0 = new Territorio_Administrativo__c();
        terr0.Location_UUID__c = 'TEST 0';
        terr0.Nivel_Administrativo__c = 0;
        terr0.Name = 'TEST 0';
        insert terr0;

        /*Test Setup */
        Territorio_Administrativo__c terr1 = new Territorio_Administrativo__c();
        terr1.Location_UUID__c = 'TEST 1';
        terr1.Nivel_Administrativo__c = 1;
        terr1.Name = 'TEST 1';
		terr1.ParentId__c = terr0.Id;
        insert terr1;

        Territorio_Administrativo__c terr2 = new Territorio_Administrativo__c();
        terr2.Location_UUID__c = 'TEST 2';
        terr2.Nivel_Administrativo__c = 2;
        terr2.Name = 'TEST 2';
        terr2.ParentId__c = terr1.Id;
        insert terr2;

        Territorio_Administrativo__c terr3 = new Territorio_Administrativo__c();
        terr3.Location_UUID__c = 'TEST 3';
        terr3.Nivel_Administrativo__c = 3;
        terr3.Name = 'TEST 3';
        terr3.ParentId__c = terr2.Id;
        insert terr3;

        Territorio_Administrativo__c terr4_1 = new Territorio_Administrativo__c();
        terr4_1.Location_UUID__c = 'TEST 4_1';
        terr4_1.Nivel_Administrativo__c = 4;
        terr4_1.Name = 'TEST 4_1';
        terr4_1.ParentId__c = terr3.Id;
        insert terr4_1;

        Territorio_Administrativo__c terr4_2 = new Territorio_Administrativo__c();
        terr4_2.Location_UUID__c = 'TEST 4_2';
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
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
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
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
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
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
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
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
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
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1236';
        con.Territorio_Administrativo__c = terr4_1.Id;
        con.Birthdate = Date.newInstance(2030, 7, 15);
        con.Gender__c = 'M';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1237';
        con.Territorio_Administrativo__c = terr4_1.Id;
        con.Birthdate = Date.newInstance(1930, 7, 15);
        con.Gender__c = 'F';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1238';
        con.Territorio_Administrativo__c = terr4_1.Id;
        con.Birthdate = Date.newInstance(1949, 7, 15);
        con.Gender__c = 'F';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1239';
        con.Territorio_Administrativo__c = terr4_1.Id;
        con.Birthdate = Date.newInstance(1965, 7, 15);
        con.Gender__c = 'F';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1230';
        con.Territorio_Administrativo__c = terr4_1.Id;
        con.Birthdate = Date.newInstance(1980, 7, 15);
        con.Gender__c = 'F';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1231';
        con.Territorio_Administrativo__c = terr4_2.Id;
        con.Birthdate = Date.newInstance(1995, 7, 15);
        con.Gender__c = 'F';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
        con.actividades_economicas__c = 'Comercio';
        citizens.add(con);

        con = new Contact();
        con.SearchCriteria__c = '22/01/2001F609';
        con.LastName = 'Test';
        con.guid__c = '1232';
        con.Territorio_Administrativo__c = terr4_2.Id;
        con.Birthdate = Date.newInstance(2005, 7, 15);
        con.Gender__c = 'F';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con.Is_RiverId_Citizen__c = true;
        con.actividades_economicas__c = 'Comercio';
        citizens.add(con);
                            
        insert citizens;
    }


    @isTest
    public static void test_clearFields () {
        List<Territorio_Administrativo__c> territories = [SELECT id FROM Territorio_Administrativo__c];
        for(Territorio_Administrativo__c thisTerritory : territories){
            thisTerritory.RiverId_Total_Ciudadanos__c = 200;
            
            thisTerritory.RiverId_TotInc_Very_Low__c = 200;
            thisTerritory.RiverId_TotInc_Low__c = 200;
            thisTerritory.RiverId_TotInc_Medium__c = 200;
            thisTerritory.RiverId_TotInc_High__c = 200;
            thisTerritory.RiverId_TotInc_Very_High__c = 200;
            
            thisTerritory.RiverId_Total_Edu_Primary__c = 200;
            thisTerritory.RiverId_Total_Edu_Secondary__c = 200;
            thisTerritory.RiverId_Total_Edu_Tertiary__c = 200;
            thisTerritory.RiverId_Total_Edu_University__c = 200;
            
            thisTerritory.RiverId_TotOccu_Not_Declared__c = 200;
            thisTerritory.RiverId_TotOccu_Wage__c = 200;
            thisTerritory.RiverId_TotOccu_Self_Employed__c = 200;
            thisTerritory.RiverId_TotOccu_Retired__c = 200;
            
            thisTerritory.RiverId_Etario_Sub_16_Male__c = 200;
            thisTerritory.RiverId_Etario_Centennials_Male__c = 200;
            thisTerritory.RiverId_Etario_Millennials_Male__c = 200;
            thisTerritory.RiverId_Etario_Generacion_X_Male__c = 200;
            thisTerritory.RiverId_Etario_Baby_Boomers_Male__c = 200;
            thisTerritory.RiverId_Etario_Generacion_Silenciosa_M__c = 200;
            
            thisTerritory.RiverId_Etario_Millennials_Female__c = 200;
            thisTerritory.RiverId_Etario_Generacion_X_Female__c = 200;
            thisTerritory.RiverId_Etario_Baby_Boomers_Female__c = 200;
            thisTerritory.RiverId_Etario_Generacion_Silenciosa_F__c = 200;
            thisTerritory.RiverId_Etario_Sub_16_Female__c = 200;
            thisTerritory.RiverId_Etario_Centennials_Female__c = 200;
            
            thisTerritory.RiverId_TotEco_Activities__c = '{"Comercio":200}';
        } 

        update territories;

        Test.startTest();
            TerritoryBatch_ClearFields batch = new TerritoryBatch_ClearFields();
            batch.doChain = false;
    	    database.executeBatch(batch, 2000);
        Test.stopTest();

        List<Territorio_Administrativo__c> clearedTerritories = [
            SELECT id,RiverId_Total_Ciudadanos__c,RiverId_TotInc_Very_Low__c,
                RiverId_TotInc_Low__c,RiverId_TotInc_Medium__c,RiverId_TotInc_High__c,
                RiverId_TotInc_Very_High__c, RiverId_Total_Edu_Primary__c, RiverId_Total_Edu_Secondary__c,
                RiverId_Total_Edu_Tertiary__c, RiverId_Total_Edu_University__c,
                RiverId_TotOccu_Not_Declared__c, RiverId_TotOccu_Wage__c, RiverId_TotOccu_Self_Employed__c,RiverId_TotOccu_Retired__c,
                RiverId_Etario_Sub_16_Male__c, RiverId_Etario_Centennials_Male__c, RiverId_Etario_Millennials_Male__c, RiverId_Etario_Generacion_X_Male__c,
                RiverId_Etario_Baby_Boomers_Male__c, RiverId_Etario_Generacion_Silenciosa_M__c,
                RiverId_Etario_Millennials_Female__c, RiverId_Etario_Generacion_X_Female__c, RiverId_Etario_Baby_Boomers_Female__c,
                RiverId_Etario_Generacion_Silenciosa_F__c,RiverId_Etario_Sub_16_Female__c, RiverId_Etario_Centennials_Female__c,
                RiverId_TotEco_Activities__c 
            FROM Territorio_Administrativo__c];

        for(Territorio_Administrativo__c thisTerritory : clearedTerritories) {
            System.assertEquals(0, thisTerritory.RiverId_Total_Ciudadanos__c, 'El total de ciudadanos socios de river debe haber seteado a 0');

            System.assertEquals(0, thisTerritory.RiverId_TotInc_Very_Low__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_TotInc_Low__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_TotInc_Medium__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_TotInc_High__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_TotInc_Very_High__c , 'Todos los campos deben estar reseteados');

            System.assertEquals(0, thisTerritory.RiverId_Total_Edu_Primary__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Total_Edu_Secondary__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Total_Edu_Tertiary__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Total_Edu_University__c , 'Todos los campos deben estar reseteados');

            System.assertEquals(0, thisTerritory.RiverId_TotOccu_Not_Declared__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_TotOccu_Wage__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_TotOccu_Self_Employed__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_TotOccu_Retired__c , 'Todos los campos deben estar reseteados');

            System.assertEquals(0, thisTerritory.RiverId_Etario_Sub_16_Male__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Etario_Centennials_Male__c , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Etario_Millennials_Male__c  , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Etario_Generacion_X_Male__c  , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Etario_Baby_Boomers_Male__c  , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Etario_Generacion_Silenciosa_M__c  , 'Todos los campos deben estar reseteados');

            System.assertEquals(0, thisTerritory.RiverId_Etario_Millennials_Female__c   , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Etario_Generacion_X_Female__c   , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Etario_Baby_Boomers_Female__c   , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Etario_Generacion_Silenciosa_F__c   , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Etario_Sub_16_Female__c   , 'Todos los campos deben estar reseteados');
            System.assertEquals(0, thisTerritory.RiverId_Etario_Centennials_Female__c   , 'Todos los campos deben estar reseteados');

            System.assertEquals('{}', thisTerritory.RiverId_TotEco_Activities__c    , 'El campo de actividades economicas debe contener un objeto vacio');

        }

    }

    @isTest
    public static void test_acumCitizens () {
        
        Contact terr4_2Contact = [SELECT id FROM contact WHERE Territorio_Administrativo__r.name = 'TEST 4_2' LIMIT 1];
        terr4_2Contact.Condicion_de_ingreso__c = 'Asalariado;Cuenta propia';
        update terr4_2Contact;

        Territorio_Administrativo__c terr4_2_update = [SELECT id FROM Territorio_Administrativo__c WHERE name = 'TEST 4_2'];
        terr4_2_update.RiverId_TotEco_Activities__c = '{"Comercio":5,"Salud":2}';
        update terr4_2_update;

        Test.startTest();
            TerritoryBatch_AcumCitizens batch = new TerritoryBatch_AcumCitizens();
            batch.doChain = false;
            database.executeBatch(batch, 2000);
        Test.stopTest();

        Territorio_Administrativo__c terr4_1 = [
            SELECT 
                id,RiverId_Total_Ciudadanos__c,RiverId_TotInc_Very_Low__c,
                RiverId_TotInc_Low__c,RiverId_TotInc_Medium__c,RiverId_TotInc_High__c,
                RiverId_TotInc_Very_High__c, RiverId_Total_Edu_Primary__c, RiverId_Total_Edu_Secondary__c,
                RiverId_Total_Edu_Tertiary__c, RiverId_Total_Edu_University__c,
                RiverId_TotOccu_Not_Declared__c, RiverId_TotOccu_Wage__c, RiverId_TotOccu_Self_Employed__c,RiverId_TotOccu_Retired__c,
                RiverId_Etario_Sub_16_Male__c, RiverId_Etario_Centennials_Male__c, RiverId_Etario_Millennials_Male__c, RiverId_Etario_Generacion_X_Male__c,
                RiverId_Etario_Baby_Boomers_Male__c, RiverId_Etario_Generacion_Silenciosa_M__c,
                RiverId_Etario_Millennials_Female__c, RiverId_Etario_Generacion_X_Female__c, RiverId_Etario_Baby_Boomers_Female__c,
                RiverId_Etario_Generacion_Silenciosa_F__c,
                RiverId_TotEco_Activities__c
            FROM Territorio_Administrativo__c 
            WHERE name = 'TEST 4_1'];

        Territorio_Administrativo__c terr4_2 = [
            SELECT 
                id, RiverId_Total_Ciudadanos__c, RiverId_Etario_Sub_16_Female__c,
                RiverId_Etario_Centennials_Female__c, RiverId_TotEco_Activities__c,
                RiverId_TotOccu_Wage__c, RiverId_TotOccu_Self_Employed__c
            FROM Territorio_Administrativo__c 
            WHERE name = 'TEST 4_2'];

        System.assertEquals(10, terr4_1.RiverId_Total_Ciudadanos__c, 'Se le crearon 10 ciudadanos de river al territorio 4_1');
        System.assertEquals(2, terr4_2.RiverId_Total_Ciudadanos__c, 'Se le crearon 2 ciudadanos de river al territorio 4_2');

        System.assertEquals(1, terr4_1.RiverId_TotInc_Very_Low__c, 'Se le 1 ciudadano con nivel de ingreso muy bajo al territorio 4_1');
        System.assertEquals(1, terr4_1.RiverId_TotInc_Low__c, 'Se le 1 ciudadano con nivel de ingreso bajo al territorio 4_1');
        System.assertEquals(1, terr4_1.RiverId_TotInc_Medium__c, 'Se le 1 ciudadano con nivel de ingreso medio al territorio 4_1');
        System.assertEquals(1, terr4_1.RiverId_TotInc_High__c, 'Se le 1 ciudadano con nivel de ingreso alto al territorio 4_1');
        System.assertEquals(1, terr4_1.RiverId_TotInc_Very_High__c, 'Se le 1 ciudadano con nivel de ingreso muy alto al territorio 4_1');

        System.assertEquals(1, terr4_1.RiverId_Total_Edu_Primary__c, 'Se le 1 ciudadano con nivel educativo primaria territorio 4_1');
        System.assertEquals(1, terr4_1.RiverId_Total_Edu_Secondary__c, 'Se le 1 ciudadano con nivel educativo secundaria territorio 4_1');
        System.assertEquals(1, terr4_1.RiverId_Total_Edu_Tertiary__c, 'Se le 1 ciudadano con nivel educativo terciario territorio 4_1');
        System.assertEquals(1, terr4_1.RiverId_Total_Edu_University__c, 'Se le 1 ciudadano con nivel educativo universitario territorio 4_1');

        System.assertEquals(6, terr4_1.RiverId_TotOccu_Not_Declared__c, 'Al tipo de ocupacion Not_Declared del territorio 4_1 se le acumularon: 6');
        System.assertEquals(1, terr4_1.RiverId_TotOccu_Wage__c, 'Al tipo de ocupacion Wage del territorio 4_1 se le acumularon: 1');
        System.assertEquals(2, terr4_1.RiverId_TotOccu_Self_Employed__c, 'Al tipo de ocupacion Self_Employed del territorio 4_1 se le acumularon: 2');
        System.assertEquals(1, terr4_1.RiverId_TotOccu_Retired__c, 'Al tipo de ocupacion no Retired del territorio 4_1 se le acumularon: 1');
        //Terr2
        System.assertEquals(1, terr4_2.RiverId_TotOccu_Wage__c, 'Se completo 1 ciudadano del territorio 2 con 2 valores diferentes en la picklist. '+
                                                                    'Debe acumular a wage y self employe');
        System.assertEquals(1, terr4_2.RiverId_TotOccu_Self_Employed__c, 'Se completo 1 ciudadano del territorio 2 con 2 valores diferentes en la picklist. '+
                                                                    'Debe acumular a wage y self employe');

        System.assertEquals(1, terr4_1.RiverId_Etario_Generacion_Silenciosa_M__c, 'Se creo 1 Male perteneciente a Generacion_Silenciosa');
        System.assertEquals(1, terr4_1.RiverId_Etario_Baby_Boomers_Male__c, 'Se creo 1 Male perteneciente a Baby_Boomers');
        System.assertEquals(1, terr4_1.RiverId_Etario_Generacion_X_Male__c, 'Se creo 1 Male perteneciente a Generacion_X');
        System.assertEquals(1, terr4_1.RiverId_Etario_Millennials_Male__c, 'Se creo 1 Male perteneciente a Millennials');
        System.assertEquals(1, terr4_1.RiverId_Etario_Centennials_Male__c, 'Se creo 1 Male perteneciente a Centennials');
        System.assertEquals(1, terr4_1.RiverId_Etario_Sub_16_Male__c, 'Se creo 1 Male perteneciente a Sub_16');

        System.assertEquals(1, terr4_1.RiverId_Etario_Generacion_Silenciosa_F__c, 'Se creo 1 Female perteneciente a Generacion_Silenciosa');
        System.assertEquals(1, terr4_1.RiverId_Etario_Baby_Boomers_Female__c, 'Se creo 1 Female perteneciente a Baby_Boomers');
        System.assertEquals(1, terr4_1.RiverId_Etario_Generacion_X_Female__c, 'Se creo 1 Female perteneciente a Generacion_X');
        System.assertEquals(1, terr4_1.RiverId_Etario_Millennials_Female__c, 'Se creo 1 Female perteneciente a Millennials');
        System.assertEquals(1, terr4_2.RiverId_Etario_Sub_16_Female__c, 'Se creo 1 Female perteneciente a Centennials');
        System.assertEquals(1, terr4_2.RiverId_Etario_Centennials_Female__c, 'Se creo 1 Female perteneciente a Sub_16');

        String actividadesTerr4_1 = terr4_1.RiverId_TotEco_Activities__c;

        Map<String, Integer> cuentaActividades = (Map<String, Integer>) JSON.deserialize(actividadesTerr4_1, Map<String, Integer>.class);

        System.assertEquals(3, cuentaActividades.get('Fuerzas de seguridad'), 'Fuerzas de seguridad esta en 3 ciudadanos diferentes del territorio 1');
        System.assertEquals(2, cuentaActividades.get('Salud'), 'Salud esta en 2 ciudadanos diferentes del territorio 1');
        System.assertEquals(1, cuentaActividades.get('Educación'), 'Educación esta en 1 ciudadanos diferentes del territorio 1');
        System.assertEquals(1, cuentaActividades.get('Comercio'), 'Comercio esta en 1 ciudadanos diferentes del territorio 1');


        String actividadesTerr4_2 = terr4_2.RiverId_TotEco_Activities__c;

        Map<String, Integer> cuentaActividades2 = (Map<String, Integer>) JSON.deserialize(actividadesTerr4_2, Map<String, Integer>.class);

        System.assertEquals(7, cuentaActividades2.get('Comercio'), 'En el territorio 2, tengo un base de 5 ciudadanos en Comercio: Mas 2 que se insertaron, debe haber un total de 7');
        System.assertEquals(2, cuentaActividades2.get('Salud'), 'En el territorio 2, tengo un base de 2 ciudadanos en Salud.');

    }

    @isTest
    public static void test_acumTerritories () {
        List<Territorio_Administrativo__c> territorios = [SELECT id FROM Territorio_Administrativo__c WHERE ParentId__r.Name = 'TEST 3'];
        territorios[0].RiverId_Total_Ciudadanos__c = 20;
        territorios[1].RiverId_Total_Ciudadanos__c = 10;

        territorios[0].RiverId_TotEco_Activities__c = '{"Comercio":1,"Salud":1}';
        territorios[1].RiverId_TotEco_Activities__c = '{"Rural":5,"Salud":2}';

        update territorios;

        Test.startTest();
            TerritoryBatch_AcumLevel batch = new TerritoryBatch_AcumLevel(4);
            batch.doChain = false;
            database.executeBatch(batch, 2000);
        Test.stopTest();

        Territorio_Administrativo__c terr3 = [
            SELECT id,RiverId_Total_Ciudadanos__c,RiverId_TotEco_Activities__c 
            FROM Territorio_Administrativo__c 
            WHERE name = 'TEST 3'];

        System.assertEquals(30, terr3.RiverId_Total_Ciudadanos__c, 'Al territorio padre, de nivel superior, se le deben haber acumulado los valores de los hijos');

        Map<String, Integer> cuentaActividades = (Map<String, Integer>) JSON.deserialize(terr3.RiverId_TotEco_Activities__c, Map<String, Integer>.class);

        System.assertEquals(3, cuentaActividades.get('Salud'), 'Para la actividad Salud, el territorio superior debe haber agrupado los inferiores para un total de 5');
        System.assertEquals(1, cuentaActividades.get('Comercio'), 'Para la actividad Comercio, el territorio superior debe haber agrupado el unico inferiores para un total de 1');
        System.assertEquals(5, cuentaActividades.get('Rural'), 'Para la actividad Rural, el territorio superior debe haber agrupado el unico inferiores para un total de 5');
    }

    
    @isTest
    public static void test_batchChaining_fullTerritoryTree () {
        List<Territorio_Administrativo__c> territories = [SELECT id FROM Territorio_Administrativo__c];
        for(Territorio_Administrativo__c thisTerritory : territories){
            thisTerritory.RiverId_Total_Ciudadanos__c = 200;
            thisTerritory.RiverId_TotEco_Activities__c = '{"Comercio":100000}';
        } 

        update territories;

        Test.startTest();
            TerritoryBatch_ClearFields batch = new TerritoryBatch_ClearFields();
            database.executeBatch(batch, 2000);
        Test.stopTest();

        Territorio_Administrativo__c terr0 = [SELECT id,RiverId_Total_Ciudadanos__c,RiverId_TotEco_Activities__c FROM Territorio_Administrativo__c WHERE name = 'TEST 0'];
        Territorio_Administrativo__c terr1 = [SELECT id,RiverId_Total_Ciudadanos__c,RiverId_TotEco_Activities__c FROM Territorio_Administrativo__c WHERE name = 'TEST 1'];
        Territorio_Administrativo__c terr2 = [SELECT id,RiverId_Total_Ciudadanos__c,RiverId_TotEco_Activities__c FROM Territorio_Administrativo__c WHERE name = 'TEST 2'];
        Territorio_Administrativo__c terr3 = [SELECT id,RiverId_Total_Ciudadanos__c,RiverId_TotEco_Activities__c FROM Territorio_Administrativo__c WHERE name = 'TEST 3'];
        Territorio_Administrativo__c terr4_1 = [SELECT id,RiverId_Total_Ciudadanos__c,RiverId_TotEco_Activities__c FROM Territorio_Administrativo__c WHERE name = 'TEST 4_1'];
        Territorio_Administrativo__c terr4_2 = [SELECT id,RiverId_Total_Ciudadanos__c,RiverId_TotEco_Activities__c FROM Territorio_Administrativo__c WHERE name = 'TEST 4_2'];

        System.assertEquals(10, terr4_1.RiverId_Total_Ciudadanos__c, 'Se le crearon 10 ciudadanos de river al territorio 4_1');
        System.assertEquals(2, terr4_2.RiverId_Total_Ciudadanos__c, 'Se le crearon 2 ciudadanos de river al territorio 4_2');

        System.assertEquals(12, terr3.RiverId_Total_Ciudadanos__c, 'El nivel 3 debe agrupar los ciudadanos del nivel 4, para un total de 12 ciudadanos.');
        System.assertEquals(12, terr2.RiverId_Total_Ciudadanos__c, 'Como no hay divisiones, el nivel 2 tiene que tener los mismos ciudadanos que el nivel 3.');
        System.assertEquals(12, terr1.RiverId_Total_Ciudadanos__c, 'Como no hay divisiones, el nivel 1 tiene que tener los mismos ciudadanos que el nivel 2.');
        System.assertEquals(12, terr0.RiverId_Total_Ciudadanos__c, 'Como no hay divisiones, el nivel 0 tiene que tener los mismos ciudadanos que el nivel 1.');

        Map<String, Integer> cuentaActividades0 = (Map<String, Integer>) JSON.deserialize(terr0.RiverId_TotEco_Activities__c, Map<String, Integer>.class);
        Map<String, Integer> cuentaActividades1 = (Map<String, Integer>) JSON.deserialize(terr1.RiverId_TotEco_Activities__c, Map<String, Integer>.class);
        Map<String, Integer> cuentaActividades2 = (Map<String, Integer>) JSON.deserialize(terr2.RiverId_TotEco_Activities__c, Map<String, Integer>.class);
        Map<String, Integer> cuentaActividades3 = (Map<String, Integer>) JSON.deserialize(terr3.RiverId_TotEco_Activities__c, Map<String, Integer>.class);
        Map<String, Integer> cuentaActividades4_1 = (Map<String, Integer>) JSON.deserialize(terr4_1.RiverId_TotEco_Activities__c, Map<String, Integer>.class);
        Map<String, Integer> cuentaActividades4_2 = (Map<String, Integer>) JSON.deserialize(terr4_2.RiverId_TotEco_Activities__c, Map<String, Integer>.class);

        System.assertEquals(2, cuentaActividades4_2.get('Comercio'), 'En el territorio 4_2 hay solo 2 ciudadanas con actividad comercio');
        System.assertEquals(1, cuentaActividades4_1.get('Comercio'), 'En el territorio 4_1 hay solo 1 ciudadano con actividad comercio');

        System.assertEquals(3, cuentaActividades3.get('Comercio'), 'En los territorios superiores se deben haber acumulado los 3 ciudadanos con comercio');
        System.assertEquals(3, cuentaActividades2.get('Comercio'), 'En los territorios superiores se deben haber acumulado los 3 ciudadanos con comercio');
        System.assertEquals(3, cuentaActividades1.get('Comercio'), 'En los territorios superiores se deben haber acumulado los 3 ciudadanos con comercio');
        System.assertEquals(3, cuentaActividades0.get('Comercio'), 'En los territorios superiores se deben haber acumulado los 3 ciudadanos con comercio');

    }

}