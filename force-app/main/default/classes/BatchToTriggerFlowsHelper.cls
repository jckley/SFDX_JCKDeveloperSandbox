public class BatchToTriggerFlowsHelper {
  //query string methods
  public static string makeSelectStatement(String flagField) {
    return 'SELECT id, guid__c, ' + flagField;
  }

  public static string makeFromStatement(String fromObject) {
    return 'FROM ' + fromObject;
  }

  public static string makeWhereStatement(String matadataWhereStament, Id recordIdReference) {
    List<String> whereStatementList = new List<String>();

    if (matadataWhereStament != null) {
      whereStatementList.add('(' + matadataWhereStament + ')');
    }

    if (recordIdReference != null) {
      whereStatementList.add('(id > \'' + recordIdReference + '\')');
    }

    if (whereStatementList.size() > 0) {
      return 'WHERE ' + String.join(whereStatementList, ' AND ');
    }

    return null;
  }

  public static string makeOrderByStatement() {
    //si los id fueran numeros planos, aca la lista va como 1, 2, 3...
    //por eso en el where, tengo que pedir los ids >= idReferencia
    return 'ORDER BY id ASC';
  }

  public static string makeLimitStatement(Decimal metadataDefinedBatchSize) {
    if (metadataDefinedBatchSize != null) {
      return 'LIMIT ' + metadataDefinedBatchSize;
    }

    return 'LIMIT 100000';
  }

  public static boolean arePendingBatches(String mtdFromStatement, String mtdWhereStatement, Id lastRecordReferenceId) {
    String pendingRecordsQuery =
      'SELECT id' +
      ' ' +
      BatchToTriggerFlowsHelper.makeFromStatement(mtdFromStatement) +
      ' ' +
      BatchToTriggerFlowsHelper.makeWhereStatement(mtdWhereStatement, lastRecordReferenceId) +
      ' ' +
      'LIMIT 1';

    List<sObject> pendingRecords = Database.query(pendingRecordsQuery);

    if (pendingRecords.isEmpty()) {
      return false;
    } else {
      return true;
    }
  }

  public static string makeChronFromDateTime(Datetime sysTime) {
    String chronExpression =
      '' +
      sysTime.second() +
      ' ' +
      sysTime.minute() +
      ' ' +
      sysTime.hour() +
      ' ' +
      sysTime.day() +
      ' ' +
      sysTime.month() +
      ' ? ' +
      sysTime.year();
    return chronExpression;
  }

  public class BatchState {
    public final String configToUse;
    public final String mtdFieldToSwitch;
    public final String mtdFromStatement;
    public final String mtdWhereStatement;
    public final Decimal mtdBatchSizeStatement;

    /*
      investigando parecen resultar 2 cosas de aca
          1. si la query locator tiene un order by, los registros que llegan a cada job en el scope, estan ordenados en coeherencia con esa query
          2. los diferentes jobs, son secuenciales
      de lo anterior surge que en teoria, puedo armar la query desde el primer id disponible, limitada a un numero N, y ordenada por id
      luego, cuando se ejecute el ultimo job de ese batch, le podria pasar el ultimo id procesado en ese job al proximo batch
      para utilizarlo en el queryLocartor como putno de partida.
      Esto podria haber sido un offset tmb. Creeeo
    */

    public Id lastRecordReferenceId;
    public Integer retriedTimes;

    public string headersRow;
    public string bodyRows;

    public BatchState(
      String configToUse,
      String mtdFieldToSwitch,
      String mtdFromStatement,
      String mtdWhereStatement,
      Decimal mtdBatchSizeStatement,
      Id lastRecordReferenceId
    ) {
      this.configToUse = configToUse;
      this.mtdFieldToSwitch = mtdFieldToSwitch;
      this.mtdFromStatement = mtdFromStatement;
      this.mtdWhereStatement = mtdWhereStatement;
      this.mtdBatchSizeStatement = mtdBatchSizeStatement;
      this.lastRecordReferenceId = lastRecordReferenceId;
      this.retriedTimes = 0;
    }
  }
}