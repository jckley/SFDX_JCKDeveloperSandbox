public interface empatia_activistaMergeInterface {

    string updateExistingRecord (String recordId, String dni, Date fecha);
    string mergeRecord (String oldActivistaId, String newActivistaId);

}