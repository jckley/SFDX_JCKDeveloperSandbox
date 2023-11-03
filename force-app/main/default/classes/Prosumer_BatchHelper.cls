public class Prosumer_BatchHelper {
  public static string makeWhereStatement(String baseWhereStatemnt, Id recordIdReference) {
    List<String> whereStatementList = new List<String>();

    if (baseWhereStatemnt != null &&  baseWhereStatemnt != '') {
      whereStatementList.add('(' + baseWhereStatemnt + ')');
    }

    if (recordIdReference != null) {
      whereStatementList.add('(id > \'' + recordIdReference + '\')');
    }

    if (whereStatementList.size() > 0) {
      return 'WHERE ' + String.join(whereStatementList, ' AND ');
    }

    return null;
  }

  public static boolean arePendingBatches(String whereStatement) {

    List<String> queryParts = new List<String> ();
    queryParts.add('SELECT id FROM Contact');
    queryParts.add(whereStatement);
    queryParts.add('LIMIT 1');

    String pendingRecordsQuery = String.join(queryParts, ' ');

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

  public static void sendEmailToAccountOwner (Id accId, String subject, String body) {

    Account acc = [SELECT id, LastModifiedById FROM account WHERE id=:accId];
    User us = [SELECT email FROM user WHERE id =: acc.LastModifiedById];

    HelperFunctions.sendEmail(us.email, subject, body);
  }

  public class BatchState {
    public String accSharingCriteria;
    public String accProsumerId;
    public Id accRecordId;

    public Id lastRecordReferenceId;
    public Integer retriedTimes;

    public String headersRow;
    public String bodyRows;
    public Integer recordsToUpdate;

    public BatchState(Id accRecordId, String accSharingCriteria, String accProsumerId, Id lastRecordReferenceId) {
      this.accRecordId = accRecordId;
      this.accSharingCriteria = accSharingCriteria;
      this.accProsumerId = accProsumerId;
      this.lastRecordReferenceId = lastRecordReferenceId;
      this.retriedTimes = 0;
      this.recordsToUpdate = 0;
    }
  }
}