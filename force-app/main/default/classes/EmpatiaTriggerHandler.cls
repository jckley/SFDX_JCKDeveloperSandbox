public without sharing class EmpatiaTriggerHandler {
  public static void handleBeforeInsert(List<Empatia__c> newRecords) {
    setRespuestaValidaOnNewEmpatiaRecordsToTrue(newRecords);
    createNewEmpatiaActivistaRecord(newRecords);
    completeEmpatiaWithActivista(newRecords);
  }

  public static void handleAfterInsert(List<Empatia__c> newRecords) {
    setRespuestaValidaOnExistingEmpatiaRecordsToFalse(newRecords);
    mapFieldsToActivista(newRecords); //others than fecha_de_nacimiento__ y dni__c
  }

  public static void setRespuestaValidaOnNewEmpatiaRecordsToTrue(List<Empatia__c> newRecords) {
    System.debug('Entering setRespuestaValidaOnNewEmpatiaRecordsToTrue..');

    //recorro las empatias nuevas y me traigo los DNIs. Luego me traigo las existentes que tengan el mismo dni y que esten marcadas como la valida
    //agrego todo a una lista
    //recorro la lista y voy agregando a un mapa de (identificador unico -> registro de empatia) los registros que deberia quedar marcados como los mas recientes
    //luego recorro el mapa tildando todos como validos (a los que ya estan en base de datos no los afecta, a los nuevos insertados los va a modificar)

    Set<String> newEmpatiasDniSet = new Set<String>();

    for (Empatia__c newrec : newRecords) {
      if (newrec.Fecha_Respuesta__c == null) {
        continue;
      }
      newEmpatiasDniSet.add(newrec.dni__c);
    }

    List<Empatia__c> empatiasRelatedByDNI = [
      SELECT id, Fecha_Respuesta__c, DNI__c, fecha_de_nacimiento__c
      FROM Empatia__c
      WHERE DNI__c IN :newEmpatiasDniSet AND Fecha_Respuesta__c != NULL AND Respuesta_Valida__c = TRUE
    ];

    List<Empatia__c> allEmpatias = new List<Empatia__c>();

    allEmpatias.addAll(empatiasRelatedByDNI);
    allEmpatias.addAll(newRecords);

    Map<String, Empatia__c> empatiaValidaByIdentificador = new Map<String, Empatia__c>();

    for (Empatia__c empatia : allEmpatias) {
      if (!empatiaValidaByIdentificador.containsKey(getIdentificadorUnico(empatia))) {
        empatiaValidaByIdentificador.put(getIdentificadorUnico(empatia), empatia);
      }

      boolean empatiaEsValida = empatiaValidaByIdentificador.get(getIdentificadorUnico(empatia)).Fecha_Respuesta__c < empatia.Fecha_Respuesta__c;

      if (empatiaEsValida) {
        empatiaValidaByIdentificador.put(getIdentificadorUnico(empatia), empatia);
      }
    }

    for (Empatia__c registroATildar : empatiaValidaByIdentificador.values()) {
      registroATildar.Respuesta_Valida__c = true;
    }
  }

  public static void createNewEmpatiaActivistaRecord(List<Empatia__c> newRecords) {
    //me traigo los activistas existentes para los identificadores unicos generados por los nuevos registros de empatia
    //luego recorro los registros de empatia, y si hay alguno que no se puede emparejar porque no tiene activista, creo ese activista

    Map<String, empatia__c> empatiasByIdentificador = new Map<String, empatia__c>();
    for (Empatia__c newrec : newRecords) {
      empatiasByIdentificador.put(getIdentificadorUnico(newrec), newrec);
    }

    List<Empatia_Activista__c> activistas = new List<Empatia_Activista__c>();
    activistas = [
      SELECT Id, DNI__c, fecha_de_nacimiento__c, identificador_unico__c
      FROM Empatia_Activista__c
      WHERE identificador_unico__c IN :empatiasByIdentificador.keyset()
    ];

    Set<String> identificadoresExistentes = new Set<String>();
    for (Empatia_Activista__c act : activistas) {
      identificadoresExistentes.add(act.identificador_unico__c);
    }

    List<Empatia_Activista__c> newEmpActLst = new List<Empatia_Activista__c>();
    for (String thisIdentificador : empatiasByIdentificador.keyset()) {
      if (!identificadoresExistentes.contains(thisIdentificador)) {
        Empatia_Activista__c newEmpAct = new Empatia_Activista__c();
        Empatia__c thisEmpatiaRecord = empatiasByIdentificador.get(thisIdentificador);
        newEmpAct.DNI__c = thisEmpatiaRecord.dni__c;
        newEmpAct.fecha_de_nacimiento__c = thisEmpatiaRecord.fecha_de_nacimiento__c;
        newEmpAct.Fecha_de_Inscripcion__c = thisEmpatiaRecord.Fecha_Respuesta__c;
        newEmpActLst.add(newEmpAct);
      }
    }

    // EL trigger estaba fallando porque trataba de insertar activistas con DNIs repetidos.
    if (!newEmpActLst.isEmpty()) {
      //insert newEmpActLst;
      List<Database.SaveResult> results = Database.insert(newEmpActLst, false);
    }
  }

  public static void completeEmpatiaWithActivista(List<Empatia__c> newRecords) {
    //traigo los activistas existentes por identificador
    //los agrego a las empatias
    List<String> identificadorList = new List<String>();
    for (Empatia__c newrec : newRecords) {
      identificadorList.add(getIdentificadorUnico(newrec));
    }

    List<Empatia_Activista__c> activistas = new List<Empatia_Activista__c>();
    activistas = [SELECT Id, identificador_unico__c FROM Empatia_Activista__c WHERE identificador_unico__c IN :identificadorList];

    Map<string, Empatia_Activista__c> activistasmap = new Map<string, Empatia_Activista__c>();
    for (Empatia_Activista__c empact : activistas) {
      activistasmap.put(empact.identificador_unico__c, empact);
    }

    for (Empatia__c emp : newRecords) {
      emp.Empatia_Activista__c = activistasmap.Get(getIdentificadorUnico(emp)).Id;
    }
  }

  public static void setRespuestaValidaOnExistingEmpatiaRecordsToFalse(List<Empatia__c> newRecords) {
    System.debug('Entering setExistingEmpatiaRecordsToInvalid..');

    //agrego los ids de los activistas de los nuevos registros de empatia que fueron marcados como validos
    //me traigo los otros registros de empatia, hijos de esos activistas que esten marcados como validos
    //les saco el tilde

    Set<id> activistasIds = new Set<id>();
    for (Empatia__c newrec : newRecords) {
      if (newrec.Respuesta_Valida__c == true) {
        activistasIds.add(newrec.Empatia_Activista__c);
      }
    }

    List<Empatia__c> empRecLst = new List<Empatia__c>();
    empRecLst = [
      SELECT Id, Respuesta_Valida__c
      FROM Empatia__c
      WHERE Empatia_Activista__c IN :activistasIds AND Respuesta_Valida__c = TRUE AND Id NOT IN :newRecords
    ];

    if (!empRecLst.isEmpty()) {
      for (Empatia__c empRec : empRecLst) {
        empRec.Respuesta_Valida__c = false;
      }

      update empRecLst;
    }
  }

  public static void mapFieldsToActivista(List<Empatia__c> newRecords) {
    //pendiente testear
    List<Empatia_Activista__c> activistasToUpdate = new List<Empatia_Activista__c>();

    for (Empatia__c emp : newRecords) {
      if (emp.Respuesta_Valida__c) {
        String ciudad = emp.Ciudad__c == null ? null : emp.Ciudad__c;
        String celular = emp.Celular__c == null ? null : emp.Celular__c;
        String email = emp.Email__c == null ? null : emp.Email__c;
        String provincia = emp.Provincia__c == null ? null : emp.Provincia__c;

        Empatia_Activista__c activistaToUpdatee = new Empatia_Activista__c();

        activistaToUpdatee.id = emp.Empatia_Activista__c;
        activistaToUpdatee.Ciudad__c = ciudad;
        activistaToUpdatee.Celular__c = celular;
        activistaToUpdatee.Email__c = email;
        activistaToUpdatee.Provincia__c = provincia;

        activistasToUpdate.add(activistaToUpdatee);
      }
    }

    update activistasToUpdate;
  }

  public static string getIdentificadorUnico(Empatia__c empatia) {
    return getIdentificadorUnico(empatia.dni__c, empatia.fecha_de_nacimiento__c);
  }

  public static string getIdentificadorUnico(String dni, Date fecha) {
    //valueof sobre un campo tipo date devuelve la fecha en formato yyyy-mm-dd
    return dni + '/' + String.valueOf(fecha);
  }
}