public class ContactWrapper {
    @AuraEnabled
    public Contact contact {get;set;}        
    @AuraEnabled
    public String gender {get;set;}
    @AuraEnabled
    public String dateString {get;set;}
    @AuraEnabled
    public String dateFormated {get;set;}
    @AuraEnabled
    public String department {get; set;}
    @AuraEnabled
    public String floor {get; set;}
    @AuraEnabled
    public String documentFormated {get; set;}
    @AuraEnabled
    public String incomeFormated {get; set;}
    @AuraEnabled
    public String salary1Formated {get; set;}
    @AuraEnabled
    public String salary2Formated {get; set;}
    @AuraEnabled
    public String salary3Formated {get; set;}
    @AuraEnabled
    public String cuit1Formated {get; set;}
    @AuraEnabled
    public String cuit2Formated {get; set;}
    @AuraEnabled
    public String cuit3Formated {get; set;}
    @AuraEnabled
    public String cuitFormated {get; set;}
    @AuraEnabled
    public String personTitle {	get; set;}
    @AuraEnabled
    public String personAddress { get; set;}    
    @AuraEnabled
    public String personAddressOnlyPisoDepto { get; set;}
    
    @AuraEnabled
    public String personAddressSearch { 
        get {
            return this.personAddressOnlyPisoDepto.replace('-', '');
        }
    }
    
    @AuraEnabled
    public String baseURL {get; set;}
    
    @AuraEnabled
    public List<TagList> attributeTags {get; set;}
    @AuraEnabled
    public List<TagList> tags {get; set;}
    @AuraEnabled
    public List<String> tagsCommunity {get; set;}
    @AuraEnabled
    public List<String> tagsForCommunity {get; set;}
    
    @AuraEnabled
    public List<String> tagsCommunityHurlingham {get; set;}
    
    @AuraEnabled
    public List<String> tagsAudience {get; set;}
    @AuraEnabled
    public List<String> tagsAudiencePol {get; set;}
    @AuraEnabled
    public List<String> tagsAudienceElect {get; set;}
    @AuraEnabled
    public List<String> tagsActividadesEconomicas {get; set;}
    @AuraEnabled
    public List<String> tagsAudienceGen {get; set;}
    @AuraEnabled
    public List<String> tagsCDPCampaing {get; set;}
    @AuraEnabled
    public List<String> tagsCDPAxis {get; set;}
    @AuraEnabled
    public String tagsCDPStatus {get; set;}
    @AuraEnabled
    public String tagsCDPScore {get; set;}
    @AuraEnabled
    public String tagsTendenciaPolitica {get; set;}
    @AuraEnabled
    public String tagsTendenciaPoliticaSTAFE {get; set;}
    @AuraEnabled
    public Integer tagsCommunityCount { 
        get {return (tagsCommunity == NULL)?0:tagsCommunity.size();}
    }//
    @AuraEnabled
    public Boolean ShowElectoralDetails {
        get{ 
        	return false; 
        }             
    }
    
    public List<SelectOption> movilityOptions {get; set;}
    public List<String> selectedMovilityOptions {get; set;}
    public List<SelectOption> incomeOptions {get; set;}
    public String selectedIncomeOption {get; set;}
    public List<SelectOption> workConditionOptions {get; set;}
    public List<String> selectedWorkConditionOptions {get; set;}
    public List<SelectOption> socialBenefitsOptions {get; set;}
    public List<String> selectedSocialBenefitsOptions {get; set;}
    public List<SelectOption> socialBenefitsCBAOptions {get; set;}
    public List<String> selectedSocialBenefitsCBAOptions {get; set;}
    
    public List<SelectOption> communityTagsOptions {get; set;}
    public List<String> selectedCommunityTagsOptions {get; set;}
    public List<String> communityOptionsSearch {get;set;}
    public String communityOptionsSearchSerialized {get;set;}

    public List<SelectOption> audiencePolOptions {get; set;}
    public List<String> selectedAudiencePolOptions {get; set;}
    public List<SelectOption> audienceElecOptions {get; set;}
    public List<String> selectedAudienceElecOptions {get; set;}
    public List<SelectOption> audienceGenOptions {get; set;}
    public List<String> selectedAudienceGenOptions {get; set;}
    public List<SelectOption> CDPCampaingTagsOptions {get; set;}
    public List<String> selectedCDPCampaingTagsOptions {get; set;}
    
    public List<String> CDPCampaingOptionsSearch {get;set;}
    public String CDPCampaingSearchSerialized {get;set;}
    public List<SelectOption> CDPAxisTagsOptions {get; set;}
    public List<String> selectedCDPAxisTagsOptions {get; set;}
    public List<String> CDPAxisOptionsSearch {get;set;}
    public String CDPAxisSearchSerialized {get;set;}
    public List<SelectOption> CDPStatusOptions {get; set;}
    public String selectedCDPStatusOption {get; set;}
    public List<String> CDPStatusOptionsSearch {get;set;}
    public String CDPStatusSearchSerialized {get;set;}
    public List<SelectOption> CDPScoreOptions {get; set;}
    public String selectedCDPScoreOption {get; set;}
    public List<String> CDPScoreOptionsSearch {get;set;}
    public String CDPScoreSearchSerialized {get;set;}
    
    public List<SelectOption> votingP15 {get; set;}
    public String selectedvotingP15Option {get; set;}    
    public List<SelectOption> votingG15 {get; set;}
    public String selectedvotingG15Option {get; set;}
    public List<SelectOption> votingB15 {get; set;}
    public String selectedvotingB15Option {get; set;}
    public List<SelectOption> votingP17 {get; set;}
    public String selectedvotingP17Option {get; set;}
    public List<SelectOption> votingG17 {get; set;}
    public String selectedvotingG17Option {get; set;}
    
    public List<SelectOption> tendenciaPoliticaCBAOptions {get; set;}
    public String tendenciaPoliticaCBASelected {get; set;}
    
    public List<SelectOption> tendenciaPoliticaSTAFEOptions {get; set;}
    public String tendenciaPoliticaSTAFESelected {get; set;}
    
    public String newPlValue {get; set;}
    public String newPlValueCampaing {get; set;}
    public String newPlValueAxis {get; set;}
    public String newPlValueScore {get; set;}
    public String newPlValueStatus {get; set;}
    
    public String valueToSave {get; set;}
    
    @AuraEnabled
    public String twitterUserFormated {get; set;}
    
    public ContactWrapper (Contact cont) {
        String strFloorApartment = null;
        String strLevel2 = null;
        contact = cont;
        baseURL = System.URL.getSalesforceBaseURL().toExternalForm();

        
        gender = String.isBlank(contact.Gender__c) ? Label.NoInformation : contact.Gender__c == 'F' ? Label.Female : Label.Male;
        
        if(contact.MailingAppartment__c != null) {
            strFloorApartment = String.format('{0}', new String [] { contact.MailingAppartment__c });
        } else {
            strFloorApartment = '';
        }
        
        dateString = contact.Birthdate != null ? getBirthDateString(contact.Birthdate, contact.Gender__c) : '';
        dateFormated = contact.Birthdate != null ? contact.Birthdate.format() : '';
        documentFormated = contact.Document_Number__c != null ?  Utilities.getThousandSeparatedByDot(Integer.valueOf(contact.Document_Number__c)) : '';
        incomeFormated = contact.Income_Total__c != null ?  Utilities.getThousandSeparatedByDot(Integer.valueOf(contact.Income_Total__c)) : '';
        salary1Formated = contact.Sueldo_1__c != null ? Utilities.getThousandSeparatedByDot(Integer.valueOf(contact.Sueldo_1__c)) : '';
        salary2Formated = contact.Sueldo_2__c != null ? Utilities.getThousandSeparatedByDot(Integer.valueOf(contact.Sueldo_2__c)) : '';
        salary3Formated = contact.Sueldo_3__c != null ? Utilities.getThousandSeparatedByDot(Integer.valueOf(contact.Sueldo_3__c)) : '';
        cuitFormated = (contact.Cuil_Number__c != null && contact.Cuil_Number__c.length() >= 8 )? contact.Cuil_Number__c.substring(0,2) + '-' + 
            contact.Cuil_Number__c.substring(2, contact.Cuil_Number__c.length() - 1) + '-' + 
            contact.Cuil_Number__c.substring(contact.Cuil_Number__c.length() - 1, contact.Cuil_Number__c.length()) : '';
        cuit1Formated = (contact.CUIT_Empleador_1__c != null && contact.CUIT_Empleador_1__c.length() >= 8 )? contact.CUIT_Empleador_1__c.substring(0,2) + '-' + 
            contact.CUIT_Empleador_1__c.substring(2, contact.CUIT_Empleador_1__c.length() - 1) + '-' + 
            contact.CUIT_Empleador_1__c.substring(contact.CUIT_Empleador_1__c.length() - 1, contact.CUIT_Empleador_1__c.length()) : '';
        cuit2Formated = (contact.CUIT_Empleador_2__c != null && contact.CUIT_Empleador_2__c.length() >= 8 )? contact.CUIT_Empleador_2__c.substring(0,2) + '-' + 
            contact.CUIT_Empleador_2__c.substring(2, contact.CUIT_Empleador_2__c.length() - 1) + '-' + 
            contact.CUIT_Empleador_2__c.substring(contact.CUIT_Empleador_2__c.length() - 1, contact.CUIT_Empleador_2__c.length()) : '';
        cuit3Formated = (contact.CUIT_Empleador_3__c != null && contact.CUIT_Empleador_3__c.length() >= 8 )? contact.CUIT_Empleador_3__c.substring(0,2) + '-' + 
            contact.CUIT_Empleador_3__c.substring(2, contact.CUIT_Empleador_3__c.length() - 1) + '-' + 
            contact.CUIT_Empleador_3__c.substring(contact.CUIT_Empleador_3__c.length() - 1, contact.CUIT_Empleador_3__c.length()) : '';
        
        Set<String> attributesInfo = new Set<String>{'Movilidad__c', 'Profession__c', 'Education_Level__c', 'Ingreso__c', 'condicion_de_ingreso__c', 'Beneficios_Sociales__c'};
            //attributeTags = getTagListFromContactData(contact, attributesInfo);
            this.attributeTags = retrieveAttributesList(contact);

        
        List<String> lstContactInfo = new List<String>();
        if(String.isNotBlank(gender)) {
            lstContactInfo.add(gender);
        }
        if(String.isNotBlank(contact.Nacionalidad__c)) {
            //por que vuelvo a calcular el gender aca ?
            gender = String.isBlank(contact.Gender__c) ? Label.NoInformation : contact.Gender__c == 'F' ? Label.Female : Label.Male;
            //si la nacionalidad termina en A y es hombre... cambio la A por O Ej: Argentina -> Argentino. Boliviana -> Boliviano
            //si la nacionalidad termina en O y es mujer.... cambio la O por A Ej: Argentino -> Argentina. Boliviano -> Boliviana
            //si la nacionalidad no termina en A ni en O y es mujer, agrego una A --> Aleman -> Alemana - Ingles -> Inglesa
            //sino lo dejo como viene.
            if(contact.Gender__c != NULL && contact.Gender__c == 'M' && contact.Nacionalidad__c.endsWithIgnoreCase('a') ) {
                lstContactInfo.add(' ' + (contact.Nacionalidad__c.substring(0,contact.Nacionalidad__c.length() - 1) + 'o').toLowerCase() );
            } else if(contact.Gender__c != NULL && contact.Gender__c == 'F' && contact.Nacionalidad__c.endsWithIgnoreCase('o') ) {
                lstContactInfo.add(' ' + (contact.Nacionalidad__c.substring(0,contact.Nacionalidad__c.length() - 1) + 'a').toLowerCase() );
            } else if(contact.Gender__c != NULL && contact.Gender__c == 'F' && !contact.Nacionalidad__c.endsWithIgnoreCase('a')) {
                lstContactInfo.add(' ' + (contact.Nacionalidad__c + 'a').toLowerCase() );            
            } else {                
                lstContactInfo.add(' ' + contact.Nacionalidad__c.toLowerCase());                
            }
        }
        if(String.isNotBlank(dateString)) {
            lstContactInfo.add(' ' + dateString);
        }
        
        if(String.isNotBlank(contact.MailingStreet) ) {
            lstContactInfo.add(' ' + Label.LivesIn + ' ');
            if(contact.Administrative_Level_4__c != NULL) {
                strLevel2 = contact.Administrative_Level_4__c;
            } else if(contact.Administrative_Level_3__c != NULL) {
                strLevel2 = contact.Administrative_Level_3__c;
            } else if(contact.Administrative_Level_2__c != NULL) {
                strLevel2 = contact.Administrative_Level_2__c;
            } else if(contact.Administrative_Level_1__c != NULL) {
                strLevel2 = contact.Administrative_Level_1__c;
            }
            System.debug('contact : ' + contact);
            
            if(string.isNotBlank(strLevel2)) {
                strLevel2 = (strLevel2.indexOf('Comuna') >= 0)?'C.A.B.A':strLevel2;                
            }
            
            if(String.isNotBlank(contact.MailingNumber__c) ) {
                if(String.isNotBlank(strFloorApartment)) {
                    personAddress = String.format('{0} {1} {2}, {3}', new String[] {contact.MailingStreet, contact.MailingNumber__c, strFloorApartment, strLevel2 });                  		                
                    personAddressOnlyPisoDepto = String.format('{0} {1} {2}', new String[] {contact.MailingStreet, contact.MailingNumber__c, strFloorApartment }); 
                } else {                    
                    personAddress = String.format('{0} {1}, {2}', new String[] {contact.MailingStreet, contact.MailingNumber__c, strLevel2 });                  		                
                    personAddressOnlyPisoDepto = String.format('{0} {1}', new String[] {contact.MailingStreet, contact.MailingNumber__c });                     
                }
            } else {
                personAddress = String.format('{0} {1}, {2}', new String[] {contact.MailingStreet, strFloorApartment, strLevel2 });
                personAddressOnlyPisoDepto = String.format('{0} {1}', new String[] {contact.MailingStreet, strFloorApartment }); 
            }
        }
        personTitle = String.join(lstContactInfo, ',');
        /* Data Formating block */
        
        tagsCommunity = new List<String>();
        tagsCommunityHurlingham = new List<String>();
        tagsForCommunity = new List<String>();
        
        tagsAudience = new List<String>();
        tagsCDPCampaing = new List<String>();
        tagsCDPAxis = new List<String>();
        List<Network> lstNetwork = [SELECT NAME FROM NETWORK WHERE ID =: Network.getNetworkId()];
        
        if(lstNetwork.isEmpty() || lstNetwork[0].Name <> 'Hurlingham') {
            if(contact.Community__c != NULL && contact.Community__c.length() > 0) {
                tagsCommunity.addAll(capitalizeList(contact.Community__c.split(';')));
            }            
        }
        
        HelperFunctions.CommunitySite objCommunitySite = HelperFunctions.retrieveSite();
        
        if(contact.Audiencia_Politica__c != NULL && contact.Audiencia_Politica__c.length() > 0){
            tagsCommunity.addAll(capitalizeList(contact.Audiencia_Politica__c.split(';')));
            tagsForCommunity.addAll(capitalizeList(contact.Audiencia_Politica__c.split(';')));
            //tagsAudiencePol = capitalizeList(contact.Audiencia_Politica__c.split(';'));
        }
        if(contact.Audiencia_Electoral__c != NULL && contact.Audiencia_Electoral__c.length() > 0){
            tagsCommunity.addAll(capitalizeList(contact.Audiencia_Electoral__c.split(';')));
            tagsForCommunity.addAll(capitalizeList(contact.Audiencia_Electoral__c.split(';')));
            //tagsAudienceElect = capitalizeList(contact.Audiencia_Electoral__c.split(';'));
        }
        if(contact.Audiencia_Generaciones__c != NULL && contact.Audiencia_Generaciones__c.length() > 0){
            tagsCommunity.addAll(capitalizeList(contact.Audiencia_Generaciones__c.split(';')));
            tagsForCommunity.addAll(capitalizeList(contact.Audiencia_Generaciones__c.split(';')));
            //tagsAudienceGen = capitalizeList(contact.Audiencia_Generaciones__c.split(';'));
        }
        
        if(contact.actividades_economicas__c != NULL && contact.actividades_economicas__c.length() > 0){
            tagsCommunity.addAll(capitalizeList(contact.actividades_economicas__c.split(';')));
            tagsForCommunity.addAll(capitalizeList(contact.actividades_economicas__c.split(';')));
            //tagsActividadesEconomicas = capitalizeList(contact.actividades_economicas__c.split(';'));
        }      
        
        if(contact.CDP_Campaign__c != NULL && contact.CDP_Campaign__c.length() > 0){
            tagsCDPCampaing = capitalizeList(contact.CDP_Campaign__c.split(';'));
        }
        if(contact.CDP_Axis__c != NULL && contact.CDP_Axis__c.length() > 0){
            tagsCDPAxis = capitalizeList(contact.CDP_Axis__c.split(';'));
        }
        if(contact.CDP_Status__c != NULL){
            tagsCDPStatus = contact.CDP_Status__c.toLowerCase().capitalize();
        }
        if(contact.CDP_Score__c != NULL){
            tagsCDPScore = contact.CDP_Score__c.toLowerCase().capitalize();
        }
        if(contact.Tendencia_Politica_CBA__c != NULL) {
            
            tagsTendenciaPolitica = contact.Tendencia_Politica_CBA__c.toLowerCase().capitalize();
        }
        if(contact.Tendencia_Politica_STAFE__c != NULL){
            tagsTendenciaPoliticaSTAFE = contact.Tendencia_Politica_STAFE__c.toLowerCase().capitalize();
        }
        if(contact.Usuario_Twitter__c != NULL) {
            twitterUserFormated = contact.Usuario_Twitter__c;
        }else if(contact.Twitter_Link__c != NULL) {
            twitterUserFormated = contact.Twitter_Link__c.split('/')[3];
        }else{
            twitterUserFormated = '';
        }
        
        loadEditionValues();
    }
    
    private List<TagList> retrieveAttributesList(Contact objContact) {
        List<TagList> lstTags = null;
        Map<String, List<String>> mapAttributes = null;
        
        System.debug('retrieveAttributesList [objContact : ' + objContact + '] ->');
        
        mapAttributes = new Map<String, List<String>>();
        mapAttributes.put('Movilidad__c', new String[] { 'Movilidad__c' });
        mapAttributes.put('Profession__c', new String[] { 'Profession__c' });
        mapAttributes.put('Education_Level__c', new String[] { 'Education_Level__c' });
        mapAttributes.put('Ingreso__c', new String[] { 'Ingreso__c' });
        mapAttributes.put('condicion_de_ingreso__c', new String[] { 'condicion_de_ingreso__c' });
        List<Network> lstNetwork = [SELECT NAME FROM NETWORK WHERE ID =: Network.getNetworkId()];
        
        if(!lstNetwork.isEmpty() && lstNetwork[0].Name == 'Hurlingham') {
            mapAttributes.put('Beneficios_Sociales__c', new String[] { 'Beneficios_Sociales__c' });            
        } else {            
            mapAttributes.put('Beneficios_Sociales__c', new String[] { 'Beneficios_Sociales__c', 'Beneficios_Sociales_CBA__c' });
        }
        
        /*
mapAttributes.put('Audiencia_Politica__c', new String[] { 'Audiencia_Politica__c' });        
mapAttributes.put('Audiencia_Electoral__c', new String[] { 'Audiencia_Electoral__c' });
mapAttributes.put('Audiencia_Generaciones__c', new String[] { 'Audiencia_Generaciones__c' });
mapAttributes.put('actividades_economicas__c', new String[] { 'actividades_economicas__c' });

*/
        lstTags = getTagListFromContactData(objContact, mapAttributes);
        
        System.debug('retrieveAttributesList [' + lstTags + '] <-');
        
        return lstTags;
    }
    
    private List<TagList> getTagListFromContactData (Contact objContact, Map<String, List<String>> mapTags){
        TagList objTag = null;
        List<TagList> lstTagList = null;
        String strValue = null;
        
        lstTagList = new List<TagList>();
        for(String strTag : mapTags.keySet()) {
            objTag = new TagList();
            objTag.label = Utilities.getFieldLabel(strTag, 'Contact');
            objTag.value = '';
            for(String strField : mapTags.get(strTag)) {      
                strValue = Utilities.getFieldType(strTag, 'Contact') == 'MULTIPICKLIST' ? getStringFromPickList((String)objContact.get(strField)) : (String)objContact.get(strField);
                
                if(String.isNotBlank(objTag.value) && String.isNotBlank(strValue)) {
                    objTag.value += ' / ';
                }
                
                if(String.isNotBlank(strValue)) {
                    objTag.value += strValue;        
                }
            }
            
            if(String.isNotBlank(objTag.value)) {
                lstTagList.add(objTag);                
            }
        }
        return lstTagList;
    }
    /*
* Name: getBirthDateString
* Description: Transform the Date to a String that suits the requirements of the page
*/
    private String getBirthDateString(Date dateNumber, String gender) {
        List<String> months = new List<String>{'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'};
            String birthDateString = gender == 'F' ? 'nacida el ' : 'nacido el ';
        birthDateString += dateNumber.day() <= 9 ? '0' + dateNumber.day() : '' + dateNumber.day();
        birthDateString += ' de ' + months[dateNumber.month() - 1] + ' de ' + dateNumber.year();
        return birthDateString;
    }
    
    /*
* Name: getStringFromPickList
* Description: Transform the String from multi-select picklist to a String that suits the requirements of the page
*/
    private String getStringFromPickList(String plString){
        String newString = '';
        if(plString != null) {
            for(String item : plString.split(';')){
                if (newString == '') {
                    newString += item;
                } else {
                    newString += ' / ' + item;
                }
            }
        }
        return newString;
    }
    
    /* 
* Name: getTagListFromContactData
* Description: Transforms a list of fields of a contact object to a List of TagList objects
*/
    private List<TagList> getTagListFromContactData (Contact cont, Set<String> tagFields){
        List<TagList> tagList = new List<TagList>();
        for(String item : tagFields){
            TagList tag = new TagList();
            tag.label = Utilities.getFieldLabel(item, 'Contact');
            tag.value = Utilities.getFieldType(item, 'Contact') == 'MULTIPICKLIST' ? getStringFromPickList((String)cont.get(item)) : (String)cont.get(item);
            if(String.isNotBlank(tag.value)) {
                tagList.add(tag);                
            }
        }
        return tagList;
    }
    
    private void loadEditionValues () {
        movilityOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','Movilidad__c'));
        selectedMovilityOptions = contact.Movilidad__c != NULL ? contact.Movilidad__c.split(';') : new List<String>{};
            incomeOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','Ingreso__c'));
        selectedIncomeOption = contact.Ingreso__c != NULL ? contact.Ingreso__c: '';
        workConditionOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','condicion_de_ingreso__c'));
        selectedWorkConditionOptions = contact.condicion_de_ingreso__c != NULL ? contact.condicion_de_ingreso__c.split(';') : new List<String>{};
            socialBenefitsOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','Beneficios_Sociales__c'));
        selectedSocialBenefitsOptions = contact.Beneficios_Sociales__c != NULL ? contact.Beneficios_Sociales__c.split(';') : new List<String>{};
            
            socialBenefitsCBAOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','beneficios_Sociales_CBA__c'));
        selectedSocialBenefitsCBAOptions = contact.beneficios_Sociales_CBA__c != NULL ? contact.beneficios_Sociales_CBA__c.split(';') : new List<String>{};
            
            
            audiencePolOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','Audiencia_Politica__c'));
        selectedAudiencePolOptions = contact.Audiencia_Politica__c != NULL ? contact.Audiencia_Politica__c.split(';') : new List<String>{};
            audienceElecOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','Audiencia_Electoral__c'));
        selectedAudienceElecOptions = contact.Audiencia_Electoral__c != NULL ? contact.Audiencia_Electoral__c.split(';') : new List<String>{};
            audienceGenOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','Audiencia_Generaciones__c'));
        selectedAudienceGenOptions = contact.Audiencia_Generaciones__c != NULL ? contact.Audiencia_Generaciones__c.split(';') : new List<String>{};
            CDPStatusOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','CDP_Status__c'));
        selectedCDPStatusOption = contact.CDP_Status__c != NULL ? contact.CDP_Status__c : '';
        CDPScoreOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','CDP_Score__c'));
        selectedCDPScoreOption = contact.CDP_Score__c != NULL ? contact.CDP_Score__c : '';
        
        votingP15 = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','voting_P2015__c'));
        selectedvotingP15Option = contact.voting_P2015__c != NULL ? contact.voting_P2015__c : '';
        votingG15 = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','voting_G2015__c'));
        selectedvotingG15Option = contact.voting_G2015__c != NULL ? contact.voting_G2015__c : '';
        votingB15 = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','voting_B2015__c'));
        selectedvotingB15Option = contact.voting_B2015__c != NULL ? contact.voting_B2015__c : '';
        votingP17 = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','voting_P2017__c'));
        selectedvotingP17Option = contact.voting_P2017__c != NULL ? contact.voting_P2017__c : '';
        votingG17 = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','voting_G2017__c'));
        selectedvotingG17Option = contact.voting_G2017__c != NULL ? contact.voting_G2017__c : '';
        
        communityOptionsSearch = new List<String>();
        for (Schema.PicklistEntry ple : Utilities.retrievePicklistValues('Contact','Community__c')) {
            communityOptionsSearch.add(ple.getValue());
        }
        communityOptionsSearchSerialized = JSON.serialize(communityOptionsSearch);
        CDPCampaingOptionsSearch = new List<String>();
        for (Schema.PicklistEntry ple : Utilities.retrievePicklistValues('Contact','CDP_Campaign__c')) {
            CDPCampaingOptionsSearch.add(ple.getValue());
        }
        CDPCampaingSearchSerialized = JSON.serialize(CDPCampaingOptionsSearch);
        CDPAxisOptionsSearch = new List<String>();
        for (Schema.PicklistEntry ple : Utilities.retrievePicklistValues('Contact','CDP_Axis__c')) {
            CDPAxisOptionsSearch.add(ple.getValue());
        }
        CDPAxisSearchSerialized = JSON.serialize(CDPAxisOptionsSearch);
        CDPStatusOptionsSearch = new List<String>();
        for (Schema.PicklistEntry ple : Utilities.retrievePicklistValues('Contact','CDP_Status__c')) {
            CDPStatusOptionsSearch.add(ple.getValue());
        }
        CDPStatusSearchSerialized = JSON.serialize(CDPStatusOptionsSearch);
        CDPScoreOptionsSearch = new List<String>();
        for (Schema.PicklistEntry ple : Utilities.retrievePicklistValues('Contact','CDP_Score__c')) {
            CDPScoreOptionsSearch.add(ple.getValue());
        }
        CDPScoreSearchSerialized = JSON.serialize(CDPScoreOptionsSearch);
        
        /* Comento esto por cambio de MM (por si hay que regresarlo)
		* ACA HABRIA QUE PONER CUAL FUE EL CAMBIO QUE PROPUSO MM, SINO NO SE ENTIENDE QUE HACIA EL ANTIGUO CODIGO Y QUE HACE EL NUEVO
		communityTagsOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','Community__c'));
		selectedCommunityTagsOptions = contact.Community__c != NULL ? contact.Community__c.split(';') : new List<String>{};*/
        
        selectedCommunityTagsOptions = contact.Community__c != NULL ? contact.Community__c.split(';') : new List<String>{};
        selectedCDPCampaingTagsOptions = contact.CDP_Campaign__c != NULL ? contact.CDP_Campaign__c.split(';') : new List<String>{};
        selectedCDPAxisTagsOptions = contact.CDP_Axis__c != NULL ? contact.CDP_Axis__c.split(';') : new List<String>{};
		communityTagsOptions = new List<SelectOption>();
        
        for(String option : selectedCommunityTagsOptions){
            communityTagsOptions.add(new SelectOption(option, option));
        }
        CDPCampaingTagsOptions = new List<SelectOption>();
        for(String option : selectedCDPCampaingTagsOptions){
            CDPCampaingTagsOptions.add(new SelectOption(option, option));
        }
        CDPAxisTagsOptions = new List<SelectOption>();
        for(String option : selectedCDPAxisTagsOptions){
            CDPAxisTagsOptions.add(new SelectOption(option, option));
        }
        
        tendenciaPoliticaCBAOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','Tendencia_Politica_CBA__c'));
        tendenciaPoliticaCBAOptions.add(0, new SelectOption('','--- Seleccionar ---'));
        tendenciaPoliticaCBASelected = (contact.Tendencia_Politica_CBA__c != NULL)?contact.Tendencia_Politica_CBA__c:'';
        
        tendenciaPoliticaSTAFEOptions = Utilities.buildPickListOptions(Utilities.retrievePicklistValues('Contact','Tendencia_Politica_STAFE__c'));
        tendenciaPoliticaSTAFEOptions.add(0, new SelectOption('','--- Seleccionar ---'));
        tendenciaPoliticaSTAFESelected = (contact.Tendencia_Politica_STAFE__c != NULL)?contact.Tendencia_Politica_STAFE__c:'';
        
    }
    
    
    private List<String> capitalizeList(List<String> listStr) {
        List<String> returnList = new List<String>();
        for(String s : listStr){
            s = s.toLowerCase().capitalize();
            returnList.add(s);
        }
        return returnList;
    }
    
    private List<String> capitalizeListNames(List<String> lstFieldList) {
        List<String> lstResult = null;
        String[] arrFields = null;
        String strWordResult = null;
        Boolean boolFirst = true;
        
        lstResult = new List<String>();
        for(String strField : lstFieldList){	
            arrFields = strField.split(' ');
            strWordResult = '';
            for(String strWord : arrFields) {
                if(boolFirst) {
                    boolFirst = false;
                } else {
                    strWordResult += ' ';
                }
                strWordResult += strWord.toLowerCase().capitalize();
            }
            lstResult.add(strWordResult);
        }
        return lstResult;
    }
    
}