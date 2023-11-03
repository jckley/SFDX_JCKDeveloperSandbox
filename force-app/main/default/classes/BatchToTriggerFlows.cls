public class BatchToTriggerFlows implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
  public BatchToTriggerFlowsHelper.BatchState batchState;

  public BatchToTriggerFlows(String configToUse, Id lastRecordReferenceId) {
    List<BatchToTriggerFlow_Query__mdt> mtd = [
      SELECT WHERE_statement__c, FROM_statement__c, Batch_Size__c, FlagField__c
      FROM BatchToTriggerFlow_Query__mdt
      WHERE ConfigToUse__c = :configToUse
    ];

    String mtdFieldToSwitch = mtd[0].FlagField__c;
    String mtdFromStatement = mtd[0].FROM_statement__c;
    String mtdWhereStatement = mtd[0].WHERE_statement__c;
    Decimal mtdBatchSizeStatement = mtd[0].Batch_Size__c;

    this.batchState = new BatchToTriggerFlowsHelper.BatchState(
      configToUse,
      mtdFieldToSwitch,
      mtdFromStatement,
      mtdWhereStatement,
      mtdBatchSizeStatement,
      lastRecordReferenceId
    );
  }

  public BatchToTriggerFlows(String configToUse) {
    this(configToUse, null);
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug(this.batchState.lastRecordReferenceId);

    List<String> queryList = new List<String>();

    queryList.add(BatchToTriggerFlowsHelper.makeSelectStatement(this.batchState.mtdFieldToSwitch));
    queryList.add(BatchToTriggerFlowsHelper.makeFromStatement(this.batchState.mtdFromStatement));
    queryList.add(BatchToTriggerFlowsHelper.makeWhereStatement(this.batchState.mtdWhereStatement, this.batchState.lastRecordReferenceId));
    queryList.add(BatchToTriggerFlowsHelper.makeOrderByStatement());
    queryList.add(BatchToTriggerFlowsHelper.makeLimitStatement(this.batchState.mtdBatchSizeStatement));

    String query = String.join(queryList, ' ');
    this.batchState.bodyRows = '';

    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<sObject> scope) {
    for (sobject thisRecord : scope) {
      Boolean previousValue = (Boolean) thisRecord.get(this.batchState.mtdFieldToSwitch);
      this.batchState.bodyRows = this.batchState.bodyRows + '"' + thisRecord.get('guid__c') + '","' + !previousValue + '"\n';
      this.batchState.lastRecordReferenceId = thisRecord.id > this.batchState.lastRecordReferenceId
        ? thisRecord.id
        : this.batchState.lastRecordReferenceId;
    }
  }

  public void finish(Database.BatchableContext BC) {
    /*Para gestionar correctamente el proceso de las callouts, hay que llevarlo un paso mas alla de tirarle un retry ciego cada X tiempo
    hace falta pasar el Id del ultimo batch, consultar el estado,
    y en funcion del estado, retomar el proceso desde donde quedo... Sera para la vuelta 3 */
    BatchToTriggerFlows.batchFinishLogic(this.batchState);
  }

  public static void batchFinishLogic(BatchToTriggerFlowsHelper.BatchState batchState) {
    try {
      BatchToTriggerFlows.makeCalloutsAndNextBatch(batchState);
    } catch (CalloutException e) {
      BatchToTriggerFlows.handleTimeOutLogic(batchState, e);
    }
  }

  public static String makeCalloutsAndNextBatch(BatchToTriggerFlowsHelper.BatchState batchState) {
    String body = '"guid__c","' + batchState.mtdFieldToSwitch + '"\n' + batchState.bodyRows;

    if (!Test.isRunningTest()) {
      //esto es rarisimo, pero parece que al poner esto aca y ser sincronico
      //tengo conflictos con la creacion de los datos del test.
      //por documentacion no puedo hacer un insert y un callout despues en la misma transaccion
      //pero el insert con el que esto interfiere es el del @testSetup!!!! En el metodo finish, no hay ninguna otra operacion DML
      BulkApiCallouts.consumeBulkApi(body);
    }

    Boolean doAnother = BatchToTriggerFlowsHelper.arePendingBatches(
      batchState.mtdFromStatement,
      batchState.mtdWhereStatement,
      batchState.lastRecordReferenceId
    );

    String nextBatchId;

    if (doAnother) {
      String configParameter = batchState.ConfigToUse;
      Id referenceIdForNextBatch = batchState.lastRecordReferenceId;
      nextBatchId = Database.executeBatch(new BatchToTriggerFlows(configParameter, referenceIdForNextBatch), 2000);
    }

    return nextBatchId;
  }

  public static String handleTimeOutLogic(BatchToTriggerFlowsHelper.BatchState batchState, CalloutException e) {
    System.debug('Exception chached');
    if (e.getMessage() != 'Read timed out' || batchState.retriedTimes > 2) {
      throw e;
    }
    batchState.retriedTimes++;
    BatchToTriggerFlowsScheduler scheduledJob = new BatchToTriggerFlowsScheduler(batchState);
    Datetime sysTime = System.now().addSeconds(10 * 60);
    String chron = BatchToTriggerFlowsHelper.makeChronFromDateTime(sysTime);
    String name = 'RetriedTimes' + batchState.retriedTimes + ' - ' + chron;
    String scheduledJobId = System.schedule(name, chron, scheduledJob);
    return scheduledJobId;
  }
}