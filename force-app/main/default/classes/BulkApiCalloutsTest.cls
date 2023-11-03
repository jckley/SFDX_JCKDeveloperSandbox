@isTest
public class BulkApiCalloutsTest {
  @isTest
  static void test_callouts() {
    Test.setMock(HttpCalloutMock.class, new OkMock());

    Test.startTest();
    BulkApiCallouts.consumeBulkApi('"Id"\n"123"');
    Test.stopTest();
  }

  @isTest
  static void test_errors() {
    Test.setMock(HttpCalloutMock.class, new ErrorMock());

    Test.startTest();
    try {
      BulkApiCallouts.createJob();
    } catch (CalloutException e) {
      System.assertEquals(
        'createJob ex: Error del server - {body error}',
        e.getMessage(),
        'Una respuesta erronea debe arrojar una excepcion de dudoso formato...' +
        ' Pero que ayuda a ver los errores en el panel de los batchs!'
      );
    }
    try {
      BulkApiCallouts.uploadCsv('jobid', 'csv');
    } catch (CalloutException e) {
      System.assertEquals(
        'uploadCsv ex: Error del server - {body error}',
        e.getMessage(),
        'Una respuesta erronea debe arrojar una excepcion de dudoso formato...' +
        ' Pero que ayuda a ver los errores en el panel de los batchs!'
      );
    }
    try {
      BulkApiCallouts.startJob('jobid');
    } catch (CalloutException e) {
      System.assertEquals(
        'startJob ex: Error del server - {body error}',
        e.getMessage(),
        'Una respuesta erronea debe arrojar una excepcion de dudoso formato...' +
        ' Pero que ayuda a ver los errores en el panel de los batchs!'
      );
    }

    Test.stopTest();
  }

  private class OkMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      String jobId = '123456789';
      HTTPResponse res;
      //createJob
      if (req.getEndpoint().endsWith('jobs/ingest/')) {
        res = new HTTPResponse();
        res.setBody('{"id":"' + jobId + '"}');
        res.setStatusCode(200);
      }
      //uploadJob
      if (req.getEndpoint().endsWith('jobs/ingest/' + jobId + '/batches')) {
        res = new HTTPResponse();
        res.setStatusCode(201);
      }
      //startJob
      if (req.getEndpoint().endsWith('jobs/ingest/' + jobId)) {
        res = new HTTPResponse();
        res.setStatusCode(200);
      }
      return res;
    }
  }

  private class ErrorMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(400);
      res.setStatus('Error del server');
      res.setBody('{body error}');
      return res;
    }
  }
}