public with sharing class PRM_LookUp_Controller {
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String strObject, String strField, String strSearchString, String strCode) {
        List<RecordsData> lstResult = null;
        List<SObject> lstRecords = null;
        String strSOQL = null;

        System.debug('fetchRecords [strObject : ' + strObject + ' - strField : ' + strField + ' - strSearchString : ' + strSearchString + ' - strCode : ' + strCode +  '] ->');

        lstResult = new List<RecordsData>();
        try {
            strSOQL = 'SELECT Code__c, ' + strField;
            strSOQL += ' FROM ' + strObject;

            if(String.isNotBlank(strCode)) {
                strSOQL += ' WHERE Code__c = \'' + strCode + '\'';
            } else if(String.isNotBlank(strSearchString)) {
                strSOQL += ' WHERE ' + strField + ' LIKE \'%' + String.escapeSingleQuotes(strSearchString.trim()) + '%\'';
            }
            strSOQL += ' ORDER BY Name ASC ';

            strSOQL += ' LIMIT 5';

            System.debug('fetchRecords [strSOQL : ' + strSOQL + ']');

            lstRecords = Database.query(strSOQL);

            System.debug('fetchRecords [lstRecords : ' + lstRecords + ']');

            for(SObject objRecord : lstRecords) {
	            lstResult.add( new RecordsData((String)objRecord.get(strField), String.valueOf( ((Decimal)objRecord.get('Code__c')).intValue() ) ) );
            }            
	    } catch (Exception Ex) {
	    	if (String.isNotBlank( Ex.getMessage() ) && Ex.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(Ex.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(Ex.getMessage());
            }
        }
        
        System.debug('fetchRecords [' + lstResult + '] <-');

        return lstResult;
    }

    public class RecordsData {
        @AuraEnabled 
        public String label;
        @AuraEnabled 
        public String value;

        public RecordsData(String strLabel, String strValue) {
            this.label = strLabel;
            this.value = strValue;
        }
    }
}