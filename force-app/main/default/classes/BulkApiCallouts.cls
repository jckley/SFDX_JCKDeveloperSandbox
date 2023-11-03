public class BulkApiCallouts {

  final static Integer CREATEJOB_EXPECTED_CODE = 200;
  final static Integer UPLOADCSV_EXPECTED_CODE = 201;
  final static Integer STARTJOB_EXPECTED_CODE = 200;


  public static string createJob() {
    Http h = new Http();
    String url = 'callout:BulkApi' + '/services/data/v53.0/jobs/ingest/';

    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');

    String body = '{"object" : "Contact","externalIdFieldName" : "guid__c","contentType" : "CSV","operation" : "upsert","lineEnding" : "LF"}';

    req.setBody(body);
    
    HttpResponse res = h.send(req);

    System.debug('POST REQUEST, createJob,' +  res.toString());

    if(res.getStatusCode() != CREATEJOB_EXPECTED_CODE){
      CalloutException e = new CalloutException();
      e.setMessage('createJob ex: ' + res.getStatus() + ' - ' + res.getBody());
      throw e;
    }

    Map<String, String> responseMap = (Map<String, String>) JSON.deserialize(res.getBody(), Map<String, String>.class);

    return (String) responseMap.get('id');
  }

  public static void uploadCsv(String ingestJobId, String body) {
    Http h = new Http();
    String url = 'callout:BulkApi' + '/services/data/v53.0/jobs/ingest/' + ingestJobId + '/batches';
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('PUT');
    req.setHeader('Content-Type', 'text/csv');

    req.setBody(body);
    //para testear los timeout
    //req.setTimeout(1);

    HttpResponse res = h.send(req);

    System.debug('PUT REQUEST, upload csv: ' + res.toString());

    if(res.getStatusCode() != UPLOADCSV_EXPECTED_CODE){
      CalloutException e = new CalloutException();
      e.setMessage('uploadCsv ex: ' + res.getStatus() + ' - ' + res.getBody());
      throw e;
    } 
  }

  public static void startJob(String ingestJobId) {
    Http h = new Http();
    String url = 'callout:BulkApi' + '/services/data/v53.0/jobs/ingest/' + ingestJobId;
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('PATCH');
    req.setHeader('Content-Type', 'application/json');

    String body = '{"state":"UploadComplete"}';

    req.setBody(body);

    HttpResponse res = h.send(req);
    System.debug('PATCH REQUEST, start job: ' + res.toString());

    if(res.getStatusCode() != STARTJOB_EXPECTED_CODE){
      CalloutException e = new CalloutException();
      e.setMessage('startJob ex: ' + res.getStatus() + ' - ' + res.getBody());
      throw e;
    } 
  }

  public static void consumeBulkApi (String body) {
    System.debug('ConsumeBulkApi');
    String jobId = BulkApiCallouts.createJob();
    BulkApiCallouts.uploadCsv(jobId, body);
    BulkApiCallouts.startJob(jobId);
  }
}