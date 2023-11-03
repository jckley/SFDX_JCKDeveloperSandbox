public without sharing class empatia_activistaMergeController implements empatia_activistaMergeInterface {
  //quedo muy complicado... La idea era poder testar las cosas de a 1. Por un lado el metodo que decide sobre si mergear o editar
  //y por otro la logica en si, del merge/edit
  //quise usar la intefase para desacoplar las cosas y funciono, pero me parece que es complicado al pedo
  //ademas el metodo "mergeRecord", tampoco quedo del todo bien en cuanto a los tests.

  @AuraEnabled
  public static String changeActivistaInfo(String recordId, String dni, Date fecha , String injectedStrategy) {
    String strategyNameToUse = String.isBlank(injectedStrategy) ? 'empatia_activistaMergeController' : injectedStrategy;

    Type t = Type.forName(strategyNameToUse);

    empatia_activistaMergeInterface controlStrategy = (empatia_activistaMergeInterface) t.newInstance();

    List<Empatia_Activista__c> activistasExistentes = [SELECT id FROM Empatia_Activista__c WHERE dni__c = :dni AND Fecha_de_nacimiento__c =: fecha];

    if (activistasExistentes.size() == 0) {
      return controlStrategy.updateExistingRecord(recordId, dni, fecha);
    }

    String oldActivistaId = recordId;
    String newRecordId = activistasExistentes[0].id;

    return controlStrategy.mergeRecord(oldActivistaId, newRecordId);
  }

  public static string updateExistingRecord(String recordId, String dni, Date fecha) {
    Empatia_Activista__c activista = new Empatia_Activista__c();
    activista.id = recordId;
    activista.dni__c = dni;
    activista.Fecha_de_nacimiento__c = fecha;

    Database.SaveResult result = Database.update(activista, false);

    if (!result.isSuccess()) {
      throw new AuraHandledException('Ocurrio un error al actualizar el DNI del activista: ' + result.getErrors()[0].getMessage());
    }
    return '{"operationType":"update"}';
  }

  public static string mergeRecord(String oldActivistaId, String newActivistaId) {
    transferNotesToNewActivista(oldActivistaId, newActivistaId);
    transferEmpatiasToNewActivista(oldActivistaId, newActivistaId);

    Empatia_Activista__c oldActivista = new Empatia_Activista__c();
    oldActivista.id = oldActivistaId;
    delete oldActivista;

    return '{"operationType":"merge", "activistaId":"' + newActivistaId + '"}';
  }

  public static void transferNotesToNewActivista(String oldActivistaId, String newActivistaId) {
    List<Empatia_Nota__c> notasToTransfer = [SELECT id FROM Empatia_Nota__c WHERE Empatia_Activista__c = :oldActivistaId];
    for (Empatia_Nota__c thisNota : notasToTransfer) {
      thisNota.Empatia_Activista__c = newActivistaId;
    }

    update notasToTransfer;
  }

  public static void transferEmpatiasToNewActivista(String oldActivistaId, String newActivistaId) {
    List<Empatia__c> empatiasToTransfer = [SELECT id FROM Empatia__c WHERE Empatia_Activista__c = :oldActivistaId];
    for (Empatia__c thisNota : empatiasToTransfer) {
      thisNota.Empatia_Activista__c = newActivistaId;
    }

    update empatiasToTransfer;
  }

  @AuraEnabled
  public static contact searchCitizen(String dni, Date fecha ) {
    List<Contact> contactList = [
      SELECT id, Name, FirstName, LastName, Level1Name__c, Level2Name__c, PhotoUrl_legacy__c
      FROM Contact
      WHERE Document_Number__c = :dni AND BirthDate =: fecha
    ];

    if (contactList.size() == 0) {
      return null;
    }

    return contactList[0];
  }
}