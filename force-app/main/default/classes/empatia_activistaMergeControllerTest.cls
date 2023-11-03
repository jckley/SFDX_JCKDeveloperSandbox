@isTest
public class empatia_activistaMergeControllerTest implements empatia_activistaMergeInterface {
  @TestSetup
  static void makeData() {
    Empatia_Activista__c act1 = new Empatia_Activista__c();
    act1.dni__c = '123456789';
    act1.Fecha_de_nacimiento__c = Date.newInstance(2022, 5, 12);
    insert act1;
  }

  @isTest
  public static void testTransferNotes() {
    Empatia_Activista__c act = new Empatia_Activista__c();
    act.dni__c = '11111111';
    insert act;

    Empatia_Nota__c nota = new Empatia_Nota__c();
    nota.Empatia_Activista__c = act.id;
    insert nota;

    Empatia_Nota__c nota2 = new Empatia_Nota__c();
    nota2.Empatia_Activista__c = act.id;
    insert nota2;

    Empatia_Activista__c newAct = [SELECT id FROM Empatia_Activista__c where dni__c = '123456789'];

    Test.startTest();
    empatia_activistaMergeController.transferNotesToNewActivista(act.id, newAct.id);
    Test.stopTest();

    Empatia_Activista__c newAct_conNotas = [SELECT id, (SELECT id FROM Empatia_Notas__r) FROM Empatia_Activista__c where dni__c = '123456789'];

    System.assertEquals(2, newAct_conNotas.Empatia_Notas__r.size(), 'Las 2 notas del activista original debe haber cambiado al nuevo');

  }

  @isTest
  public static void testTransferEmpatias() {
    Empatia_Activista__c act = new Empatia_Activista__c();
    act.dni__c = '11111111';
    insert act;

    Empatia__c empatia = new Empatia__c();
    empatia.DNI__c = '11111111';
    empatia.Email__c = 'test@test.com';
    empatia.Response_Token__c = 'test1';

    insert empatia;

    Empatia__c empatia2 = new Empatia__c();
    empatia2.DNI__c = '11111111';
    empatia2.Email__c = 'testCambioRandom@test.com';
    empatia2.Response_Token__c = 'test2';

    insert empatia2;

    Empatia_Activista__c newAct = [SELECT id FROM Empatia_Activista__c where dni__c = '123456789'];

    Test.startTest();
    empatia_activistaMergeController.transferEmpatiasToNewActivista(act.id, newAct.id);
    Test.stopTest();

    Empatia_Activista__c newAct_conNotas = [SELECT id, (SELECT id FROM Empatias__r) FROM Empatia_Activista__c where dni__c = '123456789'];

    System.assertEquals(2, newAct_conNotas.Empatias__r.size(), 'Las 2 encuestas se deben haber asociado al otro activista');
  }

  @isTest
  public static void changeRecordTo_NotExistingIdentificador() {
    Empatia_Activista__c act = new Empatia_Activista__c();
    act.dni__c = '11111111';
    act.Fecha_de_nacimiento__c = Date.newInstance(1997, 5, 12);

    insert act;
    
    //cambio el dni al del otro activista, pero la fecha de nacimiento no, se mantien diferente! Asi que no tiene que mergear, tiene que updatear.
    Test.startTest();
    String results = empatia_activistaMergeController.changeActivistaInfo(act.id, '123456789',act.Fecha_de_nacimiento__c, 'empatia_activistaMergeControllerTest');
    Test.stopTest();

    System.assertEquals(
      '{"operationType":"update"}',
      results,
      'El controller debe ejecutra el metodo updateExistingRecord de la clase inyectada ya que la combinacion de DNI y fecha ingresada no existe en otro activista en la base de datos.'
    );
  }

  @isTest
  public static void changeRecordTo_ExistingIdentificador() {
    Empatia_Activista__c act = new Empatia_Activista__c();
    act.dni__c = '11111111';
    act.Fecha_de_nacimiento__c = Date.newInstance(1997, 5, 12);

    insert act;

    //cambio fecha y dni para que coincidan con el existente
    Test.startTest();
    String results = empatia_activistaMergeController.changeActivistaInfo(act.id, '123456789',Date.newInstance(2022, 5, 12), 'empatia_activistaMergeControllerTest');
    Test.stopTest();

    System.assertEquals(
      '{"operationType":"merge", "activistaId":"placeHolder"}',
      results,
      'El controller debe ejecutar el metodo updateExistingRecord de la clase inyectada ya que el DNI y la fechas ingresdas son los mismos del otro activista.'
    );
  }

  @isTest
  public static void mergeRecord() {
    Empatia_Activista__c act = new Empatia_Activista__c();
    act.dni__c = '11111111';
    insert act;

    Empatia_Activista__c newAct = [SELECT id FROM Empatia_Activista__c where dni__c = '123456789'];

    Test.startTest();
    String results = empatia_activistaMergeController.mergeRecord(act.id, newAct.id);
    Test.stopTest();
  }

  @isTest
  public static void updateRecord() {
    Empatia_Activista__c act = new Empatia_Activista__c();
    act.dni__c = '11111111';
    act.Fecha_de_nacimiento__c = Date.newInstance(1997, 5, 12);
    insert act;

    Test.startTest();
    String results = empatia_activistaMergeController.updateExistingRecord(act.id, '2222222222', Date.newInstance(1970, 1, 1));
    Test.stopTest();
  }

  @isTest
  public static void searchCitizen() {
    Contact ct = new Contact ();
    ct.LastName = 'test';
    ct.guid__c = '11111';
    ct.Document_Number__c = '123456789';
    ct.Birthdate = Date.newInstance(1985, 5, 12);

    insert ct;

    Test.startTest();
    Contact results = empatia_activistaMergeController.searchCitizen('11111', Date.newInstance(1985, 5, 12));
    Test.stopTest();
  }

  public static string updateExistingRecord(String recordId, String dni, Date fecha) {
    return '{"operationType":"update"}';
  }

  public static string mergeRecord(String oldActivistaId, String newActivistaId) {
    return '{"operationType":"merge", "activistaId":"placeHolder"}';
  }
}