@isTest
public class Prosumer_BatchHelperTest {
  @isTest
  static void test_makeWhereStatement() {
    Contact c1 = new contact();
    c1.guid__c = 'guid1';
    c1.LastName = 'contact1';
    c1.Flow_by_batch_Flag__c = false;

    insert c1;

    String whereFromMetadata = 'lastName = \'prueba\'';
    Id idLastRecord = c1.id;

    System.assertEquals(null, Prosumer_BatchHelper.makeWhereStatement(null, null), 'Si no tiene parametros, no debe devolver un statement');

    System.assertEquals(
      'WHERE (lastName = \'prueba\')',
      Prosumer_BatchHelper.makeWhereStatement(whereFromMetadata, null),
      'Si tiene un filtro en la metadata, debe agregarlo al WHERE'
    );

    System.assertEquals(
      'WHERE (id > \'' +
      idLastRecord +
      '\')',
      Prosumer_BatchHelper.makeWhereStatement(null, idLastRecord),
      'Si de iteraciones pasadas tengo un Id de referencia, debe agregarlo al WHERE'
    );

    System.assertEquals(
      'WHERE (lastName = \'prueba\') AND (id > \'' +
      idLastRecord +
      '\')',
      Prosumer_BatchHelper.makeWhereStatement(whereFromMetadata, idLastRecord),
      'Debe concatenar filtros de la metadata con filtros debidos a Ids de referencia'
    );
  }

  @isTest
  static void test_arePendingBatches() {
    String whereStatemnet = 'WHERE lastName = \'Test\'';

    System.assertEquals(
      false,
      Prosumer_BatchHelper.arePendingBatches(whereStatemnet),
      'No hay data de test, asi que no debe haber batches pendientes'
    );
  }

  @isTest
  static void test_makeChronFromDateTime() {
    Integer year = 2020;
    Integer month = 12;
    Integer day = 5;
    Integer hour = 3;
    Integer minute = 27;
    Integer second = 44;

    Datetime sysTime = Datetime.newInstance(year, month, day, hour, minute, second);

    String chroneExpected = '44 27 3 5 12 ? 2020';

    System.assertEquals(
      chroneExpected,
      Prosumer_BatchHelper.makeChronFromDateTime(sysTime),
      'Debe armar una chron, fromato ss mm hh dd mm ? yyyy'
    );
  }

  @isTest
  static void test_BatchStateConstructor() {
    String accProsumerId = 'ASD123';
    String accSharingCriteria = 'field__c != null';
    Id accRecordId = null;
    Id lastRecordReferenceId = null;

    new Prosumer_BatchHelper.BatchState(accRecordId, accSharingCriteria, accProsumerId, lastRecordReferenceId);
  }

  @isTest
  static void test_SendEmail() {
    Account acc = new Account (name='TestAcc');
    insert acc;
    Prosumer_BatchHelper.sendEmailToAccountOwner(acc.id, 'testSubject','testBody');
  }

}