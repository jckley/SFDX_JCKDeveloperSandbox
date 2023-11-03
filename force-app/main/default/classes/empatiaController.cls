public without sharing class empatiaController {
  @AuraEnabled(cacheable=true)
  public static Empatia__c retrieveActivistaFromId(Id empatiaId) {

    List<Empatia__c> queryResults = [
      SELECT
        name,
        ciudad__c,
        Celular__c,
        Nombre__c,
        Apellido__c,
        DNI__c,
        Email__c,
        Evento__c,
        Fecha_de_Nacimiento__c,
        Participacion__c,
        Provincia__c,
        Empatia_Activista__r.Citizen__r.MailingPostalCode,
        Empatia_Activista__r.Citizen__r.MailingStreet,
        Empatia_Activista__r.Citizen__r.MailingNumber__c,
        Empatia_Activista__r.Citizen__r.Level1Name__c,
        Empatia_Activista__r.Citizen__r.Level2Name__c,
        Empatia_Activista__r.Citizen__r.Level3Name__c,
        Empatia_Activista__r.Citizen__r.Level4Name__c,
        Empatia_Activista__r.Citizen__r.Age_f_x__c,
        Empatia_Activista__r.Citizen__r.Nacionalidad__c,
        Empatia_Activista__r.Citizen__r.guid__c,
        Empatia_Activista__r.Citizen__r.Email,
        Empatia_Activista__r.Citizen__r.HomePhone,
        Empatia_Activista__r.Citizen__r.MobilePhone,
        Empatia_Activista__r.Citizen__r.Whatsapp__c,
        Empatia_Activista__r.Citizen__r.PhotoUrl_legacy__c,
        Empatia_Activista__r.Citizen__r.FirstName,
        Empatia_Activista__r.Citizen__r.LastName,
        Empatia_Activista__r.Citizen__r.Name,
        Empatia_Activista__r.Citizen__r.Birthdate,
        Empatia_Activista__r.Citizen__r.Gender__c,
        Empatia_Activista__r.Citizen__r.Document_Number__c,
        Empatia_Activista__r.Citizen__r.Cuil_Number__c,
        Empatia_Activista__r.Citizen__r.MailingAppartment__c,
        Empatia_Activista__c,
        Empatia_Activista__r.Estado_Contacto__c,
        Empatia_Activista__r.Etapa_Contacto__c,
        Empatia_Activista__r.Fecha_de_Inscripcion__c
      FROM Empatia__c
      WHERE Id = :empatiaId
    ];

    if (queryResults.size() == 0) {
      return null;
    }

    return queryResults[0];
  }

  @AuraEnabled(cacheable=true)
  public static List<Empatia_Nota__c> retrieveNotasFromActivistaFromId(
    Id empatiaId
  ) {
    //relaciones: empatia_notas (muchos)-----(1/0) empatia_activista (1/0)------(muchos) empatias
    List<Empatia__c> empatiaResult = [
      SELECT Empatia_Activista__c
      FROM Empatia__c
      WHERE Id = :empatiaId
    ];

    if (empatiaResult.size() == 0) {
      return new List<Empatia_Nota__c>();
    }

    List<Empatia_Nota__c> queryResults = [
      SELECT Nota__c, CreatedBy.FirstName, CreatedBy.LastName, CreatedDate
      FROM Empatia_Nota__c
      WHERE Empatia_Activista__c = :empatiaResult[0].Empatia_Activista__c
      ORDER BY CreatedDate DESC
    ];

    if (queryResults.size() == 0) {
      return new List<Empatia_Nota__c>();
    }

    return queryResults;
  }

  @AuraEnabled
  public static List<Empatia_Nota__c> insertNota(
    Id empatiaActivistaId,
    String nota
  ) {
    Empatia_Nota__c newNota = new Empatia_Nota__c();
    newNota.Nota__c = nota;
    newNota.Empatia_Activista__c = empatiaActivistaId;
    insert newNota;

    return [
      SELECT Nota__c, CreatedBy.FirstName, CreatedBy.LastName, CreatedDate
      FROM Empatia_Nota__c
      WHERE Empatia_Activista__c = :empatiaActivistaId
      ORDER BY CreatedDate DESC
    ];
  }

  @AuraEnabled
  public static void createLog (Id recordId) {
      String networkId = Network.getNetworkId();
      String logSource = 'CRM';
      if (String.isNotBlank(networkId)) {
          //no se pueden crear datos de test para el objeto NETWORK, porque reprensenta comunidades. Asi que lo testeo.
          //una alternativa seria que el lwc le pase como parametro el context (nompre de la app del CRM o de la comunidad donde se este usando)
          List<Network> lstNetwork = [SELECT NAME FROM NETWORK WHERE ID =: networkId];
          logSource = lstNetwork[0].name;
      }
  
      ActivityLog__c log = new ActivityLog__c ();
      log.empatia__c = recordId;
      log.logSource__c = logSource;
      Insert log;
  }
}