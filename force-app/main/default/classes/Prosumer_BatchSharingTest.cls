@isTest
public with sharing class Prosumer_BatchSharingTest {
  @TestSetup
  static void makeData() {
    Contact c1 = new contact();
    c1.guid__c = 'guid1';
    c1.LastName = 'contact1';
    c1.Prosumer_Sharing_Accts__c = '-b5';
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

    Account prosumerAcc = new Account();
    prosumerAcc.name = 'prosumer1';
    prosumerAcc.Prosumer_Sharing_Id__c = 'a1';
    prosumerAcc.Sharing_Criteria__c = 'lastname != \'excluido\'';

    insert prosumerAcc;
  }

  @isTest
  static void test_batchProcess() {
    Account prosumerAcc = [SELECT name, Prosumer_Sharing_Id__c, Sharing_Criteria__c FROM account WHERE name = 'prosumer1'];

    Test.startTest();
    Prosumer_BatchSharing batch = new Prosumer_BatchSharing(prosumerAcc.id);
    Id batchJobId = Database.executeBatch(batch, 2000);
    Test.stopTest();
    
    String expectedUpdateForTheBulkApi = '"guid__c","Prosumer_Sharing_Accts__c"\n"guid1","-b5-a1"\n"guid2","-a1"\n';

    //parece que esto funciona de la siguiente manera, yo instancio la clase de batch y la paso a executeBatch
    //pero executeBatch, lo que hace es crear una copia, y correr sobre una instancia diferente a la que guarde en la variable en la linea anterior,
    //por eso si trato de ver batch.batchState.bodyRows esta vacio...
    System.assertEquals(expectedUpdateForTheBulkApi, Prosumer_BatchSharing.testBulkApiCallBody, 'Req body incorrecto');

    //el formato esperado para el body es:
    //Se espera que el body de la request a la bulk api, sea un csv. La primer fila con los nombres de los campos.
    //Luego una fila para cada contacto evaluado (2 de los 3 por la query), donde se agreguen a los valores existentes en el campo Prosumer_Sharing_Accts__c los nuevos prosumers ids separados por un guion
  }

  @isTest
  static void test_makeCalloutsAndNextBatch() {
    Account prosumerAcc = [SELECT name, Prosumer_Sharing_Id__c, Sharing_Criteria__c FROM account WHERE name = 'prosumer1'];

    Prosumer_BatchHelper.BatchState batchState = new Prosumer_BatchHelper.BatchState(
      prosumerAcc.id,
      prosumerAcc.Sharing_Criteria__c,
      prosumerAcc.Prosumer_Sharing_Id__c,
      null
    );

    batchState.bodyRows = '"guidTEst123","true"';

    String nextBatchId = Prosumer_BatchSharing.makeCalloutsAndNextBatch(batchState);
    System.assert(
      nextBatchId != null,
      'Si bien no hace los callouts porque tenia problemas en el test, se debe lanzar un batch porque para este batchState no se proceso ningun registro y hay 2 creados'
    );
  }

  @isTest
  static void test_handleTimeOutLogic_withRetry() {
    Account prosumerAcc = [SELECT name, Prosumer_Sharing_Id__c, Sharing_Criteria__c FROM account WHERE name = 'prosumer1'];

    Prosumer_BatchHelper.BatchState batchState = new Prosumer_BatchHelper.BatchState(
      prosumerAcc.id,
      prosumerAcc.Sharing_Criteria__c,
      prosumerAcc.Prosumer_Sharing_Id__c,
      null
    );

    batchState.bodyRows = '"guidTEst123","true"';

    CalloutException e = new CalloutException();
    e.setMessage('Read timed out');
    String scheduledJobId = Prosumer_BatchSharing.handleTimeOutLogic(batchState, e, null);
    System.assert(
      scheduledJobId != null,
      'Como no tuve retriers previos, y la excepcion es de tipo timeout ' +
      'se debe haber scheduleado un trabajo y tener un id de referencia'
    );
  }
}