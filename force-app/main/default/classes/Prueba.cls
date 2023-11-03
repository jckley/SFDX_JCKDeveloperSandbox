public class Prueba {
  /*
    Primera iteracion del flujo para mandar una campaña de mail.
    Sin estar seguro que funcionalidad es interesante tener mas alla de hacer los api calls y que se envie.
    Prefiero poner todas las api calls todas juntas. Despues, si vemos que hace falta alguna cosa especifica,
    se puede extraer la logica a otras clases pensando en algun requerimiento particular.
  */

  @AuraEnabled
  public static boolean enviarPrueba(String emailAddress, String fromEmail, String fromName, String htmlEmail) {
    String envialoSimpleCampainId = getTestEnvialoSimpleCampainId();
    System.debug(envialoSimpleCampainId);
    addHtmlEmailToCampain(envialoSimpleCampainId, htmlEmail, fromEmail, fromName);
    sendTestEmail(envialoSimpleCampainId, emailAddress);
    //por ahora lo pongo aca, pero hay que ver bien como conviene manejarlo. El punto es que apex no permite el siguiente orden:
    // httpReq ----> operacion DML ----> httpReq    
    updateAccount(Prosumer_AudienciaPageController.getAccountFromUser(), envialoSimpleCampainId);
    return true;
  }


  //envialo simple necesita tener la campaña creada para enviar un msj de prueba.
  //la idea va a ser definir 1 sola campaña de preview por cuenta
  //si no existe se crea (aca hay que ver donde guardar el id asociado a la cuenta)
  //una vez tenemos el id, editar el body, subject, etc y recien ahi enviar

  public static string getTestEnvialoSimpleCampainId() {
    Id salesforceAccountId = Prosumer_AudienciaPageController.getAccountFromUser();
    Account acc = [SELECT id, name, Prosumer_Envialo_Simple_Preview__c FROM account WHERE id = :salesforceAccountId];
    if (acc.Prosumer_Envialo_Simple_Preview__c != null) {
      return acc.Prosumer_Envialo_Simple_Preview__c;
    }

    String campainId = crearCampania(acc.name);

    return campainId;
  }

  public static string crearCampania(String accName) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:EnvialoSimple/v1/campaign/create');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');

    Map<String, Object> requestBodyMap = new Map<String, Object>();
    //CampaniaTestNombreCuenta
    requestBodyMap.put('name', 'PRS Test -' + accName);
    //Test de la campaña - nombre cuenta
    requestBodyMap.put('subject', 'Test de campaña para ' + accName);

    String requestBodyJsonString = JSON.serialize(requestBodyMap);

    req.setBody(requestBodyJsonString);
    Http http = new Http();
    HTTPResponse res = http.send(req);

    System.debug('crearCampania res: ' + res);

    Map<String, Object> responseBodyObject = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    Map<String, object> dataObject = (Map<String, object>) responseBodyObject.get('data');
    String campainId = String.valueOf(dataObject.get('id'));

    /* res example
    {
    "status": "ok",
    "code": "msg_campaignCreated",
    "mailListsNotFound": [],
    "segmentNotFound": [],
    "data": 
        {
            "id": 21,
            "name": "PRUEEEBA"
        }
    }
    */

    return campainId;
  }

  public static void sendTestEmail(String envialoSimpleCampainId, String toEmail) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:EnvialoSimple/v1/campaign/preview/email');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');

    Map<String, Object> requestBodyMap = new Map<String, Object>();
    requestBodyMap.put('id', envialoSimpleCampainId);

    requestBodyMap.put('emails', new List<String > {toEmail});

    String requestBodyJsonString = JSON.serialize(requestBodyMap);

    req.setBody(requestBodyJsonString);
    Http http = new Http();
    HTTPResponse res = http.send(req);

    System.debug('sendTestEmail res: ' + res);
  }

  public static void addHtmlEmailToCampain(String envialoSimpleCampainId, String htmlEmail, String fromEmail, String fromName) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:EnvialoSimple/v1/campaign/edit');
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');

    Map<String, Object> requestBodyMap = new Map<String, Object>();
    requestBodyMap.put('id', envialoSimpleCampainId);
    requestBodyMap.put('content', htmlEmail);
    requestBodyMap.put('fromAlias', fromName);
    requestBodyMap.put('fromEmail', fromEmail);
    requestBodyMap.put('replyEmail', fromEmail);

    String requestBodyJsonString = JSON.serialize(requestBodyMap);

    req.setBody(requestBodyJsonString);

    Http http = new Http();
    HTTPResponse res = http.send(req);

    System.debug('addHtmlEmailToCampain res: ' + res);
  }

  public static void updateAccount (Id accId, String envialoSimpleCampainId ){
    Account accToUpdate = new Account();
    accToUpdate.id = accId;
    accToUpdate.Prosumer_Envialo_Simple_Preview__c = envialoSimpleCampainId;
    update accToUpdate;
  }

}