@isTest
public with sharing class empatiaControllerTest {
  @TestSetup
  static void makeData() {
    Contact ct = new Contact();
    ct.LastName = 'test';
    ct.guid__c = '11111';
    ct.Document_Number__c = '123456';

    insert ct;

    Empatia__c empatia = new Empatia__c(
      Apellido__c = 'testApellido',
      Nombre__c = 'testNombre',
      DNI__c = '123456',
      email__c = 'prueba@prueba.com',
      Response_Token__c = 'test2',
      Fecha_Respuesta__c = Date.newInstance(2222, 2, 17)
    );

    insert empatia;
  }

  @isTest
  public static void testRapido_OkCases() {
    Empatia_Activista__c activista = [
      SELECT id
      FROM Empatia_Activista__c
      WHERE dni__C = '123456'
    ];

    Empatia_Nota__c nota = new Empatia_Nota__c(
      Nota__c = 'test cuerpo nota',
      Empatia_Activista__c = activista.Id
    );

    insert nota;

    Empatia__c empRecord = [
      SELECT id, Empatia_Activista__c
      FROM Empatia__c
      WHERE DNI__c = '123456'
    ];

    Test.startTest();
    empatiaController.retrieveActivistaFromId(empRecord.id);
    empatiaController.retrieveNotasFromActivistaFromId(empRecord.id);
    empatiaController.insertNota(
      empRecord.Empatia_Activista__c,
      'test, nueva nota'
    );
    Test.stopTest();
  }

  @isTest
  public static void testRapido_NullRecords() {
    Boolean exepcion = false;
    Test.startTest();
    empatiaController.retrieveActivistaFromId(null);
    empatiaController.retrieveNotasFromActivistaFromId(null);
    Test.stopTest();
  }

  @isTest
  static void createLogTest() {
    Empatia__c empatia = [
      SELECT id, Empatia_Activista__c
      FROM Empatia__c
      WHERE DNI__c = '123456'
    ];

    Test.startTest();
    empatiaController.createLog(empatia.id);
    Test.stopTest();

    List<ActivityLog__c> logs = [ SELECT empatia__c, logSource__c FROM ActivityLog__c];

    System.assertEquals(1, logs.size(), 'Se debe haber creado 1 log.');
    System.assertEquals(empatia.id, logs[0].empatia__c, 'El log debe estar completo con el registro de empatia que se visitó');
    System.assertEquals('CRM', logs[0].logSource__c, 'El log debe estar identificado como generado desde el CRM');
  }
}