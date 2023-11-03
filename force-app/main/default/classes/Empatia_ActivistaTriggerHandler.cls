public with sharing class Empatia_ActivistaTriggerHandler {
  public static void handleBeforeInsert(List<Empatia_Activista__c> newRecords) {
    completeIdentificadorUnico(newRecords);
    completeActivistaWithCitizen(newRecords);
  }

  public static void handleBeforeUpdate(Map<id, Empatia_Activista__c> newRecordsById, Map<id, Empatia_Activista__c> oldRecordsById) {
    List<Empatia_Activista__c> recordsToCheckNewIdentificador = new List<Empatia_Activista__c>();

    for (Empatia_Activista__c thisActivista : newRecordsById.values()) {
      Boolean dniCambio = thisActivista.dni__c != oldRecordsById.get(thisActivista.id).dni__c;
      Boolean fechaCambio = thisActivista.fecha_de_nacimiento__c != oldRecordsById.get(thisActivista.id).fecha_de_nacimiento__c;
      if (dniCambio || fechaCambio) {
        recordsToCheckNewIdentificador.add(thisActivista);
      }
    }
    completeIdentificadorUnico(recordsToCheckNewIdentificador);
    completeActivistaWithCitizen(recordsToCheckNewIdentificador);
  }

  public static void completeIdentificadorUnico (List<Empatia_Activista__c> newRecords){
    for(Empatia_Activista__c thisActivista : newRecords){
      //uso el metodo del otro handler para asegurar que la key esa sea consistente.
      //La otra seria crear una tercer clase helper, pero por 1 metodo parece mucho...
      thisActivista.identificador_unico__c = EmpatiaTriggerHandler.getIdentificadorUnico(thisActivista.dni__c, thisActivista.fecha_de_nacimiento__c);
    }
  }

  public static void completeActivistaWithCitizen(List<Empatia_Activista__c> newRecords) {
    Set<String> dnilst = new Set<String>();
    for (Empatia_Activista__c newrec : newRecords) {
      dnilst.add(newrec.DNI__c);
    }

    List<Contact> citizens = new List<Contact>();
    citizens = [SELECT Id, Document_Number__c,Birthdate FROM Contact WHERE Document_Number__c IN :dnilst];

    Map<string, Contact> citizensMap = new Map<string, Contact>();
    for (Contact citi : citizens) {
      String identificadorFromCitizen = EmpatiaTriggerHandler.getIdentificadorUnico(citi.Document_Number__c, citi.Birthdate);
      citizensMap.put(identificadorFromCitizen, citi);
    }

    for (Empatia_Activista__c newrec : newRecords) {
      if (citizensMap.containsKey(newrec.identificador_unico__c)) {
        newrec.Citizen__c = citizensMap.Get(newrec.identificador_unico__c).Id;
      }
    }
  }
}