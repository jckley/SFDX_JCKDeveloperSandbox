/**
 * Class Name: Utilities
 * Description: Class with utilities methods
 * Developer: Luis Puentes - Date: 30/05/2018
*/
public class Utilities {

    /*
    * Name: getFieldLabel
    * Description: gets the field label of and object
    */
    public static String getFieldLabel(String fieldName, String sObjectName){
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);        
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
        return f.getLabel() + '';
    }
    
    /*
    * Name: getFieldType
    * Description: gets the field type of and object
    */
    public static String getFieldType(String fieldName, String sObjectName){
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);        
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
        return f.getType() + '';
    }
    
    /* 
	* Name: getThousandSeparatedByDot
	* Description: Transforms the number Integer to a thousand separated string
	*/
    public static String getThousandSeparatedByDot (Integer numberToSeparate){
        String aux = numberToSeparate + '';
        if(numberToSeparate / 1000000 >= 1){
            aux = aux.substring(0, aux.length() - 6) + '.' + aux.substring(aux.length() - 6, aux.length() - 3) + '.' + aux.substring(aux.length() - 3, aux.length());
        }else if(numberToSeparate / 1000 >= 1){
            aux = aux.substring(0, aux.length() - 3) + '.' + aux.substring(aux.length() - 3, aux.length());
        }
        return aux;
    }
    
    /* 
	* Name: removeAccents
	* Description: Removes accents from a string
	*/
    public static String removeAccents (String baseString){
        
        List<String> lettersWithAccents = new List<String> {'á','é','í','ó','ú','Á','É','Í','Ó','Ú'};
        List<String> lettersWithoutAccents = new List<String> {'a','e','i','o','u','A','E','I','O','U'};
        String newString = baseString;
        for (Integer i = 0; i < lettersWithAccents.size(); i++) {
            newString = newString.replace(lettersWithAccents[i], lettersWithoutAccents[i]);
        }

        return newString;
    }
    
    /* 
	* Name: retrievePicklistValues
	* Description: Gets the picklist pair (Label, Value) 
	*/
    public static List<Schema.PicklistEntry> retrievePicklistValues (String strSObject, String strField){
        
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(strSObject); 
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        Map<String, Schema.SObjectField> mapFieldMap = objDescribe.fields.getMap(); 
        List<Schema.PicklistEntry> lstPicklistValues = mapFieldMap.get(strField).getDescribe().getPickListValues();
        
        return lstPicklistValues;
    }
    
    /*
	* Name: buildPickListOptions
	* Description: Builds a list of picklist options
	*/
    public static List<SelectOption> buildPickListOptions (List<Schema.PicklistEntry> pickListEntry) {
        List<SelectOption> optionList = new List<SelectOption>();
        for (Schema.PicklistEntry listItem : pickListEntry) {
            optionList.add(new SelectOption(listItem.getLabel(), listItem.getValue()));
        }
        return optionList;
    }
    
    /*
	* Name: addValueToPickList
	* Description: adds new values to an existing picklist
	*/
    public static List<MetadataService.SaveResult> addValueToPickList (String plObject, String plName, Boolean isMultiPl, String newValue) {
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = plObject + '.' + plName;
        customField.label = getFieldLabel(plName, plObject);
        customField.type_x = isMultiPl? 'MultiselectPicklist' : 'Picklist';
        
        MetadataService.ValueSet valueSet = new MetadataService.ValueSet();
        MetadataService.ValueSetValuesDefinition valueSetValueDefinition = new MetadataService.ValueSetValuesDefinition();
        List<MetadataService.CustomValue> values = new List<MetadataService.CustomValue>();
        MetadataService.CustomValue customValue = new MetadataService.CustomValue();
        
        customValue.fullName = newValue;
        customValue.default_x = false;
        customValue.isActive = true;
        values.add(customValue);
        
        for (Schema.PicklistEntry entry : retrievePicklistValues(plObject, plName)) {
            customValue = new MetadataService.CustomValue();
            customValue.fullName = entry.getValue(); //API name of picklist value
            customValue.default_x = entry.isDefaultValue();
            customValue.isActive = entry.isActive();
            customValue.label = entry.getLabel();
            values.add(customValue);
        }
        
        //It will be list of CustomValue
        valueSetValueDefinition.value = values;
        valueSetValueDefinition.sorted = false;
        
        //set the valueSetDefinition
        valueSet.valueSetDefinition = valueSetValueDefinition;
        
        //Set the valueSet for picklist type
        customField.valueSet = valueSet;
        if(isMultiPl){
        	customField.visibleLines = 4;   
        }
        
        return service.updateMetadata(new MetadataService.Metadata[] { customField });
    }
    
}