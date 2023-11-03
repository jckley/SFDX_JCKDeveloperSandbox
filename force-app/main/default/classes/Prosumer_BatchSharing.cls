public class Prosumer_BatchSharing implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
  @TestVisible Prosumer_BatchHelper.BatchState batchState;
  Id offsetInputId;

  //esta esta solo por para verificar el body que se enviaria a la api
  @TestVisible static String testBulkApiCallBody;

  public Prosumer_BatchSharing(Id accId) {
    this(accId, null);
  }

  public Prosumer_BatchSharing(Id accId, Id lastRecordId) {
    Account acc = [SELECT Prosumer_Sharing_Id__c, Sharing_Criteria__c FROM Account WHERE id = :accId];

    this.batchState = new Prosumer_BatchHelper.BatchState(accId, acc.Sharing_Criteria__c, acc.Prosumer_Sharing_Id__c, lastRecordId);
    this.offsetInputId = lastRecordId;
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    //make query

    List<String> queryList = new List<String>();
    queryList.add('SELECT id FROM Contact');
    queryList.add(Prosumer_BatchHelper.makeWhereStatement(null, this.batchState.lastRecordReferenceId));
    queryList.add('ORDER BY id ASC LIMIT 100000');

    String query = String.join(queryList, ' ');
    this.batchState.bodyRows = '';
    System.debug('The query for the batch: '  + query);
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<contact> scope) {
    Set<Id> thisScopeIds = new Set<Id> ();

    for (Contact thisRecord : scope) {
      thisScopeIds.add(thisRecord.id);
      this.batchState.lastRecordReferenceId = thisRecord.id > this.batchState.lastRecordReferenceId
      ? thisRecord.id
      : this.batchState.lastRecordReferenceId;
    }

    List<String> queryList = new List<String>();
    queryList.add('SELECT id, guid__c, Prosumer_Sharing_Accts__c FROM Contact');
    queryList.add(Prosumer_BatchHelper.makeWhereStatement(this.batchState.accSharingCriteria, null));
    queryList.add('AND id IN: thisScopeIds');

    String query = String.join(queryList, ' ');

    List<Contact> newFilteredScope = (List<Contact>) Database.query(query);

    for (Contact thisRecord : newFilteredScope) {
      String previousValue = thisRecord.Prosumer_Sharing_Accts__c;
      if (previousValue == null) {
        previousValue = '';
      }

      String newValue = previousValue + '-' + this.batchState.accProsumerId;

      this.batchState.bodyRows = this.batchState.bodyRows + '"' + thisRecord.get('guid__c') + '","' + newValue + '"\n';
      this.batchState.recordsToUpdate = this.batchState.recordsToUpdate + 1;
    }
  }

  public void finish(Database.BatchableContext BC) {
    Prosumer_BatchSharing.batchFinishLogic(this.batchState, this.offsetInputId);
  }

  public static void batchFinishLogic(Prosumer_BatchHelper.BatchState batchState, Id offsetInputId) {
    try {
        Prosumer_BatchSharing.makeCalloutsAndNextBatch(batchState);
    } catch (CalloutException e) {
        Prosumer_BatchSharing.handleTimeOutLogic(batchState, e, offsetInputId);
    }
  }

  public static String makeCalloutsAndNextBatch(Prosumer_BatchHelper.BatchState batchState) {
    String body = '"guid__c","Prosumer_Sharing_Accts__c"\n' + batchState.bodyRows;
    if (Test.isRunningTest()) {
      //para poder acceder a la variable de instancia, sin refactorizar, es necesario parasarla a estatica, por como funciona el database.executeBatch
      //mas info en el test
      testBulkApiCallBody = body;
    }
    if (!Test.isRunningTest() && batchState.recordsToUpdate != 0) {
      BulkApiCallouts.consumeBulkApi(body);
    }

    String whereStatement = Prosumer_BatchHelper.makeWhereStatement(null, batchState.lastRecordReferenceId);

    Boolean doAnother = Prosumer_BatchHelper.arePendingBatches(whereStatement);
    

    String nextBatchId;

    if (doAnother) {
      Id accRecordId = batchState.accRecordId;
      Id referenceIdForNextBatch = batchState.lastRecordReferenceId;
      nextBatchId = Database.executeBatch(new Prosumer_BatchSharing(accRecordId, referenceIdForNextBatch), 2000);
    }

    return nextBatchId;
  }
  
  public static String handleTimeOutLogic(Prosumer_BatchHelper.BatchState batchState, CalloutException e, Id offsetInputId) {
    sendFeedbackEmail(batchState, e, offsetInputId);
    if (e.getMessage() != 'Read timed out' || batchState.retriedTimes > 2) {
      throw e;
    }
    batchState.retriedTimes++;
    
    Prosumer_BatchScheduler scheduledJob = new Prosumer_BatchScheduler(batchState, offsetInputId);
    Datetime sysTime = System.now().addSeconds(10 * 60);
    String chron = Prosumer_BatchHelper.makeChronFromDateTime(sysTime);
    String name = 'RetriedTimes' + batchState.retriedTimes + ' - ' + chron;
    String scheduledJobId = System.schedule(name, chron, scheduledJob);
    return scheduledJobId;
  }

  public static void sendFeedbackEmail (Prosumer_BatchHelper.BatchState batchState, CalloutException e, Id offsetInputId) {
    String subjectText = 'Hubo un problema con el batch sobre los sharing de Prosumer, cuenta id: ' + batchState.accRecordId;
    String bodyText;
    if (offsetInputId == null) {
        bodyText = 'El problema estuvo en el primer batch que se intento ejecutar. Desde el registro inicial devuelto por la query hasta: ' + batchState.lastRecordReferenceId + '\n';
    } else {
        bodyText = 'El problema estuvo en el batch que intento procesar los regsitros desde: ' + offsetInputId + ' hasta ' + batchState.lastRecordReferenceId + '\n';
    }
    bodyText = bodyText + 'Hubo una excepcion: ' + e.getMessage();
    Prosumer_BatchHelper.sendEmailToAccountOwner(batchState.accRecordId, subjectText, bodyText);
  } 
}