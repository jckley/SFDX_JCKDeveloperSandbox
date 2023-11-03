@isTEst
public class RiverIdBatchTest {
    
    @TestSetup
    static void makeData(){
        Territorio_Administrativo__c terr0 = new Territorio_Administrativo__c();
        terr0.Location_UUID__c = 'TEST 0';
        terr0.Nivel_Administrativo__c = 0;
        terr0.Name = 'TEST 0';
        insert terr0;

        Contact con1 = new Contact();
        con1.SearchCriteria__c = '22/01/2001F609';
        con1.LastName = 'Test1';
        con1.guid__c = '1231';
        con1.Territorio_Administrativo__c = terr0.Id;
        con1.Birthdate = Date.today();
        con1.Gender__c = 'M';
        con1.Ingreso__c = 'Muy Bajo';
        con1.Education_Level__c = 'Primaro';
        con1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con1.Is_RiverId_Citizen__c = true;
        insert con1;

        Contact con2 = new Contact();
        con2.SearchCriteria__c = '22/01/2001F609';
        con2.LastName = 'Test2';
        con2.guid__c = '1232';
        con2.Territorio_Administrativo__c = terr0.Id;
        con2.Birthdate = Date.today();
        con2.Gender__c = 'F';
        con2.Ingreso__c = 'Bajo';
        con2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con2.Is_RiverId_Citizen__c = true;
        con2.RiverId_Nro_socio__c = '2';
        con2.RiverId_fecha_socio__c = Date.today().addDays(-10);
        con2.RiverId_cat_socio__c = 'Cat2';
        insert con2;

        List<RiverId__c> riverIds = new List<RiverId__c> ();
        
        RiverId__c riverId = new RiverId__c();

        riverId.nro_socio__c = 1;
        riverId.riverid_citizen__c = con1.id;
        riverId.name = 'River 1';
        riverId.fecha_socio__c = Date.today();
        riverId.cat_socio__c = 'Cat1';

        riverIds.add(riverId);

        riverId = new RiverId__c();

        riverId.nro_socio__c = 20465779;
        riverId.riverid_citizen__c = con2.id;
        riverId.name = 'River 2';
        riverId.fecha_socio__c = Date.today().addDays(-10);
        riverId.cat_socio__c = 'Cat2';

        riverIds.add(riverId);

        insert riverIds;
    }

    @isTest
    public static void testBatch(){
        Test.startTest();
            RiverIdBatch batch = new RiverIdBatch();
            database.executeBatch(batch, 2000);
        Test.stopTest();

        
        Contact con1 = [SELECT RiverId_Nro_socio__c,RiverId_fecha_socio__c,RiverId_cat_socio__c FROM Contact WHERE LastName = 'Test1'];
        Contact con2 = [SELECT RiverId_Nro_socio__c,RiverId_fecha_socio__c,RiverId_cat_socio__c FROM Contact WHERE LastName = 'Test2'];


        System.assertEquals('1', con1.RiverId_Nro_socio__c, 'Contact1, debe tener los valores del RiverId__c relacionado en todos los campos. RiverId_Nro_socio__c == 1');
        System.assertEquals(Date.today(), con1.RiverId_fecha_socio__c, 'Contact1, debe tener los valores del RiverId__c relacionado en todos los campos. RiverId_fecha_socio__c == 1');
        System.assertEquals('Cat1', con1.RiverId_cat_socio__c, 'Contact1, debe tener los valores del RiverId__c relacionado en todos los campos. RiverId_cat_socio__c == 1');

        System.assertEquals('20465779', con2.RiverId_Nro_socio__c, 'El campo RiverId_Nro_socio__c es el unico de contact2 que debe haberse modificado, el valor esperado es: 3');
        System.assertEquals(Date.today().addDays(-10), con2.RiverId_fecha_socio__c, 'Contact2 ya tenia algunos campos completos con los mismos valores que el RiverId__c relacionado. RiverId_fecha_socio__c no debe cambiar');
        System.assertEquals('Cat2', con2.RiverId_cat_socio__c, 'Contact2 ya tenia algunos campos completos con los mismos valores que el RiverId__c relacionado. RiverId_cat_socio__c no debe cambiar');
    }
}