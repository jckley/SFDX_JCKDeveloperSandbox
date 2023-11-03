/**
* Class Name: ContactDetailController
* Description: Controller for the ContactDetail View
*/
public class ContactDetailController {    
    public class LayoutNotFoundException extends Exception {} 
    public Contact contact {get; set;}
    public String conId {get; set;}
    public ContactWrapper contWrap {get; set;}
    
    public Boolean ContactViewStandardPage	{ get; set; }
    public RemotingMessageHelper.UserPermissions permissions { get; set; }


    @AuraEnabled
    public CitizenWrapper citizen {get; set;}
     
    public ContactDetailController(ApexPages.StandardController objStandardController) {
        conId = objStandardController.getId();
        if(String.isNotBlank(conId)) {
            permissions = retrieveLoggedUserPermissions();

            contact = retrieveContactFromId(conId);            
            contWrap = retrieveContactWrapper(contact);
            
            citizen = new CitizenWrapper(contact);
        }
    }     
    
    @AuraEnabled 
    public static CitizenWrapper retrieveInfoFromCitizenId(String strCitizenId) { 
        Contact objContact = null;
        CitizenWrapper objCitizen = null;
        
        System.debug('retrieveInfoFromCitizenId [ strCitizenId : ' + strCitizenId + '] ->');

        if(String.isNotBlank(strCitizenId)) {
            objContact = retrieveContactFromId(strCitizenId);            
            objCitizen = new CitizenWrapper(objContact);
        } 
             
        System.debug('retrieveInfoFromCitizenId [' + objCitizen + '] <-');

        return objCitizen; 
    }
    
    @AuraEnabled
    public static RemotingMessageHelper.UserPermissions retrieveLoggedUserPermissions() { 
        RemotingMessageHelper.UserPermissions objUserPermissions = null;
        
        System.debug('retrieveLoggedUserPermissions [] ->');
        
        objUserPermissions = new RemotingMessageHelper.UserPermissions();
        
        System.debug('retrieveLoggedUserPermissions [' + objUserPermissions + '] <-');
        
        return objUserPermissions;
    }
    
    @AuraEnabled
    public static RemotingMessageHelper.SalesforceDoamins retrieveSalesforceDomains() {
        RemotingMessageHelper.SalesforceDoamins objDomains = null;
        Community_Config__mdt objCommunitySettings = null;
        
        System.debug('retrieveSalesforceDomains [] ->');
        
        objDomains = new RemotingMessageHelper.SalesforceDoamins();
        
        objCommunitySettings = HelperFunctions.retrieveCommunitySettings();
        
        System.debug('retrieveSalesforceDomains [ objCommunitySettings : ' + objCommunitySettings + ']');

        if(objCommunitySettings != NULL) {
            objDomains.LEX = objCommunitySettings.LEX_Domain__c;
            objDomains.VF = objCommunitySettings.VF_Domain__c;
        }
        
        System.debug('retrieveSalesforceDomains [' + objDomains + '] <-');
        return  objDomains;        
    }
    
    @AuraEnabled
    public static String retrieveMultipicklistOptions(String strSObject, String strField ) { 
        List<RemotingMessageHelper.MultipicklistOptions> lstOptions = null;
        List<Contact> lstContact = null;        
        List<Schema.PicklistEntry> lstValues = null;
        List<String> lstSelectedValues = null;        
        Set<String> setSelectedValues = null;        
        RemotingMessageHelper.MultipicklistOptions objPicklistOption = null;
        
        System.debug('retrieveMultipicklistOptions [strSObject : ' + strSObject + ' - strField : ' + strField + '] ->');
        
        if(String.isNotBlank(strSObject) && String.isNotBlank(strField)) {
            lstValues = HelperFunctions.retrievePicklistValues(strSObject, strField);
            lstOptions = new List<RemotingMessageHelper.MultipicklistOptions>();
            
            if(!lstValues.isEmpty()) {
                for(Schema.PicklistEntry objOption : lstValues) {
                    objPicklistOption = new RemotingMessageHelper.MultipicklistOptions();
                    objPicklistOption.label = objOption.getLabel();
                    objPicklistOption.value = objOption.getValue();
                    
                    lstOptions.add(objPicklistOption);
                }
            }
        }
        
        System.debug('retrieveMultipicklistOptions [' + lstOptions + '] <-');
        return JSON.serialize(lstOptions);
    }

    @AuraEnabled
    public static Boolean saveMultipicklistOptions(Id strRecordId, String strSObject, String strField , String[] arrSelectedOptions ) { 
        Boolean boolSaved = false;
        List<Contact> lstContact = null;
        Contact objContact = null;
        System.debug('saveMultipicklistOptions [ strRecordId : ' + strRecordId + ' - strSObject : ' + strSObject + ' - strField : ' + strField + ' - arrSelectedOptions - ' + arrSelectedOptions + '] ->');
        
        if(String.isNotBlank(strRecordId) && String.isNotBlank(strSObject) && String.isNotBlank(strField)) {
        	lstContact = [SELECT Community__c 
                          FROM Contact 
                          WHERE Id =: strRecordId];
            
            if(!lstContact.IsEmpty() && lstContact.size() == 1) {
                objContact = lstContact[0];
                objContact.Community__c = NULL;
                if(!arrSelectedOptions.IsEmpty()) {
                    objContact.Community__c = String.join(arrSelectedOptions, ';'); 
                }
                update objContact;
                boolSaved = true;
            }
        }
                       
        System.debug('saveMultipicklistOptions [' + boolSaved + '] <-');        
        return boolSaved;
    }
    
    @AuraEnabled
    public static String retrieveLayout() {
        List<String> lstLayouts = null;
        List<Metadata.Metadata> lstMetadata = null;
        Metadata.Layout objLayout = null;
        RemotingMessageHelper.CommunitySettings objCommunitySettings = null;  
            
        System.debug('retrieveLayout [] ->');        

        objCommunitySettings = retrieveSalesforceCommunitySettings();
        System.debug('objCommunitySettings : ' + objCommunitySettings);
        lstLayouts = new List<String>();
       	/* 
        if(!Test.isRunningTest()) {
            lstLayouts.add(String.format('Contact.{0}', new String[] { objCommunitySettings.ContactLayout}));
        } else {
            lstLayouts.add(String.format('Contact-Ciudadano', new String[] { objCommunitySettings.ContactLayout}));        
        }
        */
        lstLayouts.add(String.format('Contact-Ciudadano', new String[] { objCommunitySettings.ContactLayout}));        

        
        lstMetadata = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, lstLayouts);

        if(!lstMetadata.IsEmpty()) {
            objLayout = (Metadata.Layout) lstMetadata.get(0);
        } else {
            throw new LayoutNotFoundException();
        }
        
        System.debug('retrieveLayout [' + objLayout + '] <-');        

        return JSON.serialize(objLayout);
    }

    // método para guardar un citizen en object ComunidadRadicales__c	
    @AuraEnabled	
    public static void saveVotoInRadicalesObject(Id strCitizenId, String strVoto) {  	
        System.debug('saveVotoInRadicalesObject [] <-');	
        	
        ComunidadRadicales__c objCustom = null;	
        List<ComunidadRadicales__c> lstObjects = null;
        	
        System.debug('saveVotoInRadicalesObject [strCitizenId : ' + strCitizenId + ' - strVoto : ' + strVoto + '] ->');	
        if(String.isNotBlank(strCitizenId)) {	
            
            lstObjects = [SELECT Vota_a__C FROM ComunidadRadicales__c WHERE Citizen__c =: strCitizenId];	
            
            if(lstObjects.IsEmpty()) {
                objCustom = new ComunidadRadicales__c(); 
                objCustom.Citizen__c = strCitizenId;
            } else {
                objCustom = lstObjects[0];
            }
            
            objCustom.Vota_a__C = strVoto;
            System.debug('saveVotoInRadicalesObject [objCustom : ' + objCustom + ']');	
            
            if(String.isBlank(objCustom.Id)) { 
                insert objCustom;
            } else {
                update objCustom; 
            }
        }
        System.debug('saveVotoInRadicalesObject [] <-');	
    }
    
    // método para guardar un citizen en object Misiones__C	
    @AuraEnabled	
    public static void saveCitizenInMisionesbject(Id strCitizenId, String strMobile, String strEmail, String strFijo) {  	
        System.debug('saveCitizenInMisionesbject [] <-');	
        	
        Misiones__C objCustom = null;	
        List<Misiones__C> lstObjects = null;	
        	
        System.debug('saveCitizenInMisionesbject [strCitizenId : ' + strCitizenId + ' - strMobile : ' + strMobile + ' - strEmail : ' + strEmail + ' - strFijo : ' + strFijo + '] ->');	
        if(String.isNotBlank(strCitizenId)) {	
            lstObjects = [SELECT Name, Email__c, MobilePhone__c FROM Misiones__C WHERE Misiones__C.Citizen__r.Contact_ID__c =: strCitizenId];	
            	
            System.debug('saveCitizenInMisionesbject [objCustom : ' + objCustom + ']');	
            	
            objCustom = lstObjects[0];	
            	
            System.debug('saveCitizenInMisionesbject [objCustom : ' + objCustom + ']');	
            objCustom.Email__C = strEmail;	
            objCustom.MobilePhone__C = strMobile;	
            	
            update objCustom;	
        }	
        System.debug('saveCitizenInMisionesbject [] <-');	
    }
    	
    @AuraEnabled	
    public static void saveCitizenInCitizenSalesforce(Id strCitizenId, String strMobile, String strEmail, String strFijo) {  	
        	
        System.debug('saveCitizenInCitizenSalesforce [] <-');	
        Contact objContact = null;	
        List<Contact> lstContacts = null;	
  	
        System.debug('saveCitizenInCitizenSalesforce [strCitizenId : ' + strCitizenId + ' - strMobile : ' + strMobile + ' - strEmail : ' + strEmail + ' - strFijo : ' + strFijo + '] ->');	
             	
        if(String.isNotBlank(strCitizenId)) {	
            System.debug('saveCitizenInCitizenSalesforce [objContact : ' + objContact + ']');	
                 	
            lstContacts  = [SELECT Contact_ID__c FROM Contact WHERE Contact_ID__c =: strCitizenId];	
            objContact = lstContacts[0];	
            objContact = lstContacts[0];	
                 	
            System.debug('saveCitizenInCitizenSalesforce [objContact : ' + objContact + ']');	
            objContact.Email = strEmail;	
            objContact.MobilePhone = strMobile;	
            objContact.HomePhone = strFijo;	
                        	
            update objContact;	
        }	
        System.debug('saveCitizenInCitizenSalesforce [] <-');    	
    }
    
    @AuraEnabled	
    public static Contact saveCitizenInCitizenSalesforceModified(Id strCitizenId, String strMobile, String strEmail, String strFijo) {  	
        	
        System.debug('saveCitizenInCitizenSalesforceModified [] <-');	
        Contact objContact = null;	
        List<Contact> lstContacts = null;	
  	
        System.debug('saveCitizenInCitizenSalesforceModified [strCitizenId : ' + strCitizenId + ' - strMobile : ' + strMobile + ' - strEmail : ' + strEmail + ' - strFijo : ' + strFijo + '] ->');	
             	
        if(String.isNotBlank(strCitizenId)) {	
            System.debug('saveCitizenInCitizenSalesforceModified [objContact : ' + objContact + ']');	
                 	
            lstContacts  = [SELECT Contact_ID__c FROM Contact WHERE Contact_ID__c =: strCitizenId];	
            objContact = lstContacts[0];	
            objContact = lstContacts[0];	
                 	
            System.debug('saveCitizenInCitizenSalesforceModified [objContact : ' + objContact + ']');	
            objContact.Email = strEmail;	
            objContact.MobilePhone = strMobile;	
            objContact.HomePhone = strFijo;	
                        	
            update objContact;	
        }
        System.debug('saveCitizenInCitizenSalesforceModified [] <-');
        return objContact;
    }
    
    @AuraEnabled
    public static void saveCitizenInSalesforce(Id strCitizenId, String strMobile, String strEmail, String strFijo) {
        Contact objContact = null;
        List<Pilar360__c> lstPilar360s = null;
        Pilar360__c objPilar = null;
  
        System.debug('saveCitizenInSalesforce [strCitizenId : ' + strCitizenId + ' - strMobile : ' + strMobile + ' - strEmail : ' + strEmail + '] ->');
        
        if(String.isNotBlank(strCitizenId)) {
            System.debug('saveCitizenInSalesforce [objContact : ' + objContact + ']');
            
            lstPilar360s  = [SELECT Id FROM Pilar360__c WHERE Citizen__c =: strCitizenId];
            if(lstPilar360s.IsEmpty()) {
                objPilar = new Pilar360__c(); 
                objPilar.Citizen__c = strCitizenId;
            } else {
                objPilar = lstPilar360s[0];
            }

            System.debug('saveCitizenInSalesforce [objPilar : ' + objPilar + ']');
            objPilar.Email__c = strEmail;
            objPilar.Mobile_Phone__c = strMobile;
            objPilar.Phone__c = strFijo;
            
            if(String.isBlank(objPilar.Id)) { 
                insert objPilar;
            } else {
                update objPilar; 
            }
        }

        System.debug('saveCitizenInSalesforce [] <-');    
    }

    private static ContactWrapper retrieveContactWrapper(Contact objContact) {     	
        ContactWrapper objContactWrapper = null;
        System.debug('retrieveContactWrapper [] ->');

        objContactWrapper = new ContactWrapper(objContact);

        System.debug('retrieveContactWrapper [] <-');
        
        return objContactWrapper;
    }
    
    public static Contact retrieveContactFromId(Id strContactId) {
        String strSOQL = null;
        List<String> lstFields = null;
        Contact objContact = null;
        List<Contact> lstContact = null;
        
        System.debug('retrieveContactFromId [] ->');

        lstFields = retrieveFieldsToQuery();
        
        strSOQL = 'SELECT Id, RecordType.DeveloperName ';
        if(lstFields != NULL && !lstFields.isEmpty()) {
            strSOQL += ',';
            strSOQL += String.join(lstFields, ',');
        }

        strSOQL += ' FROM Contact ';
        strSOQL += ' WHERE Id =: strContactId ';
       
        System.debug('retrieveContactFromId [strSOQL : ' + strSOQL + '] ');

        lstContact = Database.query(String.escapeSingleQuotes(strSOQL));
        
        if(lstContact != NULL && !lstContact.isEmpty()) {
            objContact = lstContact[0];
        }
        
        System.debug('retrieveContactFromId [' + objContact + '] <-');

        return objContact;
    }

    private static List<String> retrieveFieldsToQuery() {
        Set<String> setFields = null;        
        Set<String> setFieldsAux = null;     
        List<String> lstFields = null;
        
        System.debug('retrieveFieldsToQuery [] ->');

        setFields = new Set<String>();        

        setFieldsAux = retrieveFieldsToQueryGeneralInfo();
        setFields.addAll(setFieldsAux);

        setFieldsAux = retrieveFieldsToQueryContactInfo();
        setFields.addAll(setFieldsAux);
        
        setFieldsAux = retrieveFieldsToQuerySocialInfo();
        setFields.addAll(setFieldsAux);
        
        setFieldsAux = retrieveFieldsToQueryLocationInfo();
        setFields.addAll(setFieldsAux);
                
        setFieldsAux = retrieveFieldsToQueryAttributesInfo();
        setFields.addAll(setFieldsAux);
        
        setFieldsAux = retrieveFieldsToQueryMovilidadInfo();
        setFields.addAll(setFieldsAux);
            
        setFieldsAux = retrieveFieldsToQueryIncomeInfo();
        setFields.addAll(setFieldsAux);
            
        setFieldsAux = retrieveFieldsToQueryElectoralInfo();
        setFields.addAll(setFieldsAux);
        
        setFieldsAux = retrieveFieldsToQueryAddressInfo();
        setFields.addAll(setFieldsAux);
        
        setFieldsAux = retrieveFieldsToQueryHashtagsInfo();
        setFields.addAll(setFieldsAux);
        
        setFieldsAux = retrieveFieldsToQueryAlertaBAInfo();
        setFields.addAll(setFieldsAux);
        
        setFieldsAux = retrieveFieldsToQueryAdfiInfo();
        setFields.addAll(setFieldsAux);
        
        setFieldsAux = retrieveFieldsToQueryCDPInfo();
        setFields.addAll(setFieldsAux);

        setFieldsAux = retrieveFieldsToQueryDatosSalud();
        setFields.addAll(setFieldsAux);
        
        setFieldsAux = retrieveFieldsToQueryCuidarnos();
        setFields.addAll(setFieldsAux);

        setFieldsAux = retrieveFieldsToQueryEcuador();	
        setFields.addAll(setFieldsAux);

        setFieldsAux = retrieveFieldsToQueryDatosRiver();	
        setFields.addAll(setFieldsAux);
        
        lstFields = new List<String>();
        lstFields.addAll(setFields);
        System.debug('retrieveFieldsToQuery [' + lstFields + '] <-');
        
        return lstFields;
    }
    
    private static Set<String> retrieveFieldsToQueryGeneralInfo() { 
        Set<String> setFields = null;
        
        System.debug('retrieveFieldsToQueryGeneralInfo [] ->');
        
        setFields = new Set<String>();
        
        setFields.add('Name');
        setFields.add('FirstName');
        setFields.add('MiddleName');
        setFields.add('LastName');
        setFields.add('Birthdate');
        setFields.add('Gender__c');
        setFields.add('Nacionalidad__c');
        setFields.add('Document_Number__c');
        setFields.add('Cuil_Number__c');
        setFields.add('PhotoUrl_legacy__c');
        setFields.add('Age_f_x__c');
        setFields.add('GUID__c');
        setFields.add('health_insurance__c');
        
        System.debug('retrieveFieldsToQueryGeneralInfo [' + setFields + '] <-');

        return setFields;
    }
    

    private static Set<String> retrieveFieldsToQueryCuidarnos() { 
        Set<String> setFields = null;
        
        System.debug('retrieveFieldsToQueryCuidarnos [] ->');
        
        setFields = new Set<String>();
        setFields.add('mig_exit_date__c');
        setFields.add('mig_entry_date__c');
        setFields.add('mig_outbound_crossing_type__c');
        setFields.add('mig_inbound_crossing_type__c');
        setFields.add('mig_outbound_country__c');
        setFields.add('mig_inbound_country__c');
        setFields.add('mig_outbound_crossing_point__c');
        setFields.add('mig_outbound_crossing_terrestrial_type__c');
        setFields.add('mig_inbound_crossing_point__c');
        setFields.add('mig_inbound_crossing_terrestrial_type__c');
        setFields.add('mig_inbound_transportation_desc__c');
        setFields.add('mig_outbound_transportation_desc__c');
        setFields.add('mig_inbound_transportation_id__c');
        setFields.add('mig_outbound_transportation_id__c');

        setFields.add('Covid19_Score_Percent__c');

        setFields.add('grouphash_coh__c'); 
        setFields.add('grouphash_cot__c'); 
        setFields.add('grouphash_cot_near__c'); 
        setFields.add('grouphash_cov__c'); 
        setFields.add('grouphash_coe__c');         
        setFields.add('grouphash_cof__c');        
                
        
        System.debug('retrieveFieldsToQueryCuidarnos [' + setFields + '] <-');

        return setFields;
    }
    
    private static Set<String> retrieveFieldsToQueryContactInfo() { 
        Set<String> setFields = null;
        
        System.debug('retrieveFieldsToQueryContactInfo [] ->');

        setFields = new Set<String>();
        setFields.add('Email');
        setFields.add('HomePhone');
        setFields.add('MobilePhone');
        setFields.add('Whatsapp__c');
        setFields.add('Telegram__c');
        
        System.debug('retrieveFieldsToQueryContactInfo [' + setFields + '] <-');

        return setFields;
    }

    private static Set<String> retrieveFieldsToQueryEcuador() { 	
        Set<String> setFields = null;	
        	
        System.debug('retrieveFieldsToQueryEcuador [] ->');	
        setFields = new Set<String>();	
        setFields.add('ec_party_affiliation__c');
        setFields.add('ec_electoral_canton_name__c');	
        setFields.add('ec_electoral_parroquia_name__c');	
        setFields.add('ec_electoral_provincia_name__c');	
        setFields.add('ec_electoral_recinto_name__c');	

        	
        System.debug('retrieveFieldsToQueryEcuador [' + setFields + '] <-');	
        return setFields;	
    }
    
    private static Set<String> retrieveFieldsToQuerySocialInfo() { 
        Set<String> setFields = null;
        
        System.debug('retrieveFieldsToQuerySocialInfo [] ->');

        setFields = new Set<String>();
        setFields.add('Usuario_Facebook__c');
        setFields.add('Facebook_Link__c');
        setFields.add('Usuario_Twitter__c');
        setFields.add('Twitter_Link__c');
        setFields.add('Usuario_Instagram__c');
        setFields.add('Instagram_Link__c');
        setFields.add('Usuario_Linkedin__c');
        setFields.add('Linkedin_Link__c');
        
        System.debug('retrieveFieldsToQuerySocialInfo [' + setFields + '] <-');

        return setFields;
    }
    
    private static Set<String> retrieveFieldsToQueryLocationInfo() { 
        Set<String> setFields = null;
        
        System.debug('retrieveFieldsToQueryLocationInfo [] ->');
        setFields = new Set<String>();
        setFields.add('MailingLatitude');
        setFields.add('MailingLongitude');
        setFields.add('MailingStreet');
        setFields.add('MailingNumber__c');
        setFields.add('MailingAppartment__c');
        setFields.add('MailingPostalCode');
        setFields.add('Administrative_Level_0__c');
        setFields.add('Administrative_Level_1__c');
        setFields.add('Administrative_Level_2__c');
        setFields.add('Administrative_Level_3__c');
        setFields.add('Administrative_Level_4__c');
    
        System.debug('retrieveFieldsToQueryLocationInfo [' + setFields + '] <-');

        return setFields;
    }
    
    private static Set<String> retrieveFieldsToQueryAttributesInfo() { 
        Set<String> setFields = null;
        
        System.debug('retrieveFieldsToQueryAttributesInfo [] ->');
        setFields = new Set<String>();
        setFields.add('toLabel(Movilidad__c)');
        setFields.add('Profession__c');
        setFields.add('Education_Level__c');
        setFields.add('toLabel(Ingreso__c)');
        setFields.add('toLabel(Condicion_De_Ingreso__c)');
        setFields.add('toLabel(Beneficios_Sociales__c)');
        setFields.add('toLabel(Beneficios_Sociales_CBA__c)');
        // setFields.add('licensePlate__c');
    
        System.debug('retrieveFieldsToQueryAttributesInfo [' + setFields + '] <-');

        return setFields;
    }

    private static Set<String> retrieveFieldsToQueryMovilidadInfo() { 
        Set<String> setFields = null;
        
        System.debug('retrieveFieldsToQueryMovilidadInfo [] ->');
        setFields = new Set<String>();
        // setFields.add('toLabel(Movilidad__c)');
        setFields.add('movilidad_clase__c');
        setFields.add('movilidad_desc__c');
        setFields.add('movilidad_patente__c');

        System.debug('retrieveFieldsToQueryMovilidadInfo [' + setFields + '] <-');

        return setFields;
    }

    private static Set<String> retrieveFieldsToQueryIncomeInfo() { 
        Set<String> setFields = null;
        
        System.debug('retrieveFieldsToQueryIncomeInfo [] ->');
        setFields = new Set<String>();
        setFields.add('Employer_1__c');
        setFields.add('Employer_2__c');
        setFields.add('Employer_3__c');
        
        setFields.add('CUIT_Empleador_1__c');
        setFields.add('CUIT_Empleador_2__c');
        setFields.add('CUIT_Empleador_3__c');
                
        setFields.add('Sueldo_1__c');    
        setFields.add('Sueldo_2__c');
        setFields.add('Sueldo_3__c');

        setFields.add('Activity_1__c');
        setFields.add('Activity_2__c');
        setFields.add('Activity_3__c');

        setFields.add('Income_Total__c');    
        
        System.debug('retrieveFieldsToQueryIncomeInfo [' + setFields + '] <-');

        return setFields;
    }
    
    private static Set<String> retrieveFieldsToQueryElectoralInfo() { 
        Set<String> setFields = null;

        System.debug('retrieveFieldsToQueryElectoralInfo [] ->');
        
        setFields = new Set<String>();
        setFields.add('Electoral_District__c');
        setFields.add('Electoral_District_name__c');
        
        setFields.add('Electoral_Section__c');
        setFields.add('Electoral_Section_name__c');
        
        setFields.add('Electoral_Circuit__c');        
        setFields.add('Electoral_Booth__c');
        setFields.add('Escuela_Electoral__c');
        setFields.add('party_affiliation__c');   
        
        setFields.add('toLabel(voting_P2013__c)');        
        setFields.add('toLabel(voting_G2013__c)');    
        setFields.add('toLabel(voting_P2015__c)');
        
        setFields.add('toLabel(voting_G2015__c)');        
        setFields.add('toLabel(voting_B2015__c)');
        
        setFields.add('toLabel(voting_P2017__c)');
        setFields.add('toLabel(voting_G2017__c)');

        setFields.add('toLabel(voting_P2019__c)');
        setFields.add('toLabel(voting_G2019__c)');

        setFields.add('toLabel(voting_P2021__c)');
        setFields.add('toLabel(voting_G2021__c)');

        setFields.add('toLabel(voting_P2023__c)');
        setFields.add('voting_PASO2023_JM__c');
        setFields.add('voting_PASO2023_JS__c');
        setFields.add('voting_PASO2023_JXC__c');
        setFields.add('voting_PASO2023_turnout__c');
        setFields.add('voting_PASO2023_UXP__c');
        setFields.add('toLabel(voting_intent_PASO2023__c)');

        setFields.add('toLabel(voting_intent_GENERALES2023__c)');

        setFields.add('toLabel(Audiencia_Electoral__c)');

        setFields.add('JSON_Votos__c');
                         
        System.debug('retrieveFieldsToQueryElectoralInfo [' + setFields + '] <-');

        return setFields;
    }
                
    private static Set<String> retrieveFieldsToQueryAddressInfo() { 
        Set<String> setFields = null;

        System.debug('retrieveFieldsToQueryAddressInfo [] ->');

        setFields = new Set<String>();
        setFields.add('Level1ID__c');
        setFields.add('Level2ID__c');
        setFields.add('Level3ID__c');        
        setFields.add('Level4ID__c');
        setFields.add('Level1Name__c');
        setFields.add('Level2Name__c');   
        setFields.add('Level3Name__c');   
        setFields.add('Level4Name__c');  
                 
        System.debug('retrieveFieldsToQueryAddressInfo [' + setFields + '] <-');

        return setFields;
    }
    
    private static Set<String> retrieveFieldsToQueryHashtagsInfo() { 
        Set<String> setFields = null;

        System.debug('retrieveFieldsToQueryHashtagsInfo [] ->');

        setFields = new Set<String>();
        setFields.add('toLabel(Audiencia_Politica__c)');
        setFields.add('toLabel(Audiencia_Electoral__c)');
        setFields.add('toLabel(Audiencia_Generaciones__c)');   
        setFields.add('Actividades_Economicas__c');  
        
        setFields.add('toLabel(Tendencia_Politica_STAFE__c)');
        setFields.add('toLabel(Tendencia_Politica_CBA__c)');        

        setFields.add('tribu_electoral_2021__c'); 
        setFields.add('situacion_del_asalariado__c'); 
        setFields.add('toLabel(tipo_de_asalariado__c)'); 
        setFields.add('toLabel(jerarquia_empleo__c)');
        
        setFields.add('delphos_tribe_2019__c'); 
        
        setFields.add('Community__c');
                        
        System.debug('retrieveFieldsToQueryHashtagsInfo [' + setFields + '] <-');

        return setFields;
    }
    
    private static Set<String> retrieveFieldsToQueryAlertaBAInfo() {
        Set<String> setFields = null;

        System.debug('retrieveFieldsToQueryAlertaBAInfo [] ->');

        setFields = new Set<String>();
        setFields.add('Alerta_Buenos_Aires_SirenaID__c');
        setFields.add('Alerta_Buenos_Aires_ID__c');   
        setFields.add('Alerta_Buenos_Aires__c');   
        
        System.debug('retrieveFieldsToQueryAlertaBAInfo [' + setFields + '] <-');

        return setFields;
    }
    
    private static Set<String> retrieveFieldsToQueryAdfiInfo() {
        Set<String> setFields = null;

        System.debug('retrieveFieldsToQueryAdfiInfo [] ->');

        setFields = new Set<String>();
        setFields.add('ADFi_Profile_ID__c');

        System.debug('retrieveFieldsToQueryAdfiInfo [' + setFields + '] <-');

        return setFields;
    }
    
    private static Set<String> retrieveFieldsToQueryCDPInfo() {
        Set<String> setFields = null;
        
        System.debug('retrieveFieldsToQueryCDPInfo [] ->');
        
        setFields = new Set<String>();
        setFields.add('toLabel(CDP_Campaign__c)');
        setFields.add('toLabel(CDP_Axis__c)');
        setFields.add('toLabel(CDP_Status__c)');
        setFields.add('toLabel(CDP_Score__c)');
        
        System.debug('retrieveFieldsToQueryCDPInfo [' + setFields + '] <-');
        
        return setFields;
    }

    private static Set<String> retrieveFieldsToQueryDatosSalud() {
        Set<String> setFields = null;
        
        System.debug('retrieveFieldsToQueryDatosSalud [] ->');
        
        setFields = new Set<String>();
        setFields.add('Comorbilidades__c');
        setFields.add('health_insurance__c');
        setFields.add('Tuvo_Covid19__c');
        setFields.add('covid_vacc_desc__c');
        setFields.add('covid_vacc_1st_dose__c');
        setFields.add('covid_vacc_2nd_dose__c');
        setFields.add('covid_vacc_3rd_dose__c');
        
        System.debug('retrieveFieldsToQueryDatosSalud [' + setFields + '] <-');
        
        return setFields;
    }

    private static Set<String> retrieveFieldsToQueryDatosRiver() {
        Set<String> setFields = null;
        
        System.debug('retrieveFieldsToQueryDatosRiver [subquery] ->');
        
        setFields = new Set<String>();
        setFields.add('(SELECT Id, cat_socio__c, voto_2009__c, voto_2013__c, voto_2017__c, '
                            + 'voto_2021__c, fecha_socio__c, nro_socio__c '
                            + 'FROM RiverIds__r)');
        
        System.debug('retrieveFieldsToQueryDatosRiver [' + setFields + '] <-');
        
        return setFields;
    }
     
    private static RemotingMessageHelper.CommunitySettings retrieveSalesforceCommunitySettings() {
        RemotingMessageHelper.CommunitySettings objCommunitySettings = null;
        Community_Config__mdt objCommunitySettingsC = null;
        
        System.debug('retrieveSalesforceCommunitySettings [] ->');
        
        objCommunitySettingsC = HelperFunctions.retrieveCommunitySettings();
        
        System.debug('retrieveSalesforceCommunitySettings [ objCommunitySettingsC : ' + objCommunitySettingsC + ']');
        
        objCommunitySettings = new RemotingMessageHelper.CommunitySettings();
        if(objCommunitySettingsC != NULL) {
            objCommunitySettings.LEX = objCommunitySettingsC.LEX_Domain__c;
            objCommunitySettings.VF = objCommunitySettingsC.VF_Domain__c;
            objCommunitySettings.ContactLayout =  objCommunitySettingsC.Citizen_Edit_Layout__c;
        }
        
        System.debug('retrieveSalesforceCommunitySettings [' + objCommunitySettings + '] <-');
        return  objCommunitySettings;        
    }
    
    public void savePicklistValue() { 
        String strValue = null;
        String strPicklist = null;
        Boolean boolIsMultipicklist = false;
        
        System.debug('savePicklistValue [] ->');
        
        strPicklist = ApexPages.CurrentPage().getParameters().get('strPicklist');
        strValue = ApexPages.CurrentPage().getParameters().get('strValue');
        boolIsMultipicklist = ApexPages.CurrentPage().getParameters().get('boolIsMultipicklist') == '1' ||  ApexPages.CurrentPage().getParameters().get('boolIsMultipicklist') == 'true';

        citizen.hashtags.updatePicklistValue(strPicklist, boolIsMultipicklist, strValue);
        
        System.debug('savePicklistValue [] <-');
    }
    
    public PageReference saveContact() { 
        contact.Movilidad__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'Movilidad__c', citizen.attributes.mobility.itemsSelected);
        contact.condicion_de_ingreso__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'condicion_de_ingreso__c',citizen.attributes.workCondition.itemsSelected);
        contact.Beneficios_Sociales__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'Beneficios_Sociales__c',citizen.attributes.socialBenefits.itemsSelected);
        contact.beneficios_Sociales_CBA__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'beneficios_Sociales_CBA__c',citizen.attributes.socialBenefitsCBA.itemsSelected);

        contact.Audiencia_Politica__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'Audiencia_Politica__c',citizen.hashtags.tagsAudienciaPolitica.tagsSelected);
        contact.Audiencia_Electoral__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'Audiencia_Electoral__c',citizen.hashtags.tagsAudienciaElectoral.tagsSelected);
        contact.Audiencia_Generaciones__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'Audiencia_Generaciones__c',citizen.hashtags.tagsAudienciaGeneraciones.tagsSelected);
                
        contact.Community__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'Community__c', citizen.hashtags.tagsCommunity.tagsSelected);
        contact.CDP_Campaign__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'CDP_Campaign__c', citizen.hashtags.tagsCDPCampaign.tagsSelected);
        contact.CDP_Axis__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'CDP_Axis__c', citizen.hashtags.tagsCDPCampaign.tagsSelected);
    
        contact.Situacion_del_Asalariado__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'Situacion_del_Asalariado__c',citizen.hashtags.tagsSituacionAsalariado.tagsSelected);

        contact.tribu_electoral_2021__c = HelperFunctions.getValuesFromMultiPickList('Contact', 'tribu_electoral_2021__c',citizen.hashtags.tagsTribuElectoral2021.tagsSelected);
		
        update contact;
        
        return null;
    }
    
    @AuraEnabled
    public static void createLog(Id recordId){
        CommunitiesController.createLog(recordId);
    }
}