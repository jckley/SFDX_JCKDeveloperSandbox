@IsTest
private class EmpatiaTriggerTest {
  @TestSetup
  static void makeData() {
    Empatia_Activista__c act = new Empatia_Activista__c();
    act.dni__c = '123456789';
    act.fecha_de_nacimiento__c = date.newinstance(2022, 1, 15);
    insert act;
  }

  @isTest
  public static void addMultipleEmpatiaRecordsWithTheSameId_newActivista() {
    List<Empatia__c> empatias = new List<Empatia__c>();

    String testDNI = '111111111111';
    Date nacimiento = date.newinstance(2022, 12, 22);

    for (Integer i = 0; i < 10; i++) {
      String thisEmpatiaResponseToken = 'token' + i;
      empatias.add(
        new Empatia__c(
          DNI__c = testDNI,
          Email__c = 'test@test.com',
          Response_Token__c = thisEmpatiaResponseToken,
          fecha_de_nacimiento__c = nacimiento
        )
      );
    }

    Test.startTest();
    insert empatias;
    Test.stopTest();

    List<Empatia_Activista__c> activistas = [SELECT id FROM Empatia_Activista__c WHERE dni__c = :testDNI];

    System.assertEquals(
      1,
      activistas.size(),
      'Independientemente de la cantidad de registros de empatia creados, ' +
      'se debe crear 1 solo registro de activista para esa convinacion de DNI con fecha de nacimiento'
    );

    List<Empatia__c> empatiasActualizadas = [SELECT id, Empatia_Activista__c FROM Empatia__c WHERE dni__c = :testDNI];

    for (Empatia__c thisEmpatia : empatiasActualizadas) {
      System.assertEquals(
        activistas[0].id,
        thisEmpatia.Empatia_Activista__c,
        'Los registros de empatia creados con el mismo dni deben estar asociados al mismo activista'
      );
    }
  }

  @isTest
  public static void addMultipleEmpatiaRecordsWithTheSameId_ActivistaExistente() {
    List<Empatia__c> empatias = new List<Empatia__c>();

    String testDNI = '123456789';
    Date testFecha = date.newinstance(2022, 1, 15);

    for (Integer i = 0; i < 10; i++) {
      String thisEmpatiaResponseToken = 'token' + i;
      empatias.add(
        new Empatia__c(DNI__c = testDNI, Email__c = 'test@test.com', Response_Token__c = thisEmpatiaResponseToken, fecha_de_nacimiento__c = testFecha)
      );
    }

    Test.startTest();
    insert empatias;
    Test.stopTest();

    List<Empatia_Activista__c> activistas = [SELECT id FROM Empatia_Activista__c WHERE dni__c = :testDNI];

    System.assertEquals(1, activistas.size(), 'Si ya existia el activista, no deben crearse activistas nuevos');

    List<Empatia__c> empatiasActualizadas = [SELECT id, Empatia_Activista__c FROM Empatia__c WHERE dni__c = :testDNI];

    for (Empatia__c thisEmpatia : empatiasActualizadas) {
      System.assertEquals(
        activistas[0].id,
        thisEmpatia.Empatia_Activista__c,
        'Los registros de empatia creados con la misma convinacion de dni y fecha deben estar asociados al mismo activista'
      );
    }
  }

  @isTest
  public static void addMultipleEmpatiaRecordsWithDiferentBirdates_multipleActivistaCreations() {
    List<Empatia__c> empatias = new List<Empatia__c>();

    String testDNI = '1111111111';
    Date testFecha = date.newinstance(2022, 1, 15);

    for (Integer i = 0; i < 10; i++) {
      String thisEmpatiaResponseToken = 'token' + i;
      empatias.add(
        new Empatia__c(
          DNI__c = testDNI,
          Email__c = 'test@test.com',
          Response_Token__c = thisEmpatiaResponseToken,
          fecha_de_nacimiento__c = testFecha.addDays(i)
        )
      );
    }

    Test.startTest();
    insert empatias;
    Test.stopTest();

    List<Empatia_Activista__c> activistas = [SELECT id FROM Empatia_Activista__c WHERE dni__c = :testDNI];
    Map<Id, Empatia_Activista__c> activistasById = new Map<Id, Empatia_Activista__c>(activistas);

    System.assertEquals(10, activistas.size(), 'Aunque el dni sea el mismo, deben haberse creado 10 activistas, uno para cada fecha de nacimiento');

    List<Empatia__c> empatiasActualizadas = [SELECT id, Empatia_Activista__c FROM Empatia__c WHERE dni__c = :testDNI];

    for (Empatia__c thisEmpatia : empatiasActualizadas) {
      activistasById.remove(thisEmpatia.Empatia_Activista__c);
    }

    System.assertEquals(0, activistasById.keyset().size(), 'Cada registro de empatia se debe haber completado con un activista diferente');
  }

  @IsTest
  public static void onlyEmpatiaRecordShouldBeValid() {
    Empatia__c emp1 = new Empatia__c();
    emp1.DNI__c = '22222222';
    emp1.Email__c = '222@email.com';
    emp1.Response_Token__c = 'test1';
    emp1.fecha_de_nacimiento__c = Date.newInstance(1971, 5, 9);
    emp1.Fecha_Respuesta__c = Date.newInstance(2022, 12, 17);

    test.startTest();
    insert (emp1);
    test.stopTest();

    Empatia__c emp1Actualizada = [SELECT Respuesta_Valida__c FROM Empatia__c WHERE id = :emp1.id];

    System.assertEquals(
      true,
      emp1Actualizada.Respuesta_Valida__c,
      'El primer registro de empatia para un DNI en particular debe marcarse como Respuesta_Valida__c siempre que tenga una Fecha_Respuesta__c'
    );
  }

  @IsTest
  public static void newestEmpatiaRecordShouldBeValid() {
    Empatia__c emp1 = new Empatia__c();
    emp1.DNI__c = '22222222';
    emp1.Email__c = '222@email.com';
    emp1.Response_Token__c = 'test1';
    emp1.fecha_de_nacimiento__c = Date.newInstance(1971, 5, 9);
    emp1.Fecha_Respuesta__c = Date.newInstance(2020, 1, 1);

    insert (emp1);

    Empatia__c emp1Actualizada = [SELECT Respuesta_Valida__c FROM Empatia__c WHERE id = :emp1.id];

    System.assertEquals(true, emp1Actualizada.Respuesta_Valida__c, 'Este registro deberia estar en TRUE ahora.');

    Empatia__c emp2 = new Empatia__c();
    emp2.DNI__c = '22222222';
    emp2.Email__c = '222@email.com';
    emp2.Response_Token__c = 'test2';
    emp2.fecha_de_nacimiento__c = Date.newInstance(1971, 5, 9);
    emp2.Fecha_Respuesta__c = Date.newInstance(2022, 5, 12);

    test.startTest();
    insert (emp2);
    test.stopTest();

    Empatia__c emp1SegundaActualizacion = [SELECT Respuesta_Valida__c FROM Empatia__c WHERE id = :emp1.id];

    System.assertEquals(
      false,
      emp1SegundaActualizacion.Respuesta_Valida__c,
      'Luego del insert de un segundo registro de empatia, el primero, con una fecha mas vieja, debe dejar de ser la respuesta valida.'
    );

    Empatia__c emp2Actualizada = [SELECT Respuesta_Valida__c FROM Empatia__c WHERE id = :emp2.id];

    System.assertEquals(true, emp2Actualizada.Respuesta_Valida__c, 'El registro de empatia con la fecha mas actual debe ser la respuesta valida');
  }

  @IsTest
  public static void insertedValidEmpatiaShouldOverrideValuesInActivista() {
    Test.startTest();

    Empatia__c emp1 = new Empatia__c();
    emp1.DNI__c = '111111111';
    emp1.Email__c = 'test1@email.com';
    emp1.Response_Token__c = 'test1';
    emp1.fecha_de_nacimiento__c = Date.newInstance(1971, 5, 9);
    emp1.Fecha_Respuesta__c = Date.newInstance(2020, 1, 1);
    emp1.Provincia__c = 'Misiones';
    emp1.Ciudad_Misiones__c = 'Campo Grande';
    emp1.Celular__c = '2345 222222';

    insert emp1;

    Empatia__c emp1WithActivista = [SELECT id, Empatia_activista__c FROM Empatia__c WHERE id = :emp1.id];

    Empatia_activista__c actPrimerInsert = [
      SELECT id, Ciudad__c, Celular__c, Email__c, Provincia__c
      FROM Empatia_activista__c
      WHERE id = :emp1WithActivista.Empatia_activista__c
    ];

    System.assertEquals('Misiones', actPrimerInsert.Provincia__c, 'Se debe haber completado Provincia__c con el registro de la empatia');
    System.assertEquals('Campo Grande', actPrimerInsert.Ciudad__c, 'Se debe haber completado Ciudad__c con el registro de la empatia');
    System.assertEquals('test1@email.com', actPrimerInsert.Email__c, 'Se debe haber completado Email__c con el registro de la empatia');
    System.assertEquals('2345 222222', actPrimerInsert.Celular__c, 'Se debe haber completado Celular__c con el registro de la empatia');

    Empatia__c emp2 = new Empatia__c();
    emp2.DNI__c = '111111111';
    emp2.Response_Token__c = 'test2';
    emp2.fecha_de_nacimiento__c = Date.newInstance(1971, 5, 9);
    emp2.Fecha_Respuesta__c = Date.newInstance(2021, 1, 1);
    emp2.Email__c = 'test2222@email.com';
    emp2.Provincia__c = 'Tucumán';

    insert emp2;

    Empatia__c emp2WithActivista = [SELECT id, Empatia_activista__c FROM Empatia__c WHERE id = :emp2.id];

    Empatia_activista__c actSegundoInsert = [
      SELECT id, Ciudad__c, Celular__c, Email__c, Provincia__c
      FROM Empatia_activista__c
      WHERE id = :emp2WithActivista.Empatia_activista__c
    ];

    System.assertEquals('Tucumán', actSegundoInsert.Provincia__c, 'Se debe haber completado Provincia__c con el segundo registro de  empatia');    
    System.assertEquals('test2222@email.com', actSegundoInsert.Email__c, 'Se debe haber completado Email__c con el segundo registro de empatia');    
    System.assertEquals(null, actSegundoInsert.Celular__c, 'El celular no se cargo en el segundo registro de empatia, se debe borrar en la base de datos');
    System.assertEquals(null, actSegundoInsert.Ciudad__c, 'No se cargo una ciudad en el segundo registro de empatia, se debe borrar en la base de datos');

    Test.stopTest();
  }
}