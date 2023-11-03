@isTest
public class BatchToTriggerFlowsTest {
  @TestSetup
  static void makeData() {
    Contact c1 = new contact();
    c1.guid__c = 'guid1';
    c1.LastName = 'contact1';
    c1.Flow_by_batch_Flag__c = false;

    insert c1;

    Contact c2 = new contact();
    c2.guid__c = 'guid2';
    c2.LastName = 'contact2';
    c2.Flow_by_batch_Flag__c = true;

    insert c2;

    Contact c3 = new contact();
    c3.guid__c = 'guid3';
    c3.LastName = 'excluido';
    c3.Flow_by_batch_Flag__c = false;

    insert c3;
  }

  @isTest
  static void test_batchProcess() {
    List<BatchToTriggerFlow_Query__mdt> testMtd = [SELECT DeveloperName FROM BatchToTriggerFlow_Query__mdt WHERE ConfigToUse__c = 'TEST'];

    System.assertEquals(
      1,
      testMtd.size(),
      'En la org debe estar creada la metadata de test, obtiene todos los contactos y switchea el campo Flow_by_batch_Flag__c'
    );

    Test.startTest();
    Id batchJobId = Database.executeBatch(new BatchToTriggerFlows('TEST'), 200);
    Test.stopTest();
  }

  @isTest
  static void test_makeCalloutsAndNextBatch() {
    String configToUse = 'TEST';
    String mtdFieldToSwitch = 'Flow_by_batch_Flag__c';
    String mtdFromStatement = 'Contact';
    String mtdWhereStatement = 'LastName != \'excluido\'';
    Decimal mtdBatchSizeStatement = 100;
    Id lastRecordReferenceId = null;

    BatchToTriggerFlowsHelper.BatchState batchState = new BatchToTriggerFlowsHelper.BatchState(
      configToUse,
      mtdFieldToSwitch,
      mtdFromStatement,
      mtdWhereStatement,
      mtdBatchSizeStatement, 
      lastRecordReferenceId
    );

    batchState.bodyRows = '"guidTEst123","true"';

    String nextBatchId = BatchToTriggerFlows.makeCalloutsAndNextBatch(batchState);
    System.assert(
        nextBatchId != null,
      'Si bien no hace los callouts porque tenia problemas en el test, se debe lanzar un batch porque para este batchState no se proceso ningun registro y hay 2 creados'
    );
  }

  @isTest
  static void test_handleTimeOutLogic_withRetry() {
    String configToUse = 'TEST';
    String mtdFieldToSwitch = 'Flow_by_batch_Flag__c';
    String mtdFromStatement = 'Contact';
    String mtdWhereStatement = null;
    Decimal mtdBatchSizeStatement = 100;
    Id lastRecordReferenceId = null;

    BatchToTriggerFlowsHelper.BatchState batchState = new BatchToTriggerFlowsHelper.BatchState(
      configToUse,
      mtdFieldToSwitch,
      mtdFromStatement,
      mtdWhereStatement,
      mtdBatchSizeStatement,
      lastRecordReferenceId
    );

    CalloutException e = new CalloutException();
    e.setMessage('Read timed out');
    String scheduledJobId = BatchToTriggerFlows.handleTimeOutLogic(batchState, e);
    System.assert(
      scheduledJobId != null,
      'Como no tuve retriers previos, y la excepcion es de tipo timeout ' +
      'se debe haber scheduleado un trabajo y tener un id de referencia'
    );
  }
}