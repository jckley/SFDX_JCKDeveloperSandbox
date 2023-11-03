/**
 * An apex controller that retrieves polls data for RiverId Community
 */
@IsTest public with sharing class CommunitiesRiverControllerTest {

    @testSetup
    private static void setupTest() {
        createData();
    }

    @IsTest
    public static void CommunitiesRiverControllerTest() {
        Contact con1 = [SELECT RiverId_Nro_socio__c,RiverId_fecha_socio__c,RiverId_cat_socio__c, LastName FROM Contact WHERE LastName = 'Test1'];
        System.debug('name: ' + con1.LastName);
        System.assert(CommunitiesRiverController.retrieveInfoPollsFromCitizenId(con1.Id) <> null);  
        System.assert(CommunitiesRiverController.retrieveInfoPollsFromCitizenId('0031h00000dbtwgxxx') == null);
    }

    private static void createData() {
        Contact con1 = new Contact();
        con1.SearchCriteria__c = '22/01/2001F609';
        con1.LastName = 'Test1';
        con1.guid__c = '1231';
        con1.Birthdate = Date.today();
        con1.Gender__c = 'M';
        con1.Ingreso__c = 'Muy Bajo';
        con1.Education_Level__c = 'Primaro';
        con1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Argentino').getRecordTypeId();
        con1.Is_RiverId_Citizen__c = true;
        insert con1;

        RiverId__c riverId = new RiverId__c();
        riverId.nro_socio__c = 1;
        riverId.riverid_citizen__c = con1.id;
        riverId.name = 'River 1';
        riverId.fecha_socio__c = Date.today();
        riverId.cat_socio__c = 'Cat1';
        insert riverId;

        RiverId_Polls__c poll1 = New RiverId_Polls__c();
        poll1.RiverId_SFID__c = riverId.Id;
        poll1.Abonos__c = 2;
        poll1.Beneficios__c = 4;
        poll1.Estadio__c = 4;
        poll1.Futbol__c = 3;
        poll1.Instalaciones__c = 2;
        poll1.guid__c = con1.guid__c;
        poll1.Fecha_Respuesta__c = Date.newInstance(2022, 4, 3);
        poll1.Token__c = '32132132';
        insert poll1;

        RiverId_Polls__c poll2 = New RiverId_Polls__c();
        poll2.RiverId_SFID__c = riverId.Id;
        poll2.Abonos__c = 3;
        poll2.Beneficios__c = 2;
        poll2.Estadio__c = 5;
        poll2.Futbol__c = 4;
        poll2.Instalaciones__c = 3;
        poll2.guid__c = con1.guid__c;
        poll2.Fecha_Respuesta__c = Date.newInstance(2022, 3, 3);
        poll2.Token__c = '32132132';
        insert poll2;

    }
    
}