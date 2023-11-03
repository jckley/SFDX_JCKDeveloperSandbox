@isTest
public class Empatia_ActivistaTriggerTEST {
  @TestSetup
  public static void makeData() {
    Contact ct = new Contact();
    ct.LastName = 'test';
    ct.guid__c = '11111';
    ct.Document_Number__c = '123456789';
    ct.Birthdate = Date.newInstance(1985, 5, 12);

    insert ct;
  }

  @isTest
  public static void testInsert() {
    Empatia_Activista__c act = new Empatia_Activista__c();
    act.dni__c = '123456789';
    act.fecha_de_nacimiento__c = Date.newInstance(1985, 5, 12);

    Test.startTest();
    insert act;
    Test.stopTest();

    Empatia_Activista__c actInserted = [SELECT id, citizen__c FROM Empatia_Activista__c WHERE id = :act.id];

    Contact expectedContact = [SELECT id FROM contact WHERE Document_Number__c = :act.dni__c AND Birthdate = :act.fecha_de_nacimiento__c];

    System.assertEquals(
      expectedContact.id,
      actInserted.citizen__c,
      'El activista debe tener el lookup completo con el citizen matcheado por DNI y fecha de nacimiento'
    );
  }

  @isTest
  public static void testUpdate() {
    Empatia_Activista__c act = new Empatia_Activista__c();
    act.dni__c = '111111111';
    act.fecha_de_nacimiento__c = Date.newInstance(1985, 5, 12);
    insert act;

    Empatia_Activista__c actInserted = [SELECT id, citizen__c FROM Empatia_Activista__c WHERE id = :act.id];

    System.assertEquals(
      null,
      actInserted.citizen__c,
      'El activista debe tener el lookup en blanco, ya que no hay ninguna combinacion de DNI y fecha coincidente'
    );

    Test.startTest();
    act.dni__c = '123456789';
    update act;
    Test.stopTest();

    Empatia_Activista__c actUpdated = [SELECT id, citizen__c FROM Empatia_Activista__c WHERE id = :act.id];

    Contact expectedContact = [SELECT id FROM contact WHERE Document_Number__c = :act.dni__c AND Birthdate = :act.fecha_de_nacimiento__c];

    System.assertEquals(
      expectedContact.id,
      actUpdated.citizen__c,
      'En el update con un DNI existente (la fecha ya coincidia), se debe haber completado el lookup del activista al citizen.'
    );
  }
}