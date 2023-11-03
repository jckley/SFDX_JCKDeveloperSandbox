@isTest
public class BatchToTriggerFlowsHelperTest {
  @isTest
  static void test_makeSelectStatement() {
    System.assertEquals(
      'SELECT id, guid__c, lastName',
      BatchToTriggerFlowsHelper.makeSelectStatement('lastName'),
      'Para un campo o lista de campos, el metodo debe devolver un select statement correcto agregando guid__c y id.'
    );
  }

  @isTest
  static void test_makeFromStatement() {
    System.assertEquals(
      'FROM Contact',
      BatchToTriggerFlowsHelper.makeFromStatement('Contact'),
      'Para un objeto, debe armar el FROM correspondiente.'
    );
  }

  @isTest
  static void test_makeWhereStatement() {
    Contact c1 = new contact();
    c1.guid__c = 'guid1';
    c1.LastName = 'contact1';
    c1.Flow_by_batch_Flag__c = false;

    insert c1;

    String whereFromMetadata = 'lastName = \'prueba\'';
    Id idLastRecord = c1.id;

    System.assertEquals(null, BatchToTriggerFlowsHelper.makeWhereStatement(null, null), 'Si no tiene parametros, no debe devolver un statement');

    System.assertEquals(
      'WHERE (lastName = \'prueba\')',
      BatchToTriggerFlowsHelper.makeWhereStatement(whereFromMetadata, null),
      'Si tiene un filtro en la metadata, debe agregarlo al WHERE'
    );

    System.assertEquals(
      'WHERE (id > \'' +
      idLastRecord +
      '\')',
      BatchToTriggerFlowsHelper.makeWhereStatement(null, idLastRecord),
      'Si de iteraciones pasadas tengo un Id de referencia, debe agregarlo al WHERE'
    );

    System.assertEquals(
      'WHERE (lastName = \'prueba\') AND (id > \'' +
      idLastRecord +
      '\')',
      BatchToTriggerFlowsHelper.makeWhereStatement(whereFromMetadata, idLastRecord),
      'Debe concatenar filtros de la metadata con filtros debidos a Ids de referencia'
    );
  }

  @isTest
  static void test_makeOrderByStatement() {
    System.assertEquals('ORDER BY id ASC', BatchToTriggerFlowsHelper.makeOrderByStatement(), 'Siempre debe devolver ORDER BY id ASC');
  }

  @isTest
  static void test_makeLimitStatement() {
    System.assertEquals(
      'LIMIT 250',
      BatchToTriggerFlowsHelper.makeLimitStatement(250),
      'Si se le pasa un numero, debe limitar la query a ese numero'
    );
    System.assertEquals('LIMIT 100000', BatchToTriggerFlowsHelper.makeLimitStatement(null), 'El limite por default debe ser 100000');
  }
  
  @isTest
  static void test_arePendingBatches() {
    String mtdFromStatement = 'Contact';
    String mtdWhereStatement = 'lastName = \'Test\'';
    Id lastRecordReferenceId = null;

    System.assertEquals(
      false,
      BatchToTriggerFlowsHelper.arePendingBatches(mtdFromStatement, mtdWhereStatement, lastRecordReferenceId),
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
      BatchToTriggerFlowsHelper.makeChronFromDateTime(sysTime),
      'Debe armar una chron, fromato ss mm hh dd mm ? yyyy'
    );
  }

  @isTest
  static void test_BatchStateConstructor() {
    String configToUse = 'TEST';
    String mtdFieldToSwitch = 'testFlag__c';
    String mtdFromStatement = 'Object__c';
    String mtdWhereStatement = 'field__c != null';
    Decimal mtdBatchSizeStatement = 100;
    Id lastRecordReferenceId = null;

    new BatchToTriggerFlowsHelper.BatchState(
      configToUse,
      mtdFieldToSwitch,
      mtdFromStatement,
      mtdWhereStatement,
      mtdBatchSizeStatement,
      lastRecordReferenceId
    );
  }
}