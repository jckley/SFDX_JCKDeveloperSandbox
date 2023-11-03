@isTEst
public class PruebaTest {
    /*
    @TestSetup
    static void makeData(){

    }
    */

    @isTest
    public static void getTestEnvialoSimpleCampainIdTest(){
        Account acc = new Account();
        acc.name = 'PROSUMER ADMINS DEFAULT ACCOUNT';
        acc.Prosumer_Envialo_Simple_Preview__c = 'IdDeLaCampañaDeEnvialoSimple';
        insert acc;
        Prueba.getTestEnvialoSimpleCampainId();
    }

    @isTest
    public static void crearCampaniaTest(){

        HttpMock thisTestHttpMock = new HttpMock();
        thisTestHttpMock.res.setHeader('Content-Type', 'application/json');
        thisTestHttpMock.res.setStatusCode(200);

        Map<String, Integer> dataValue = new Map<String, Integer>();
        dataValue.put('id', 555);
        Map<String, Object> responseBody = new Map<String, Object>();
        responseBody.put('data', dataValue);

        thisTestHttpMock.res.setBody(JSON.serialize(responseBody));

        Test.setMock(HttpCalloutMock.class, thisTestHttpMock);
         
        String idEnvialoSimple = Prueba.crearCampania('Nombre de cuenta de test');
        System.assertEquals('555', idEnvialoSimple);
    }

    @isTest
    public static void sendTestEmailTest(){
        Test.setMock(HttpCalloutMock.class, new HttpMock());
        Prueba.sendTestEmail('123','toEmail@test.com');
    }

    @isTest
    public static void addHtmlEmailToCampainTest(){
        Test.setMock(HttpCalloutMock.class, new HttpMock());
        Prueba.addHtmlEmailToCampain('123','<h1>TESTS</h1>', 'fromEmail@test.com', 'fromName');
    }

    @isTest
    public static void updateAccountTEst(){
        Account acc = new Account();
        acc.name = 'PROSUMER ADMINS DEFAULT ACCOUNT';
        acc.Prosumer_Envialo_Simple_Preview__c = 'IdDeLaCampañaDeEnvialoSimple';
        insert acc;
        Prueba.updateAccount(acc.Id,'12345');
    }

    public class HttpMock implements HttpCalloutMock {
        
        HttpResponse res;
        
        public HttpMock() {
            this.res = new HttpResponse();
        }

        public HTTPResponse respond(HTTPRequest req) {
            return this.res;
        }
    }
}