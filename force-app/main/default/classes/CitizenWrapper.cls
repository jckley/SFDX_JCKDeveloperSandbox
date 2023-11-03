public class CitizenWrapper {
    private HelperFunctions.CommunitySite communitySite { get; set; }
    
    public class GeneralInfo {
        private HelperFunctions.CommunitySite communitySite { get; set; }
        private String Level {get; set;}
        private String FloorApartment {get; set;}    
        private String Nationality {get; set;}  
        private String Birthdate { get; set; }

        @AuraEnabled
        public String Title { get; set; }        
        @AuraEnabled
        public String Address { get; set; }
        @AuraEnabled
        public String Picture { get; set; }
        @AuraEnabled
        public String Gender { get; set; }
        @AuraEnabled
        public String BirthdateSPFormat { get; set; }
        @AuraEnabled
        public String CUIT { get; set; }
        @AuraEnabled
        public String DNI { get; set; }
        @AuraEnabled
        public String addressSimple { get; set; }
        
        @AuraEnabled
        public String relatedQuery { get; set; }
        @AuraEnabled
        public Boolean hasRelatedCoh { get; set; }

        
        public GeneralInfo(HelperFunctions.CommunitySite objCommunitySite, Contact objContact) {
            this.communitySite = objCommunitySite;
            this.Gender = String.isBlank(objContact.Gender__c) ? Label.NoInformation : objContact.Gender__c == 'F' ? Label.Female : Label.Male;
            this.Level = retrieveAddressLevel(objContact);
            this.FloorApartment = retrieveFloorApartment(objContact);
            this.Nationality = retrieveNationality(objContact);
            this.Birthdate = HelperFunctions.convertDateToString(objContact.Birthdate);
            this.BirthdateSPFormat = objContact.Birthdate.format();
            this.relatedQuery = retrieveRelatedQuery(objContact);
            this.hasRelatedCoh = retrieveRelatedCoh(objContact);
                
            this.addressSimple = retrieveAddressSimple(objContact);
            this.Address = retrieveAddress();
            this.Title = retrieveContactInfo(objContact);
            this.Picture = objContact.PhotoUrl_legacy__c; 
            
            System.debug('GeneralInfo [ RecordType : ' + objContact.RecordType.DeveloperName  +  ']');
            if(objContact.RecordType.DeveloperName == 'Argentino') {
                System.debug('GeneralInfo [ RecordType : Argentino ]');
                this.CUIT = HelperFunctions.formatCUIT(objContact.Cuil_Number__c);
                this.DNI = HelperFunctions.formatNumberString(objContact.Document_Number__c);
    
            } else if(objContact.RecordType.DeveloperName == 'Ecuatoriano') {
                System.debug('GeneralInfo [ RecordType : Ecuatoriano ]');
                if(objContact.Cuil_Number__c != NULL && objContact.Cuil_Number__c.length() == 13) {
                    this.CUIT = objContact.Cuil_Number__c.substring(0, 10) + ' ' + objContact.Cuil_Number__c.substring(10,13);
                }

                if(objContact.Document_Number__c != NULL && objContact.Document_Number__c.length() == 10) {
                    this.DNI = objContact.Document_Number__c.substring(0, 9) + '-' + objContact.Document_Number__c.substring(9,10);
                }
            
            // VER CHILE
            } else if(objContact.RecordType.DeveloperName == 'Chileno') {
                System.debug('GeneralInfo [ RecordType : Chileno ]');
                this.CUIT = HelperFunctions.formatCUIT(objContact.Cuil_Number__c);
                this.DNI = HelperFunctions.formatNumberString(objContact.Document_Number__c);
            }
        }

        private String retrieveRelatedQuery(Contact objContact) { 
            String strQuery = null;
            List<String> lstParams = null;
            Boolean boolFirst = true;

            lstParams = new List<String>();

            if(String.isNotBlank(objContact.grouphash_coh__c)) {
                lstParams.add(objContact.grouphash_coh__c);
            }

            if(String.isNotBlank(objContact.grouphash_cot__c)) {
                lstParams.add(objContact.grouphash_cot__c);
            }

            if(String.isNotBlank(objContact.grouphash_coe__c)) {
                lstParams.add(objContact.grouphash_coe__c);                
            }

            if(String.isNotBlank(objContact.grouphash_cof__c)) {
                lstParams.add(objContact.grouphash_cof__c);                
            } 

            strQuery = '';
            if(!lstParams.isEmpty()) {
                for(String strParam : lstParams) {
                    if(boolFirst) {
                        boolFirst = false;
                    } else {
                        strQuery += ' OR ';
                    }

                    strQuery += '"' + strParam + '"';
                }
            }

            return strQuery;
        }


        private Boolean retrieveRelatedCoh(Contact objContact) { 

            Boolean ans = false;

            if(String.isNotBlank(objContact.grouphash_coh__c)) {

                String strSearch = objContact.grouphash_coh__c;

                List<List<sObject>> lstResults = null;

                System.debug('retrieveRelatedCoh [ strSearch : ' + strSearch +  '] ->');
                
                lstResults = [FIND :strSearch IN ALL FIELDS  
                              RETURNING Contact(Id, Name,Document_Number__c, Age_f_x__c, Administrative_Level_2__c,  covid19_salud_status__c )
                              LIMIT 2];
        
                System.debug('retrieveRelatedCoh [ lstResults : ' + lstResults + ']');
                System.debug('retrieveRelatedCoh [ lstResults.size() : ' + lstResults[0].size() + ']');
                
                if (!lstResults.isEmpty())
                    if (lstResults[0].size() > 1)
                        ans = true;
            }

            return ans;
        }


        private String retrieveRelatedQuery_OLD(Contact objContact) {
            List<String> lstQueryPart = null;
            String strAddress = null;
            String strQuery = null;

            System.debug('retrieveRelatedQuery [] ->');

            lstQueryPart = new List<String>();

            if(String.isNotBlank(objContact.MailingStreet)) {    
                strAddress = objContact.MailingStreet;
                if(String.isNotBlank(objContact.MailingNumber__c)) {
                    strAddress += ' ' + objContact.MailingNumber__c ;                  		                
                }
                lstQueryPart.add(' ( '  + strAddress + ' ) ');
            }

            if(String.isNotBlank(objContact.CUIT_Empleador_1__c)) {    
                lstQueryPart.add(' ( '  + objContact.CUIT_Empleador_1__c + ' ) ');
            }

            if(String.isNotBlank(objContact.mig_inbound_transportation_id__c)) {    
                lstQueryPart.add(' ( '  + objContact.mig_inbound_transportation_id__c + ' ) ');
            }

            
            if(String.isNotBlank(objContact.mig_outbound_transportation_id__c)) {    
                lstQueryPart.add(' ( '  + objContact.mig_outbound_transportation_id__c + ' ) ');
            }

            if(!lstQueryPart.IsEmpty()) {    
                strQuery = String.join(lstQueryPart, ' OR ');
            }

            System.debug('retrieveRelatedQuery [' + strQuery +  '] <-');
            return strQuery;
        }
         
        private String retrieveContactInfo(Contact objContact) {
            List<String> lstContactInfo = null;
            
            System.debug('retrieveContactInfo [] ->');
            
            lstContactInfo = new List<String>();
            if(String.isNotBlank(this.Gender)) {
                lstContactInfo.add(this.Gender);
            }
            
            if(String.isNotBlank(this.Nationality)) {
                lstContactInfo.add(this.Nationality);
            }
            
            if(String.isNotBlank(this.Birthdate)) {
                lstContactInfo.add(this.Birthdate);
            }
            
            if(String.isNotBlank(this.Address)) {
                lstContactInfo.add(' ' +  Label.LivesIn + ' ');
            }
            
            System.debug('retrieveContactInfo [] <-');
            
            return String.join(lstContactInfo, ', ');
        }
          
        private String retrieveAddressLevel(Contact objContact) {
            String strLevel = null;
            
            System.debug('retrieveAddressLevel [] ->');
            
            if(String.isNotBlank(objContact.Administrative_Level_4__c) && objContact.Administrative_Level_4__c.toLowerCase() != 'sin especificar') {
                strLevel = objContact.Administrative_Level_4__c;
            } else if(String.isNotBlank(objContact.Administrative_Level_3__c) && objContact.Administrative_Level_3__c.toLowerCase() != 'sin especificar') {
                strLevel = objContact.Administrative_Level_3__c;
            } else if(String.isNotBlank(objContact.Administrative_Level_2__c) && objContact.Administrative_Level_2__c.toLowerCase() != 'sin especificar') {
                strLevel = objContact.Administrative_Level_2__c;
            } else if(String.isNotBlank(objContact.Administrative_Level_1__c) && objContact.Administrative_Level_1__c.toLowerCase() != 'sin especificar') {
                strLevel = objContact.Administrative_Level_1__c;
            }
            if(string.isNotBlank(strLevel)) {
                strLevel = (strLevel.indexOf('Comuna') >= 0)?'C.A.B.A':strLevel;                               
            }
            
            System.debug('retrieveAddressLevel [' + strLevel +'] <-');
            return strLevel;
        }
        
        private String retrieveFloorApartment(Contact objContact) { 
            String strFloorApartment = null;
            System.debug('retrieveFloorApartment [] ->');
            
            if(objContact.MailingAppartment__c != null) {
                strFloorApartment = String.format('{0}', new String [] { objContact.MailingAppartment__c });
            } else {
                strFloorApartment = '';
            }
            
            System.debug('retrieveFloorApartment [' + strFloorApartment + '] <-');
            
            return strFloorApartment;
        }
        
        private String retrieveNationality(Contact objContact) {
            String strNationality = null;
            
            System.debug('retrieveNationality [] ->');
            if(String.isNotBlank(objContact.Nacionalidad__c)) {
                if(String.isNotBlank(objContact.Gender__c)) {
                    if(objContact.Gender__c == 'M' && objContact.Nacionalidad__c.endsWithIgnoreCase('a')) {
                        strNationality = (objContact.Nacionalidad__c.substring(0,objContact.Nacionalidad__c.length() - 1) + 'o').toLowerCase();
                    } else if(objContact.Gender__c == 'F' && objContact.Nacionalidad__c.endsWithIgnoreCase('o')) {
                        strNationality = (objContact.Nacionalidad__c.substring(0,objContact.Nacionalidad__c.length() - 1) + 'a').toLowerCase();
                    } else if(objContact.Gender__c == 'F' && !objContact.Nacionalidad__c.endsWithIgnoreCase('a')) {
                        strNationality = (objContact.Nacionalidad__c + 'a').toLowerCase();
                    } else {
                        strNationality = objContact.Nacionalidad__c.toLowerCase();
                    }
                } else {
                    strNationality = objContact.Nacionalidad__c.toLowerCase();
                }
            }
                      
            System.debug('retrieveNationality [' + strNationality + '] <-');
            
            return strNationality;
        }
        
        private String retrieveAddressSimple(Contact objContact) {
            String strAddress = null;
            
            System.debug('retrieveAddressSimple [] ->');

            if(String.isNotBlank(objContact.MailingStreet)) {    
                objContact.MailingStreet = String.join(HelperFunctions.capitalizeList(objContact.MailingStreet.split(' ')), ' ');
                if(String.isNotBlank(objContact.MailingNumber__c) ) {
                    if(String.isNotBlank(this.FloorApartment)) {
                        strAddress = String.format('{0} {1} {2}', new String[] {objContact.MailingStreet, objContact.MailingNumber__c, this.FloorApartment  });                  		                
                    } else {                    
                        strAddress = String.format('{0} {1}', new String[] {objContact.MailingStreet, objContact.MailingNumber__c });                  		                
                    }
                } else {
                    if(String.isNotBlank(this.FloorApartment)) {
                        strAddress = String.format('{0} {1}, {2}', new String[] {  objContact.MailingStreet, this.FloorApartment});
                    } else {                    
                        strAddress = String.format('{0}', new String[] {objContact.MailingStreet });
                    }                
                }
            } else {
                strAddress = '';
            }

            System.debug('retrieveAddressSimple [' + strAddress + '] <-');
            return strAddress;
        }
        
        private String retrieveAddress() {
            String strAddress = null;
            
            System.debug('retrieveAddress [] ->');
            
            if(String.isNotBlank(this.AddressSimple) && String.isNotBlank(this.Level)  ) {
                strAddress = String.format('{0}, {1}', new String[] {this.AddressSimple, String.join(HelperFunctions.capitalizeList(this.Level.split(' ')), ' ') });                  		                
            } 
            
            System.debug('retrieveAddress [' + strAddress + '] <-');
            return strAddress;
        }
    }

    public class Attributes {
        private HelperFunctions.CommunitySite communitySite { get; set; }

        @AuraEnabled
        public List<Attribute> items { get; set; }
        @AuraEnabled
        public AttributesEditables mobility { get; set; }
        @AuraEnabled
        public AttributesEditables incometype { get; set; }
        @AuraEnabled
        public AttributesEditables workCondition { get; set; }
        @AuraEnabled
        public AttributesEditables socialBenefits { get; set; }
        @AuraEnabled
        public AttributesEditables socialBenefitsCBA { get; set; }
        // @AuraEnabled
        // public String licensePlate { get; set; }
                
        public Attributes(HelperFunctions.CommunitySite objCommunitySite, Contact objContact) {
            this.communitySite = objCommunitySite;
            this.items = retrieveAttributes(objContact);
            this.mobility = new AttributesEditables(objCommunitySite, objContact, 'Movilidad__c' );
            this.incometype = new AttributesEditables(objCommunitySite, objContact, 'Ingreso__c' );
            this.workCondition = new AttributesEditables(objCommunitySite, objContact, 'Condicion_de_Ingreso__c' );
            this.socialBenefits = new AttributesEditables(objCommunitySite, objContact, 'Beneficios_Sociales__c' );
            this.socialBenefitsCBA = new AttributesEditables(objCommunitySite, objContact, 'Beneficios_Sociales_CBA__c' );
            // this.licensePlate = objContact.licensePlate__c;
        }
        
        private List<Attribute> retrieveAttributes(Contact objContact) {
            Map<String, List<String>> mapAttributes = null;
            List<Attribute> lstAttributes = null;
            
            System.debug('retrieveAttributes [objContact : ' + objContact + '] ->');
            
            mapAttributes = new Map<String, List<String>>();
            mapAttributes.put('Movilidad__c', new String[] { 'Movilidad__c' });
            mapAttributes.put('Profession__c', new String[] { 'Profession__c' });
            mapAttributes.put('Education_Level__c', new String[] { 'Education_Level__c' });
            mapAttributes.put('Ingreso__c', new String[] { 'Ingreso__c' });
            mapAttributes.put('jerarquia_empleo__c', new String[] { 'jerarquia_empleo__c' });
            mapAttributes.put('condicion_de_ingreso__c', new String[] { 'condicion_de_ingreso__c'  });
            // mapAttributes.put('licensePlate__c', new String[] { 'licensePlate__c'  });
            //mapAttributes.put('Vota_a__c', new String[] { 'Vota_a__c'  });
            
            if(this.communitySite == HelperFunctions.CommunitySite.HURLINGHAM) {
                mapAttributes.put('Beneficios_Sociales__c', new String[] { 'Beneficios_Sociales__c' });            
            } else {            
                mapAttributes.put('Beneficios_Sociales__c', new String[] { 'Beneficios_Sociales__c', 'Beneficios_Sociales_CBA__c' });
            }
            
            lstAttributes = retrieveAttributeList(objContact, mapAttributes);
            
            System.debug('retrieveAttributes [' + lstAttributes + '] <-');
            
            return lstAttributes;
        }
        
        private List<Attribute> retrieveAttributeList(Contact objContact, Map<String, List<String>> mapAttributes){
            List<Attribute> lstAttributes = null;
            Attribute objAttribute = null;
            String strValue = null;
            
            System.debug('retrieveAttributes [objContact : ' + objContact + ' - mapAttributes : ' + mapAttributes + '] ->');

            lstAttributes = new List<Attribute>();
            for(String strAttribute : mapAttributes.keySet()) {
                objAttribute = new Attribute();
                objAttribute.label = HelperFunctions.getFieldLabel(strAttribute, 'Contact');
                objAttribute.value = '';
                for(String strField : mapAttributes.get(strAttribute)) {      
                    if(HelperFunctions.getFieldType(strAttribute, 'Contact') == 'MULTIPICKLIST') {
                        if(strField.toLowerCase().equals('condicion_de_ingreso__c')) {
                            strValue = getStringFromPickListCondicionIngreso(objContact, (String)objContact.get(strField));                            
                        } else {
                            strValue = getStringFromPickList((String)objContact.get(strField));
                        }
                    } else {
                        strValue = (String)objContact.get(strField);
                    }                    

                    if(String.isNotBlank(objAttribute.value) && String.isNotBlank(strValue)) {
                        objAttribute.value += ' / ';
                    }
                    
                    if(String.isNotBlank(strValue)) {
                        objAttribute.value += strValue;        
                    }
                }
                
                if(String.isNotBlank(objAttribute.value)) {
                    lstAttributes.add(objAttribute);                
                }
            }
            
            System.debug('retrieveAttributes [' + lstAttributes + '] <-');

            return lstAttributes;
        }
        
        private String getStringFromPickList(String strPicklistValues){
            String strPicklistValuesFormatted = null;
            
            if(String.isNotBlank(strPicklistValues)) {
                for(String strPicklistValue : strPicklistValues.split(';')){
                    if (String.isBlank(strPicklistValuesFormatted)) {
                        strPicklistValuesFormatted = strPicklistValue;
                    } else {
                        strPicklistValuesFormatted += ' / ' + strPicklistValue;
                    }
                }
            }
            return strPicklistValuesFormatted;
        }

        private String getStringFromPickListCondicionIngreso(Contact objContact, String strPicklistValues){
            String strPicklistValuesFormatted = null;
            
            if(String.isNotBlank(strPicklistValues)) {
                for(String strPicklistValue : strPicklistValues.split(';')){
                    if (String.isBlank(strPicklistValuesFormatted)) {
                        strPicklistValuesFormatted = strPicklistValue;
                    } else {
                        strPicklistValuesFormatted += ' / ' + strPicklistValue;
                    }

                    if(strPicklistValue.toLowerCase().equals('asalariado') && String.isNotBlank(objContact.tipo_de_asalariado__c)) {
                        strPicklistValuesFormatted += ' ' + objContact.tipo_de_asalariado__c;
                    }
                }
            }
            return strPicklistValuesFormatted;
        }
    }
    
    public class Attribute {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
    }
    
    public class AttributesEditables {
        public List<SelectOption> items { get; set; }
        public List<String> itemsSelected { get; set; }

        public AttributesEditables(HelperFunctions.CommunitySite objCommunitySite, Contact objContact, String strField) {
            List<Schema.PicklistEntry> lstPickListValues = null;

            lstPickListValues = HelperFunctions.retrievePicklistValues('Contact', strField);
            this.items = HelperFunctions.buildPickListOptions(lstPickListValues);     
            
            if(objContact.get(strField) != NULL) {
                this.itemsSelected = ( (String)objContact.get(strField)).split(';');
            } else {
                this.itemsSelected = new List<String>();
            }
            
        }
    }


    public class MovilidadInfo { 
        private HelperFunctions.CommunitySite communitySite { get; set; }

        @AuraEnabled
        public List<Movilidad> movilidades { get; set; }

        public MovilidadInfo(HelperFunctions.CommunitySite objCommunitySite, Contact objContact) {
            this.communitySite = objCommunitySite;
            this.movilidades = retrieveMovilidad(objContact);
        }

        private List<Movilidad> retrieveMovilidad(Contact objContact) {
            List<Movilidad> lstMovilidades = new List<Movilidad>();
            System.debug('retrieveMovilidad -> Movilidad__c[' + objContact.Movilidad__c +'] <-');


            // List<String> lstVehiculoClase = objContact.Movilidad__c != null ? objContact.Movilidad__c.split(';') : new List<String>();
            List<String> lstVehiculoClase = objContact.movilidad_clase__c != null ? objContact.movilidad_clase__c.split(';') : new List<String>();
            List<String> lstVehiculoDesc = objContact.movilidad_desc__c != null ? objContact.movilidad_desc__c.split(';') : new List<String>();
            List<String> lstVehiculoPatente = objContact.movilidad_patente__c != null ? objContact.movilidad_patente__c.split(';') : new List<String>();

            Integer maxlen = Math.max(Math.max(lstVehiculoClase.size(), lstVehiculoDesc.size()), lstVehiculoPatente.size());

            for (Integer i = 0 ; i < maxlen ; i++) {
                String clase = i < lstVehiculoClase.size() ? lstVehiculoClase[i] : '';
                String descripcion = i < lstVehiculoDesc.size() ? lstVehiculoDesc[i] : '';
                String patente = i < lstVehiculoPatente.size() ? lstVehiculoPatente[i] : '';

                lstMovilidades.add(new Movilidad(clase, descripcion, patente));
            }

            return lstMovilidades;
        }
    }

    public class Movilidad {
        @AuraEnabled
        public String clase { get; set; }
        @AuraEnabled
        public String descripcion { get; set; }
        @AuraEnabled
        public String patente { get; set; }

        public Movilidad(String clase, String descripcion, String patente) {
            this.clase = clase;
            this.descripcion = descripcion;
            this.patente = patente;
        }    
    }



    public class IncomeInfo { 
        private HelperFunctions.CommunitySite communitySite { get; set; }

        @AuraEnabled
        public String totalIncome 		 { get; set; }
        @AuraEnabled
        public List<EmployerInfo> employers { get; set; }
        
        public IncomeInfo(HelperFunctions.CommunitySite objCommunitySite, Contact objContact) {
            this.communitySite = objCommunitySite;

            this.employers = retrieveEmployers(objContact);
            
            if(objContact.Income_Total__c != NULL) {
                this.totalIncome = HelperFunctions.formatNumberString(String.valueOf(Integer.valueOf(objContact.Income_Total__c)));
            }
        }
        
        private List<EmployerInfo> retrieveEmployers(Contact objContact) {
            List<EmployerInfo> lstEmployers = null;
            
            lstEmployers = new List<EmployerInfo>();
            if(String.isNotBlank(objContact.CUIT_Empleador_1__c)) {
                lstEmployers.add(new EmployerInfo(objContact.Employer_1__c, objContact.CUIT_Empleador_1__c, objContact.Sueldo_1__c, objContact.Activity_1__c));                
            }
            
            if(String.isNotBlank(objContact.CUIT_Empleador_2__c)) {
                lstEmployers.add(new EmployerInfo(objContact.Employer_2__c, objContact.CUIT_Empleador_2__c, objContact.Sueldo_2__c, objContact.Activity_2__c));
            }
            
            if(String.isNotBlank(objContact.CUIT_Empleador_3__c)) {
                lstEmployers.add(new EmployerInfo(objContact.Employer_3__c, objContact.CUIT_Empleador_3__c, objContact.Sueldo_3__c, objContact.Activity_3__c));
            }
            return lstEmployers;
        }
    }
    
    public class EmployerInfo {
        @AuraEnabled
        public String name   { get; set; }
        @AuraEnabled
        public String cuit   { get; set; }
        @AuraEnabled
        public String income { get; set; }
        @AuraEnabled
        public String activity { get; set; }

        public EmployerInfo(String strName, String strCUIT, Decimal dblIncome, String strActivity) {
            strCUIT = HelperFunctions.formatCUIT(strCUIT);
            
            // this.name = (String.isNotBlank(strName))?strName:strCUIT;
            this.name = (String.isNotBlank(strName)) ? strName : '-';
            this.cuit = strCUIT;
            this.activity = (String.isNotBlank(strActivity)) ? strActivity : '';
            if(dblIncome != NULL) {
                this.income = HelperFunctions.formatNumberString(String.valueOf(Integer.valueOf(dblIncome)));
            } 
        }    
    }
    
    public class ElectoralInfo {
        private HelperFunctions.CommunitySite communitySite { get; set; }

        @AuraEnabled
        public ElectoralElectionInfo election2015 { get; set; }
        @AuraEnabled
        public ElectoralElectionInfo election2017 { get; set; }
        @AuraEnabled
        public ElectoralElectionInfo election2019 { get; set; }
        @AuraEnabled
        public ElectoralElectionInfo election2021 { get; set; }

        @AuraEnabled
        public Boolean showElectoralDetails { get; set; }
        
        public ElectoralInfo(HelperFunctions.CommunitySite objCommunitySite, Contact objContact) {
            this.communitySite = objCommunitySite;
            //no muestro los "campos gaston"
            this.showElectoralDetails = false;
			this.election2015 = new ElectoralElectionInfo(objContact, '2015');
            this.election2017 = new ElectoralElectionInfo(objContact, '2017');
            this.election2019 = new ElectoralElectionInfo(objContact, '2019');
            this.election2021 = new ElectoralElectionInfo(objContact, '2021');
        }            
    }

    public class ElectoralElectionInfo {
        @AuraEnabled
        public String PASO 		{ get; set; }
        @AuraEnabled
        public String General 	{ get; set; }
        @AuraEnabled
        public String Ballotage { get; set; }
        
        @AuraEnabled
        public String PASOValue 	 { get; set; }
        @AuraEnabled
        public String GeneralValue 	 { get; set; }
        @AuraEnabled
        public String BallotageValue { get; set; }

        @AuraEnabled
        public List<RemotingMessageHelper.CustomSelectOptions> PASOOptions { get; set; }
        @AuraEnabled
        public List<RemotingMessageHelper.CustomSelectOptions> GeneralOptions { get; set; }
        @AuraEnabled
        public List<RemotingMessageHelper.CustomSelectOptions> BallotageOptions { get; set; }
        
        public ElectoralElectionInfo(Contact objContact, String strElectoralYear) {
            String strField = null;
            
            strField = String.format('voting_P{0}__c', new String[] {strElectoralYear});
            if(HelperFunctions.hasSObjectField(strField, 'Contact')) {
                this.PASOValue = (String)objContact.get(strField);      
                this.PASO = (this.PASOValue == 'EMITIDO')?Label.Yes:Label.No;
                this.PASOOptions = HelperFunctions.buildPickListCustomOptions(HelperFunctions.retrievePicklistValues('Contact', strField)); 
            }
            
            strField = String.format('voting_G{0}__c', new String[] {strElectoralYear});
            if(HelperFunctions.hasSObjectField(strField, 'Contact')) {
                this.GeneralValue = (String)objContact.get(strField);     
                this.General = (this.GeneralValue == 'EMITIDO')?Label.Yes:Label.No;
                this.GeneralOptions = HelperFunctions.buildPickListCustomOptions(HelperFunctions.retrievePicklistValues('Contact', strField));
            }
            
            strField = String.format('voting_B{0}__c', new String[] {strElectoralYear});
            if(HelperFunctions.hasSObjectField(strField, 'Contact')) {
                this.BallotageValue = (String)objContact.get(strField);     
                this.Ballotage = (this.BallotageValue == 'EMITIDO')?Label.Yes:Label.No;
                this.BallotageOptions = HelperFunctions.buildPickListCustomOptions(HelperFunctions.retrievePicklistValues('Contact', strField));
            }
        }
    }

    public class ElectoralPaso2023 {
        @AuraEnabled
        public ElectoralPaso2023Info paso2023 { get; set; }

        public ElectoralPaso2023(Contact objContact) {
            this.paso2023 = new ElectoralPaso2023Info(objContact);
        }            
    }

    public class ElectoralPaso2023Info {
        @AuraEnabled
        public String ElectionPASO2023JM	{ get; set; }

        @AuraEnabled
        public String ElectionPASO2023JS 	{ get; set; }

        @AuraEnabled
        public String ElectionPASO2023JxC   { get; set; }

        @AuraEnabled
        public String ElectionPASO2023UxP 	 { get; set; }

        @AuraEnabled
        public String ElectionPASO2023Presentismo  { get; set; }

        @AuraEnabled
        public String ElectionPASO2023IntencionVoto { get; set; }

        public ElectoralPaso2023Info(Contact objContact) {
            this.ElectionPASO2023JM = String.valueOf(objContact.voting_PASO2023_JM__c);
            this.ElectionPASO2023JS = String.valueOf(objContact.voting_PASO2023_JS__c);
            this.ElectionPASO2023JxC = String.valueOf(objContact.voting_PASO2023_JXC__c);
            this.ElectionPASO2023UxP = String.valueOf(objContact.voting_PASO2023_UXP__c);
            this.ElectionPASO2023Presentismo = String.valueOf(objContact.voting_PASO2023_turnout__c);
            this.ElectionPASO2023IntencionVoto = objContact.voting_intent_PASO2023__c;
        }
    }


    public class HashtagsInfo {
        private HelperFunctions.CommunitySite communitySite { get; set; }
        private Contact citizen { get; set; }
        
        @AuraEnabled
        public List<String> tags { get; set; }        
        @AuraEnabled
        public List<String> tagsEPDLG { get; set; }
        @AuraEnabled
        public List<String> HastEditables { get; set; }
        
        @AuraEnabled
        public HashtagPicklist tagsCommunity { get; set; }
        @AuraEnabled
        public HashtagPicklist tagsAudienciaPolitica { get; set; }
        @AuraEnabled
        public HashtagPicklist tagsAudienciaElectoral { get; set; }
        @AuraEnabled
        public HashtagPicklist tagsAudienciaGeneraciones { get; set; }
        @AuraEnabled
        public HashtagPicklist tagsActividadesEconomicas { get; set; }
        
        @AuraEnabled
        public HashtagPicklist tagsCDPCampaign { get; set; }
        @AuraEnabled
        public HashtagPicklist tagsCDPAxis { get; set; }
        @AuraEnabled
        public HashtagPicklist tagsCDPStatus { get; set; }
        @AuraEnabled
        public HashtagPicklist tagsCDPScore { get; set; }
        @AuraEnabled
        public HashtagPicklist tagsSituacionAsalariado { get; set; }
        @AuraEnabled
        public HashtagPicklist tagsTribuElectoral2021 { get; set; }

        public List<RemotingMessageHelper.CustomSelectOptions> 	tagsTendeciaPoliticaCBA { get; set; }
        public List<RemotingMessageHelper.CustomSelectOptions> 	tagsTipoAsalariado { get; set; }
        public List<RemotingMessageHelper.CustomSelectOptions> 	tagsDelphosTribe2019 { get; set; }
        
        public HashtagsInfo(HelperFunctions.CommunitySite objCommunitySite, Contact objContact) {
	        this.communitySite = objCommunitySite;
            this.citizen = objContact;
            this.tags = retrieveHashtags(objContact); 
            
            this.tagsEPDLG = retrieveHashtagsEPDLG(objContact); 
            
            this.tagsCommunity = new HashtagPicklist();
            this.tagsCommunity.tagsAvailable = retrieveCommunityTagsAvailable();
            this.tagsCommunity.tagsAvailableSerialized  = JSON.serialize(this.tagsCommunity.tagsAvailable);
            this.tagsCommunity.tagsSelected = retrieveSelectedCommunityTags(objContact);
            this.tagsCommunity.tags = retrieveCommunityTags();
             
            this.tagsTendeciaPoliticaCBA = retrieveTendenciaPoliticaCBA();
            this.tagsTipoAsalariado = retrieveTipoAsalariado();
            this.tagsDelphosTribe2019 = retrieveDelphosTribe2019();

            this.tagsTribuElectoral2021 = new HashtagPicklist();
            this.tagsTribuElectoral2021.tags = retrieveTribuElectoral2021();
            this.tagsTribuElectoral2021.tagsSelected = retrievetagsTribuElectoral2021Selected(objContact);

            this.tagsSituacionAsalariado = new HashtagPicklist();
            this.tagsSituacionAsalariado.tags = retrievetagsSituacionAsalariado();
            this.tagsSituacionAsalariado.tagsSelected = retrievetagsSituacionAsalariadoSelected(objContact);       
            
            this.tagsAudienciaPolitica = new HashtagPicklist();
            this.tagsAudienciaPolitica.tags = retrievetagsAudienciaPolitica();
            this.tagsAudienciaPolitica.tagsSelected = retrievetagsAudienciaPoliticaSelected(objContact);       
            
            this.tagsAudienciaElectoral = new HashtagPicklist();
            this.tagsAudienciaElectoral.tags = retrievetagsAudienciaElectoral();
            this.tagsAudienciaElectoral.tagsSelected = retrievetagsAudienciaElectoralSelected(objContact);  
            
            this.tagsAudienciaGeneraciones = new HashtagPicklist();
            this.tagsAudienciaGeneraciones.tags = retrievetagsAudienciaGeneraciones();
            this.tagsAudienciaGeneraciones.tagsSelected = retrievetagsAudienciaGeneracionesSelected(objContact);  
            
            this.tagsActividadesEconomicas = new HashtagPicklist();
            this.tagsActividadesEconomicas.tags = retrievetagsActividadesEconomicas();
            this.tagsActividadesEconomicas.tagsSelected = retrievetagsActividadesEconomicasSelected(objContact); 
            
            this.tagsCDPCampaign = new HashtagPicklist();
            this.tagsCDPCampaign.tagsAvailable = retrieveCDPCampaingsTagsAvailable();
            this.tagsCDPCampaign.tagsAvailableSerialized  = JSON.serialize(this.tagsCDPCampaign.tagsAvailable);
            this.tagsCDPCampaign.tagsSelected = retrieveSelectedCDPCampaingsTags(objContact);
            this.tagsCDPCampaign.tags = retrieveCDPCampaingsTags();
            
            this.tagsCDPAxis = new HashtagPicklist();
            this.tagsCDPAxis.tagsAvailable = retrieveCDPAxisTagsAvailable();
            this.tagsCDPAxis.tagsAvailableSerialized  = JSON.serialize(this.tagsCDPAxis.tagsAvailable);
            this.tagsCDPAxis.tagsSelected = retrieveSelectedCDPAxisTags(objContact);
            this.tagsCDPAxis.tags = retrieveCDPAxisTags();
            
            this.tagsCDPStatus = new HashtagPicklist();
            this.tagsCDPStatus.tagsAvailable = retrieveCDPStatusTagsAvailable();
            this.tagsCDPStatus.tags = retrieveCDPStatusTags();
            this.tagsCDPStatus.tagsAvailableSerialized  = JSON.serialize(this.tagsCDPStatus.tagsAvailable);
            
            this.tagsCDPScore = new HashtagPicklist();
            this.tagsCDPScore.tagsAvailable = retrieveCDPScoreTagsAvailable();
            this.tagsCDPScore.tags = retrieveCDPScoreTags();
            this.tagsCDPScore.tagsAvailableSerialized  = JSON.serialize(this.tagsCDPScore.tagsAvailable);
        }        
        
        public void updatePicklistValue(String strPicklist, Boolean boolIsMultipicklist,String strValue) {
            RemotingMessageHelper.CustomSelectOptions objOption = null;
            
            System.debug('updatePicklistValue [strPicklist : ' + strPicklist + '- boolIsMultipicklist : ' + boolIsMultipicklist + ' - strValue : ' + strValue + ' ] ->');

            objOption = new RemotingMessageHelper.CustomSelectOptions(strValue, strValue);
            
            if(strPicklist == 'Community__c') {
                updatePicklistValueCommunity(strPicklist, boolIsMultipicklist, strValue, objOption);
            } else if(strPicklist == 'CDP_Campaign__c') {
                updatePicklistValueCDPCampaign(strPicklist, boolIsMultipicklist, strValue, objOption);
            } else if (strPicklist == 'CDP_Axis__c') {
                updatePicklistValueCDPAxis(strPicklist, boolIsMultipicklist, strValue, objOption);
            } else if (strPicklist == 'CDP_Status__c') {
                updatePicklistValueCDPStatus(strPicklist, boolIsMultipicklist, strValue, objOption);
                this.citizen.CDP_Status__c = strValue;
            } else if (strPicklist == 'CDP_Score__c') {
                updatePicklistValueCDPScore(strPicklist, boolIsMultipicklist, strValue, objOption);
                this.citizen.CDP_Score__c = strValue;
            }
        }
        
        private void updatePicklistValueCommunity(String strPicklist, Boolean boolIsMultipicklist, String strValue, RemotingMessageHelper.CustomSelectOptions objOption) {
            System.debug('updatePicklistValueCommunity [strPicklist : ' + strPicklist + '- boolIsMultipicklist : ' + boolIsMultipicklist + ' - strValue : ' + strValue + ' - objOption : ' + objOption + ' ] ->');

            if(!this.tagsCommunity.tagsAvailable.contains(strValue)) {                
                this.tagsCommunity.tagsAvailable.add(strValue);
                HelperFunctions.addValueToPickList('Contact', strPicklist, boolIsMultipicklist, strValue);   
            }
            
            if(!this.tagsCommunity.tagsSelected.contains(strValue)) {     
                System.debug('adding tag selected');
                this.tagsCommunity.tagsSelected.add(strValue);
            }
            
            this.tagsCommunity.tags.add(objOption); 
            
            System.debug('updatePicklistValueCommunity [] <-');
        }
        
        private void updatePicklistValueCDPCampaign(String strPicklist, Boolean boolIsMultipicklist, String strValue, RemotingMessageHelper.CustomSelectOptions objOption) {
            if(!this.tagsCDPCampaign.tagsAvailable.contains(strValue)) {                
                this.tagsCDPCampaign.tagsAvailable.add(strValue);
                HelperFunctions.addValueToPickList('Contact', strPicklist, boolIsMultipicklist, strValue);   
            }
            
            if(!this.tagsCDPCampaign.tagsSelected.contains(strValue)) {                
                this.tagsCDPCampaign.tagsSelected.add(strValue);
            }
            
            this.tagsCDPCampaign.tags.add(objOption); 
        }
        
        private void updatePicklistValueCDPAxis(String strPicklist, Boolean boolIsMultipicklist, String strValue, RemotingMessageHelper.CustomSelectOptions objOption) {
            if(!this.tagsCDPAxis.tagsAvailable.contains(strValue)) {                
                this.tagsCDPAxis.tagsAvailable.add(strValue);
                HelperFunctions.addValueToPickList('Contact', strPicklist, boolIsMultipicklist, strValue);   
            }
            
            if(!this.tagsCDPAxis.tagsSelected.contains(strValue)) {                
                this.tagsCDPAxis.tagsSelected.add(strValue);
            }
            
            this.tagsCDPAxis.tags.add(objOption); 
        }
        
        private void updatePicklistValueCDPStatus(String strPicklist, Boolean boolIsMultipicklist, String strValue, RemotingMessageHelper.CustomSelectOptions objOption) {
            if(!this.tagsCDPStatus.tagsAvailable.contains(strValue)) {                
                this.tagsCDPStatus.tagsAvailable.add(strValue);
                HelperFunctions.addValueToPickList('Contact', strPicklist, boolIsMultipicklist, strValue);   
            }
            
            this.tagsCDPStatus.tags.add(objOption); 
        }
        
        private void updatePicklistValueCDPScore(String strPicklist, Boolean boolIsMultipicklist, String strValue, RemotingMessageHelper.CustomSelectOptions objOption) {
            if(!this.tagsCDPScore.tagsAvailable.contains(strValue)) {                
                this.tagsCDPScore.tagsAvailable.add(strValue);
                HelperFunctions.addValueToPickList('Contact', strPicklist, boolIsMultipicklist, strValue);   
            }
            
            this.tagsCDPScore.tags.add(objOption); 
        }
        
        private List<String> retrieveHashtags(Contact objContact) {
            Set<String> setHashTags = null;
            Set<String> setFormattedHashTags = null;
            
            setHashTags = new Set<String>();
            
            if(this.communitySite == HelperFunctions.CommunitySite.SALESFORCE) {
                setHashTags.addAll(retrieveHashtagsProsumia(objContact));
            } else if (this.communitySite == HelperFunctions.CommunitySite.CUIDARNOS) {
                //setHashTags.addAll(retrieveHashtagsProsumia(objContact));
            }
            
            setFormattedHashTags = HelperFunctions.capitalizeList(setHashTags);
            setFormattedHashTags = HelperFunctions.trimList(setFormattedHashTags);

            return new List<String>(setFormattedHashTags);
        }
        
        private Set<String> retrieveHashtagsProsumia(Contact objContact) {
            Set<String> setHashTags = null;
            
            setHashTags = new Set<String>();
            
            if(objContact.Community__c != NULL && objContact.Community__c.length() > 0) {
                setHashTags.addAll(objContact.Community__c.split(';'));
            }   
            
            if(objContact.Audiencia_Politica__c != NULL && objContact.Audiencia_Politica__c.length() > 0) {
                setHashTags.addAll(objContact.Audiencia_Politica__c.split(';'));
            } 
            
            if(objContact.Audiencia_Electoral__c != NULL && objContact.Audiencia_Electoral__c.length() > 0) {
                setHashTags.addAll(objContact.Audiencia_Electoral__c.split(';'));
            } 
            
            if(objContact.Audiencia_Generaciones__c != NULL && objContact.Audiencia_Generaciones__c.length() > 0) {
                setHashTags.addAll(objContact.Audiencia_Generaciones__c.split(';'));
            } 
            
            if(objContact.Actividades_Economicas__c != NULL && objContact.Actividades_Economicas__c.length() > 0) {
                setHashTags.addAll(objContact.Actividades_Economicas__c.split(';'));
            } 

            if(objContact.Tendencia_Politica_CBA__c != NULL ) {
                setHashTags.add(objContact.Tendencia_Politica_CBA__c.toLowerCase());
            }
            
            if(objContact.Tendencia_Politica_STAFE__c != NULL ) {
                setHashTags.add('STAFE_' + objContact.Tendencia_Politica_STAFE__c.toLowerCase());
            } 
            
                   
            if(objContact.Situacion_del_Asalariado__c != NULL && objContact.Situacion_del_Asalariado__c.length() > 0) {
                setHashTags.addAll(objContact.Situacion_del_Asalariado__c.split(';'));
            } 

            if(objContact.delphos_tribe_2019__c != NULL && objContact.delphos_tribe_2019__c.length() > 0) {
                setHashTags.addAll(objContact.delphos_tribe_2019__c.split(';'));
            }
            
            return setHashTags;
        }
                
        private List<String> retrieveHashtagsEPDLG(Contact objContact) {
            Set<String> setHashTags = null;
            Set<String> setFormattedHashTags = null;

            setHashTags = new Set<String>();
            
            if(objContact.CDP_Campaign__c != NULL && objContact.CDP_Campaign__c.length() > 0) {
                setHashTags.addAll(objContact.CDP_Campaign__c.split(';'));
            }   
            
            if(objContact.CDP_Axis__c != NULL && objContact.CDP_Axis__c.length() > 0) {
                setHashTags.addAll(objContact.CDP_Axis__c.split(';'));
            } 

            if(objContact.CDP_Status__c != NULL ) {
                setHashTags.add(objContact.CDP_Status__c.toLowerCase());
            } 
            
            if(objContact.CDP_Score__c != NULL ) {
                setHashTags.add(objContact.CDP_Score__c.toLowerCase());
            } 
               
            setFormattedHashTags = HelperFunctions.capitalizeList(setHashTags);
            setFormattedHashTags = HelperFunctions.trimList(setFormattedHashTags);
            
            return new List<String> (setFormattedHashTags);
        }
        
        private List<String> retrieveSelectedCommunityTags(Contact objContact) {
            List<String> lstTags = null;
            
            lstTags = new List<String>();
            if(String.isNotBlank(objContact.Community__c)) {
                lstTags = objContact.Community__c.split(';');                                               
            }
                        
            return lstTags;
        }
        
        private List<RemotingMessageHelper.CustomSelectOptions> retrieveCommunityTags() {  
        	 List<RemotingMessageHelper.CustomSelectOptions> lstTags = null;
            
            lstTags = new List<RemotingMessageHelper.CustomSelectOptions>();
            if(this.tagsCommunity.tagsAvailable != NULL && this.tagsCommunity.tagsAvailable.size() > 0) {
                for(String strTag : this.tagsCommunity.tagsAvailable) {
                    lstTags.add(new RemotingMessageHelper.CustomSelectOptions(strTag, strTag));
                }
            }
                        
            return lstTags;
        }
        
        private List<String> retrieveCommunityTagsAvailable() { 
        	List<String> lstPicklistValues = null;
            List<Schema.PicklistEntry> lstPicklistEntry = null;
            
            lstPicklistValues = new List<String>();
            lstPicklistEntry = HelperFunctions.retrievePicklistValues('Contact','Community__c');
            
            for (Schema.PicklistEntry objPickListEntry :lstPicklistEntry) {
                lstPicklistValues.add(objPickListEntry.getValue());
            }
                            
            return lstPickListValues;
        }
                                
        private List<RemotingMessageHelper.CustomSelectOptions> retrieveTendenciaPoliticaCBA() {
            List<RemotingMessageHelper.CustomSelectOptions> lstResult = null;
            List<Schema.PicklistEntry> lstPicklistValues = null;
            
            lstPicklistValues = HelperFunctions.retrievePicklistValues('Contact','Tendencia_Politica_CBA__c');
            lstResult = HelperFunctions.buildPickListCustomOptions(lstPicklistValues);
            lstResult.add(0, new RemotingMessageHelper.CustomSelectOptions('','--- Seleccionar ---'));
                                    
            return lstResult;
        }
        
        private List<RemotingMessageHelper.CustomSelectOptions> retrieveTipoAsalariado() {
            List<RemotingMessageHelper.CustomSelectOptions> lstResult = null;
            List<Schema.PicklistEntry> lstPicklistValues = null;
            
            lstPicklistValues = HelperFunctions.retrievePicklistValues('Contact','Tipo_de_Asalariado__c');
            lstResult = HelperFunctions.buildPickListCustomOptions(lstPicklistValues);
            lstResult.add(0, new RemotingMessageHelper.CustomSelectOptions('','--- Seleccionar ---'));
                                    
            return lstResult;
        }
        
        private List<RemotingMessageHelper.CustomSelectOptions> retrieveDelphosTribe2019() {
            List<RemotingMessageHelper.CustomSelectOptions> lstResult = null;
            List<Schema.PicklistEntry> lstPicklistValues = null;
            
            lstPicklistValues = HelperFunctions.retrievePicklistValues('Contact','delphos_tribe_2019__c');
            lstResult = HelperFunctions.buildPickListCustomOptions(lstPicklistValues);
            lstResult.add(0, new RemotingMessageHelper.CustomSelectOptions('','--- Seleccionar ---'));
                                    
            return lstResult;
        }

        
        private List<RemotingMessageHelper.CustomSelectOptions> retrieveTribuElectoral2021() {
            List<RemotingMessageHelper.CustomSelectOptions> lstResult = null;
            List<Schema.PicklistEntry> lstPicklistValues = null;
            
            lstPicklistValues = HelperFunctions.retrievePicklistValues('Contact','tribu_electoral_2021__c');
            lstResult = HelperFunctions.buildPickListCustomOptions(lstPicklistValues);
                                    
            return lstResult;
        }

        private List<String> retrievetagsTribuElectoral2021Selected(Contact objContact) {
            List<String> lstResult = null;
            
            lstResult = new List<String>();
            if(objContact.tribu_electoral_2021__c != NULL && objContact.tribu_electoral_2021__c.length() > 0) {
                lstResult.addAll(objContact.tribu_electoral_2021__c.split(';'));
            } 
            
            return lstResult;
        }


        private List<RemotingMessageHelper.CustomSelectOptions> retrievetagsSituacionAsalariado() { 
            List<RemotingMessageHelper.CustomSelectOptions> lstResult = null;
            List<Schema.PicklistEntry> lstPicklistValues = null;
            
            lstPicklistValues = HelperFunctions.retrievePicklistValues('Contact','Situacion_del_Asalariado__c');
            lstResult = HelperFunctions.buildPickListCustomOptions(lstPicklistValues);
            //lstResult.add(0, new RemotingMessageHelper.CustomSelectOptions('','--- Seleccionar ---'));
                                    
            return lstResult;            
        }
        
        private List<String> retrievetagsSituacionAsalariadoSelected(Contact objContact) {
            List<String> lstResult = null;
            
            lstResult = new List<String>();
            if(objContact.Situacion_del_Asalariado__c != NULL && objContact.Situacion_del_Asalariado__c.length() > 0) {
                lstResult.addAll(objContact.Situacion_del_Asalariado__c.split(';'));
            } 
            
            return lstResult;
        }
        
        
        private List<RemotingMessageHelper.CustomSelectOptions> retrievetagsAudienciaPolitica() { 
            List<RemotingMessageHelper.CustomSelectOptions> lstResult = null;
            List<Schema.PicklistEntry> lstPicklistValues = null;
            
            lstPicklistValues = HelperFunctions.retrievePicklistValues('Contact','Audiencia_Politica__c');
            lstResult = HelperFunctions.buildPickListCustomOptions(lstPicklistValues);
            //lstResult.add(0, new SelectOption('','--- Seleccionar ---'));
                                    
            return lstResult;            
        }
        
        private List<String> retrievetagsAudienciaPoliticaSelected(Contact objContact) {
            List<String> lstResult = null;
            
            lstResult = new List<String>();
            if(objContact.Audiencia_Politica__c != NULL && objContact.Audiencia_Politica__c.length() > 0) {
                lstResult.addAll(objContact.Audiencia_Politica__c.split(';'));
            } 
            
            return lstResult;
        }
        
        private List<RemotingMessageHelper.CustomSelectOptions> retrievetagsAudienciaElectoral() { 
            List<RemotingMessageHelper.CustomSelectOptions> lstResult = null;
            List<Schema.PicklistEntry> lstPicklistValues = null;
            
            lstPicklistValues = HelperFunctions.retrievePicklistValues('Contact','Audiencia_Electoral__c');
            lstResult = HelperFunctions.buildPickListCustomOptions(lstPicklistValues);
            //lstResult.add(0, new RemotingMessageHelper.CustomSelectOptions('','--- Seleccionar ---'));
                                    
            return lstResult;            
        }
        
        private List<String> retrievetagsAudienciaElectoralSelected(Contact objContact) {
            List<String> lstResult = null;
            
            lstResult = new List<String>();
            if(objContact.Audiencia_Electoral__c != NULL && objContact.Audiencia_Electoral__c.length() > 0) {
                lstResult.addAll(objContact.Audiencia_Electoral__c.split(';'));
            } 
            
            return lstResult;
        }
        
        private List<RemotingMessageHelper.CustomSelectOptions> retrievetagsAudienciaGeneraciones() { 
            List<RemotingMessageHelper.CustomSelectOptions> lstResult = null;
            List<Schema.PicklistEntry> lstPicklistValues = null;
            
            lstPicklistValues = HelperFunctions.retrievePicklistValues('Contact','Audiencia_Generaciones__c');
            lstResult = HelperFunctions.buildPickListCustomOptions(lstPicklistValues);
            //lstResult.add(0, new RemotingMessageHelper.CustomSelectOptions('','--- Seleccionar ---'));
                                    
            return lstResult;            
        }
        
        private List<String> retrievetagsAudienciaGeneracionesSelected(Contact objContact) {
            List<String> lstResult = null;
            
            lstResult = new List<String>();
            if(objContact.Audiencia_Generaciones__c != NULL && objContact.Audiencia_Generaciones__c.length() > 0) {
                lstResult.addAll(objContact.Audiencia_Generaciones__c.split(';'));
            } 
            
            return lstResult;
        }
        
        private List<RemotingMessageHelper.CustomSelectOptions> retrievetagsActividadesEconomicas() { 
            List<RemotingMessageHelper.CustomSelectOptions> lstResult = null;
            List<Schema.PicklistEntry> lstPicklistValues = null;
            
            lstPicklistValues = HelperFunctions.retrievePicklistValues('Contact','actividades_economicas__c');
            lstResult = HelperFunctions.buildPickListCustomOptions(lstPicklistValues);
            //lstResult.add(0, new RemotingMessageHelper.CustomSelectOptions('','--- Seleccionar ---'));
                                    
            return lstResult;            
        }
        
        private List<String> retrievetagsActividadesEconomicasSelected(Contact objContact) {
            List<String> lstResult = null;
            
            lstResult = new List<String>();
            if(objContact.actividades_economicas__c != NULL && objContact.actividades_economicas__c.length() > 0) {
                lstResult.addAll(objContact.actividades_economicas__c.split(';'));
            } 
            
            return lstResult;
        }
                        
        private List<String> retrieveSelectedCDPCampaingsTags(Contact objContact) {
            List<String> lstTags = null;
            
            lstTags = new List<String>();
            if(String.isNotBlank(objContact.CDP_Campaign__c)) {
                lstTags = objContact.CDP_Campaign__c.split(';');                                               
            }
                        
            return lstTags;
        }
        
        private List<RemotingMessageHelper.CustomSelectOptions> retrieveCDPCampaingsTags() {  
        	 List<RemotingMessageHelper.CustomSelectOptions> lstTags = null;
            
            lstTags = new List<RemotingMessageHelper.CustomSelectOptions>();
            if(this.tagsCDPCampaign.tagsAvailable != NULL && this.tagsCDPCampaign.tagsAvailable.size() > 0) {
                for(String strTag : this.tagsCDPCampaign.tagsAvailable) {
                    lstTags.add(new RemotingMessageHelper.CustomSelectOptions(strTag, strTag));
                }
            } 
                        
            return lstTags;
        }
        
        private List<String> retrieveCDPCampaingsTagsAvailable() { 
        	List<String> lstPicklistValues = null;
            List<Schema.PicklistEntry> lstPicklistEntry = null;
            
            lstPicklistValues = new List<String>();
            lstPicklistEntry = HelperFunctions.retrievePicklistValues('Contact','CDP_Campaign__c');
            
            for (Schema.PicklistEntry objPickListEntry :lstPicklistEntry) {
                lstPicklistValues.add(objPickListEntry.getValue());
            }
                            
            return lstPickListValues;
        }
                                         
        private List<String> retrieveSelectedCDPAxisTags(Contact objContact) {
            List<String> lstTags = null;
            
            lstTags = new List<String>();
            if(String.isNotBlank(objContact.CDP_Axis__c)) {
                lstTags = objContact.CDP_Axis__c.split(';');                                               
            }
                        
            return lstTags;
        }
        
        private List<RemotingMessageHelper.CustomSelectOptions> retrieveCDPAxisTags() {  
        	 List<RemotingMessageHelper.CustomSelectOptions> lstTags = null;
            
            lstTags = new List<RemotingMessageHelper.CustomSelectOptions>();
            if(this.tagsCDPAxis.tagsAvailable != NULL && this.tagsCDPAxis.tagsAvailable.size() > 0) {
                for(String strTag : this.tagsCDPAxis.tagsAvailable) {
                    lstTags.add(new RemotingMessageHelper.CustomSelectOptions(strTag, strTag));
                }
            }
                        
            return lstTags;
        }
        
        private List<String> retrieveCDPAxisTagsAvailable() { 
        	List<String> lstPicklistValues = null;
            List<Schema.PicklistEntry> lstPicklistEntry = null;
            
            lstPicklistValues = new List<String>();
            lstPicklistEntry = HelperFunctions.retrievePicklistValues('Contact','CDP_Axis__c');
            
            for (Schema.PicklistEntry objPickListEntry :lstPicklistEntry) {
                lstPicklistValues.add(objPickListEntry.getValue());
            }
                            
            return lstPickListValues;
        }
        
        
        private List<RemotingMessageHelper.CustomSelectOptions> retrieveCDPStatusTags() {  
        	 List<RemotingMessageHelper.CustomSelectOptions> lstTags = null;
            
            lstTags = new List<RemotingMessageHelper.CustomSelectOptions>();
            if(this.tagsCDPStatus.tagsAvailable != NULL && this.tagsCDPStatus.tagsAvailable.size() > 0) {
                for(String strTag : this.tagsCDPStatus.tagsAvailable) {
                    lstTags.add(new RemotingMessageHelper.CustomSelectOptions(strTag, strTag));
                }
            }
                        
            return lstTags;
        }
        
        private List<String> retrieveCDPStatusTagsAvailable() { 
        	List<String> lstPicklistValues = null;
            List<Schema.PicklistEntry> lstPicklistEntry = null;
            
            lstPicklistValues = new List<String>();
            lstPicklistEntry = HelperFunctions.retrievePicklistValues('Contact','CDP_Status__c');
            
            for (Schema.PicklistEntry objPickListEntry :lstPicklistEntry) {
                lstPicklistValues.add(objPickListEntry.getValue());
            }
                            
            return lstPickListValues;
        }
                      
        private List<RemotingMessageHelper.CustomSelectOptions> retrieveCDPScoreTags() {  
        	 List<RemotingMessageHelper.CustomSelectOptions> lstTags = null;
            
            lstTags = new List<RemotingMessageHelper.CustomSelectOptions>();
            if(this.tagsCDPScore.tagsAvailable != NULL && this.tagsCDPScore.tagsAvailable.size() > 0) {
                for(String strTag : this.tagsCDPScore.tagsAvailable) {
                    lstTags.add(new RemotingMessageHelper.CustomSelectOptions(strTag, strTag));
                }
            }
                        
            return lstTags;
        }
        
        private List<String> retrieveCDPScoreTagsAvailable() { 
        	List<String> lstPicklistValues = null;
            List<Schema.PicklistEntry> lstPicklistEntry = null;
            
            lstPicklistValues = new List<String>();
            lstPicklistEntry = HelperFunctions.retrievePicklistValues('Contact','CDP_Score__c');
            
            for (Schema.PicklistEntry objPickListEntry :lstPicklistEntry) {
                lstPicklistValues.add(objPickListEntry.getValue());
            }
                            
            return lstPickListValues;
        }
    }
      
    public class HashtagPicklist {
        @AuraEnabled
        public List<RemotingMessageHelper.CustomSelectOptions> 	tags { get; set; }
        @AuraEnabled
        public List<String> 		tagsSelected { get; set; } //multipicklist
        @AuraEnabled
        public String 				tagSelected { get; set; } //single picklist
        @AuraEnabled
        public List<String> 		tagsAvailable { get; set; }        
        @AuraEnabled
        public String 				tagsAvailableSerialized { get; set; }
    }
    
    public class Observaciones { 
        @AuraEnabled
        public String Usuario { get; set; }
        @AuraEnabled
        public String Fecha { get; set; }
        @AuraEnabled
        public String Observacion { get; set; }

        public Observaciones(Covid_Observacion__c objObservacion) {
            this.Usuario = objObservacion.CreatedBy.Name;
            this.Fecha = objObservacion.CreatedDate.format('dd/MM/yyyy, kk:mm:ss');
            this.Observacion = objObservacion.Observaciones__c;
        }

    }

    public class Cuidarnos {
        private HelperFunctions.CommunitySite communitySite { get; set; }

        @AuraEnabled
        public String DateEntrySPFormat { get; set; }
        @AuraEnabled
        public String DateExitSPFormat { get; set; }
        @AuraEnabled
        public String HospitalDataSPFormat { get; set; }
        @AuraEnabled
        public String DateTemperatureSPFormat { get; set; }
        @AuraEnabled
        public String confirmdate { get; set; }

        @AuraEnabled
        public String Temperatura { get; set; }
        @AuraEnabled
        public Covid19__c covid { get; set; }

        @AuraEnabled
        public List<String> sintomas { get; set; }   
        
        @AuraEnabled
        public List<String> reactiva_sintomas { get; set; }  

        @AuraEnabled
        public List<String> situacion { get; set; }   

        @AuraEnabled
        public Boolean mark_enabled { get; set; }  
        @AuraEnabled
        public Boolean confirm_enabled { get; set; }  
        @AuraEnabled
        public Boolean isconfirmado { get; set; }  
        @AuraEnabled
        public Boolean issospechoso { get; set; }  
        
        @AuraEnabled
        public String etiquetaurl { get; set; }  
        @AuraEnabled
        public String etiquetaurl_reprint { get; set; }  
        @AuraEnabled
        public String pdf_url { get; set; }  
        @AuraEnabled
        public String alta_url { get; set; }  
        @AuraEnabled
        public String notification_url { get; set; }  

        @AuraEnabled
        public String proactiva_history { get; set; }  
        @AuraEnabled
        public List<String> proactiva_contacttype { get; set; }  
        @AuraEnabled 
        public String proactiva_frecuency { get; set; }  
        @AuraEnabled
        public String proactiva_needs { get; set; }  
        @AuraEnabled 
        public List<String> proactiva_sintomas { get; set; }  
        @AuraEnabled 
        public List<Observaciones> observaciones { get; set; }  

        @AuraEnabled 
        public String email { get; set; }  
        @AuraEnabled 
        public String mobile_phone { get; set; }  
        @AuraEnabled 
        public String phone { get; set; }  

        @AuraEnabled 
        public String Triage { get; set; }  
        @AuraEnabled 
        public String Telemedico { get; set; }  
        @AuraEnabled 
        public String Muestra { get; set; }  
        @AuraEnabled 
        public String Resultado { get; set; }  
        @AuraEnabled 
        public String Notificacion { get; set; }  
        @AuraEnabled 
        public String Archivado { get; set; }  
        @AuraEnabled 
        public String TestSerologico { get; set; }  
        @AuraEnabled 
        public String TurnoHisopado { get; set; }  

        @AuraEnabled 
        public String status { get; set; }  
     
        @AuraEnabled 
        public String turnos_url { get; set; } 

        @AuraEnabled 
        public Boolean usuario_pilar  { get; set; }  
     
        @AuraEnabled
        public String defaultLab { get; set; }

        @AuraEnabled 
        public Boolean hasOOSS  { get; set; }  

		@AuraEnabled 
        public List<String> tipoEstudio { get; set; }  
     
        @AuraEnabled
        public String linkTriage { get; set; }

        public Cuidarnos(HelperFunctions.CommunitySite objCommunitySite, Contact objContact) {
            List<String> lstFrecuency = null;
            String strDomain = null;
            User objLoggedUserInfo = [SELECT Laboratorio_Codigo__c,Triage_Parameters__c FROM User WHERE ID =: UserInfo.getUserId()];
            this.communitySite = objCommunitySite;
            this.DateExitSPFormat = (objContact.mig_exit_date__c != NULL)?objContact.mig_exit_date__c.format():'';
            this.DateEntrySPFormat = (objContact.mig_entry_date__c != NULL)?objContact.mig_entry_date__c.format():'';
            this.observaciones = new List<Observaciones>();  

            this.covid = retrieveCovidInfo(objContact);
            
            this.confirmdate = (this.covid.Cuidarnos_Comunidad_Date__c != NULL)?'(' + this.covid.Cuidarnos_Comunidad_Date__c.format() + ')':'';
            this.status = String.isNotBlank(this.covid.Cuidarnos_Status__c)?this.covid.Cuidarnos_Status__c:'';
            this.status = this.covid.Cuidarnos_Comunidad_Status__c;
            

            this.hasOOSS = String.isNotBlank(objContact.health_insurance__c);
            //this.DateTemperatureSPFormat = (this.covid.proactiva_date__c != NULL)?this.covid.proactiva_date__c.format():'';
            this.Temperatura = (this.covid.proactiva_temperature__c != NULL)?String.valueOf(this.covid.proactiva_temperature__c) + ' ℃' : '';
            this.sintomas = retrieveSintomas(objContact); 
            this.reactiva_sintomas = retrieveReactivaSintomas();
            this.situacion = retrieveSituation(objContact); 

            lstFrecuency = convertToList(this.covid.proactiva_frecuency__c); 
            this.proactiva_history = ( String.isNotBlank(this.covid.proactiva_history__c))?String.join(this.covid.proactiva_history__c.split(';'), ' ,'):''; 
            this.proactiva_contacttype = convertToList(this.covid.proactiva_contacttype__c); 
            this.proactiva_frecuency = (lstFrecuency != NULL && lstFrecuency.size() > 0)?lstFrecuency[0]:''; 
            this.proactiva_needs = ( String.isNotBlank(this.covid.proactiva_needs__c))?this.covid.proactiva_needs__c.split(';')[0]:''; 
            this.proactiva_sintomas = convertToList(this.covid.proactiva_symptoms__c); 
                
            this.isconfirmado = (this.covid != NULL && this.covid.Cuidarnos_Comunidad_Status__c == 'Confirmado' || this.covid.Cuidarnos_Comunidad_Status__c == 'Recuperado');            
            this.issospechoso = (this.covid != NULL && this.covid.Cuidarnos_Comunidad_Status__c == 'Sospechoso');            

            this.mark_enabled = !this.covid.Cuidarnos_Marked__c && !this.issospechoso && !this.isconfirmado;  
            this.confirm_enabled = ( this.covid.Cuidarnos_Marked__c || this.issospechoso ) && !this.isconfirmado;  

            this.email = String.isNotBlank(this.covid.Email__c)?this.covid.Email__c:objContact.Email;  
            this.mobile_phone = String.isNotBlank(this.covid.Mobile_Phone__c)?this.covid.Mobile_Phone__c:objContact.MobilePhone;  
            this.phone = String.isNotBlank(this.covid.Phone__c)?this.covid.Phone__c:objContact.HomePhone;  
            
            this.turnos_url = String.format('https://appointments.clients.debmedia.com/#/company/MunicipalidadDePilar/schedules?customer.firstName={0}&customer.lastName={1}&customer.dni={2}&customer.phone={3}&customer.email={4}', new String[] { objContact.FirstName, objContact.LastName, objContact.Document_Number__c, this.mobile_phone, (String.IsNotBlank(this.email))?EncodingUtil.urlEncode(this.email, 'UTF-8'):'' }); 
            this.usuario_pilar =  esDePilar(); 
            //https://{{salesforcedomain}}pilar
            strDomain = ([SELECT Id, IsSandbox  FROM Organization].IsSandbox)?'dev-prosumiacrm.cs79.force.com/cdn':'prosumiacrm.secure.force.com/cdn';
            if(this.usuario_pilar) {
                this.etiquetaurl = 'https://etiquetas.cuidarnos.com/?dni=' + String.valueOf(objContact.Document_Number__c);
                this.etiquetaurl_reprint = 'https://etiquetas.cuidarnos.com/?dni=' + String.valueOf(objContact.Document_Number__c) + '&new=0';

                this.pdf_url = String.format('https://{0}/services/apexrest/cuidarnos/rest/pdf/{1}/notificacion/pilar', new String[] { strDomain,objContact.Id });
                this.alta_url = String.format('https://{0}/services/apexrest/cuidarnos/rest/pdf/{1}/alta/pilar', new String[] { strDomain,objContact.Id });
        
                this.notification_url = String.format('https://{0}/services/apexrest/cuidarnos/rest/pdf/{1}/notificacion/pilar', new String[] { strDomain,objContact.Id });
            } else {
                this.etiquetaurl = 'https://etiquetas.cuidarnos.com/?dni=' + String.valueOf(objContact.Document_Number__c) + '&gen=1';
                this.etiquetaurl_reprint = 'https://etiquetas.cuidarnos.com/?dni=' + String.valueOf(objContact.Document_Number__c) + '&gen=1';

                this.pdf_url = String.format('https://{0}/services/apexrest/cuidarnos/rest/pdf/{1}/notificacion/cuidarnos', new String[] { strDomain,objContact.Id });
                this.alta_url = String.format('https://{0}/services/apexrest/cuidarnos/rest/pdf/{1}/alta/cuidarnos', new String[] { strDomain,objContact.Id });
                this.notification_url = String.format('https://{0}/services/apexrest/cuidarnos/rest/pdf/{1}/notificacion/cuidarnos', new String[] {strDomain, objContact.Id });
            }

            this.Triage = (this.covid.proactiva_date__c != NULL)?this.covid.proactiva_date__c.format('dd/MM/yyyy kk:mm:ss'):'';
            this.Telemedico = (this.covid.Telemedico_Date__c != NULL)?this.covid.Telemedico_Date__c.format('dd/MM/yyyy kk:mm:ss'):'';
            this.Muestra = (this.covid.label_date__c != NULL)?this.covid.label_date__c.format('dd/MM/yyyy kk:mm:ss'):'';
            this.Resultado = (this.covid.Cuidarnos_Muestra_Result_Date__c != NULL)?this.covid.Cuidarnos_Muestra_Result_Date__c.format('dd/MM/yyyy kk:mm:ss'):'';
            this.Notificacion = (this.covid.Notificacion_Date__c != NULL)?this.covid.Notificacion_Date__c.format('dd/MM/yyyy kk:mm:ss'):'';
            this.Archivado = (this.covid.Archive_Date__c != NULL)?this.covid.Archive_Date__c.format('dd/MM/yyyy kk:mm:ss'):'';            
            this.TestSerologico = (this.covid.testserologico_fecha__c != NULL)?this.covid.testserologico_fecha__c.format('dd/MM/yyyy kk:mm:ss'):'';            
            this.TurnoHisopado = (this.covid.turno_hisopado__c != NULL)?  ((Datetime) this.covid.turno_hisopado__c).format('dd/MM/yyyy'):'';            
            
            this.defaultLab = objLoggedUserInfo.Laboratorio_Codigo__c;
            this.defaultLab = String.isBlank(this.defaultLab)?'':this.defaultLab;
            
            this.linkTriage = retrieveLinkTriage(objContact, objLoggedUserInfo);
            
            this.tipoEstudio = new List<String>();
			if (FeatureManagement.checkPermission('Cuidarnos_Test_Type_Antigeno')) {
				this.tipoEstudio.add('Antigeno');
            } 
            if(FeatureManagement.checkPermission('Cuidarnos_Test_Type_PCR')) {
				this.tipoEstudio.add('PCR');
			}
 
            //this.mark_enabled = !objContact.Cuidarnos_Citizen_Marked__c && ( this.covid == NULL || (this.covid.Cuidarnos_Comunidad_Status__c <> 'Confirmado' || this.covid.Cuidarnos_Comunidad_Status__c <> 'Recuperado') );  
            //this.confirm_enabled = objContact.Cuidarnos_Citizen_Marked__c && ( this.covid == NULL || (this.covid.Cuidarnos_Comunidad_Status__c <> 'Confirmado' || this.covid.Cuidarnos_Comunidad_Status__c <> 'Recuperado') );  
        }

        private String retrieveLinkTriage(Contact objContact, User objUser) {
            String strLinkTriage = null;
            User objUserInfo = null;

            System.debug('retrieveLinkTriage [objContact : ' + objContact + ' - objUser : ' + objUser + '] ->');

            if(this.usuario_pilar) {
                if(String.IsNotBlank(objUser.Triage_Parameters__c)) {
                    strLinkTriage = 'https://covid.pilar.gov.ar/?' + objUser.Triage_Parameters__c +'&guid=' + objContact.guid__c;
                } else {
                    strLinkTriage = 'https://covid.pilar.gov.ar/?guid=' + objContact.guid__c;
                }
            } else {
                strLinkTriage = 'https://cuidarnos.app/?g=' + objContact.guid__c;
            }

            System.debug('retrieveLinkTriage [' + strLinkTriage + '] <-');

            return strLinkTriage;
        }

        private void loadCustomPermissions() {
            
        }
        private List<String> converttoList(String strList) {
            List<String> setHashTags = null;
            
            setHashTags = new List<String>();
            
            if(String.isNotBlank(strList)) {
                setHashTags.addAll(strList.split(';'));
            }   
                                    
            return setHashTags;
        }

        private List<String> retrieveSintomas(Contact objContact) {
            List<String> setHashTags = null;
            
            setHashTags = new List<String>();
            
            if(this.covid.proactiva_symptoms__c != NULL && this.covid.proactiva_symptoms__c.length() > 0) {
                setHashTags.addAll(this.covid.proactiva_symptoms__c.split(';'));
            }   
                                    
            return setHashTags;
        }

        private List<String> retrieveReactivaSintomas() {
            List<String> setHashTags = null;
            
            setHashTags = new List<String>();
            
            if(this.covid.salud_symptom__c != NULL && this.covid.salud_symptom__c.length() > 0) {
                setHashTags.addAll(this.covid.salud_symptom__c.split(';'));
            }   
                                    
            return setHashTags;
        }
 
        private List<String> retrieveSituation(Contact objContact) {
            List<String> setHashTags = null;
            
            setHashTags = new List<String>();
         
            if(this.covid.proactiva_history__c != NULL && this.covid.proactiva_history__c.length() > 0) {
                setHashTags.addAll(this.covid.proactiva_history__c.split(';'));
            }

            if(this.covid.proactiva_symptoms__c != NULL && this.covid.proactiva_symptoms__c.length() > 0) {
                setHashTags.addAll(this.covid.proactiva_symptoms__c.split(';'));
            }
            
            return setHashTags;
        }

        private Covid19__c retrieveCovidInfo(Contact objContact) {
            List<Covid19__c> lstCovid19Info = null;
            Covid19__c objCovidData = null;

            lstCovid19Info = [ SELECT   Cuidarnos_Muestra_Result_Date__c, 
                                        Cuidarnos_Muestra_Result__c,
                                        Administrative_Level_1__c, 
                                        Administrative_Level_2__c, 
                                        Administrative_Level_3__c, 
                                        Administrative_Level_4__c, 
                                        testserologico_fecha__c,
                                        testserologico__c,
                                        testserologico_IGG__c,
                                        testserologico_IGG_resultado__c,
                                        testserologico_IGM__c,
                                        testserologico_IGM_resultado__c,
                                        testserologico_lugar__c,
                                        Tipo_de_Test__c,
                                        Citizen__c, 
                                        CreatedById, 
                                        CreatedDate, 
                                        Cuidarnos_Autoevaluado__c, 
                                        Cuidarnos_Resultado_Etiqueta__c,
                                        Cuidarnos_Comunidad_Date__c, 
                                        Cuidarnos_Comunidad_Level1__c, 
                                        Cuidarnos_Comunidad_Level2__c, 
                                        Cuidarnos_Comunidad_Status__c, 
                                        Cuidarnos_Hash_Etiqueta__c,
                                        Cuidarnos_Muestra_Laboratorio__c,
                                        Cuidarnos_Date__c, 
                                        Cuidarnos_Level1__c, 
                                        Cuidarnos_Level2__c, 
                                        Cuidarnos_Marked__c, 
                                        Cuidarnos_Observation__c, 
                                        Cuidarnos_Sent__c, 
                                        Cuidarnos_Status__c, 
                                        Document_Number__c, 
                                        centro_hisopado__c,
                                        turno_hisopado__c,
                                        Estado_Epidemiologico__c,
                                        Edad__c, 
                                        Email__c, 
                                        FirstName__c, 
                                        FullName__c, 
                                        Id,  
                                        LastName__c, 
                                        MiddleName__c, 
                                        Mobile_Phone__c, 
                                        Phone__c,
                                        Name, 
                                        Name_with_Link__c, 
                                        Notificacion_Date__c,  
                                        Telemedico_Date__c, 
                                        appointment_date__c, 
                                        guid__c, 
                                        label_date__c, 
                                        label_place__c, 
                                        proactiva_autoperception__c, 
                                        proactiva_contacttype__c, 
                                        proactiva_date__c, 
                                        proactiva_frecuency__c, 
                                        proactiva_hasbeencontact__c, 
                                        proactiva_hashistory__c, 
                                        proactiva_hassymptoms__c, 
                                        proactiva_health__c, 
                                        proactiva_history__c, 
                                        proactiva_needs__c, 
                                        proactiva_resultgroup__c, 
                                        proactiva_results__c, 
                                        proactiva_risk__c, 
                                        proactiva_source__c, 
                                        proactiva_symptoms__c, 
                                        proactiva_temperature__c, 
                                        proactiva_traveler__c, 
                                        Archive_Date__c,
                                        Riesgo__c,
                                        salud__c, 
                                        salud_date__c, 
                                        salud_level1__c, 
                                        salud_level2__c, 
                                        salud_link__c, 
                                        salud_status__c, 
                                        salud_symptom__c, 
                                        salud_test__c, salud_treatment__c, salud_treatmenttype__c, 
                                        test_result__c, test_result_date__c, test_results_place__c, test_results_testtype__c,
                                        (SELECT Id, Name, Observaciones__c, CreatedBy.Name, CreatedDate FROM Covid_Observacion__r ORDER BY CreatedDate DESC)
                              FROM Covid19__c
                              WHERE Citizen__c =: objContact.Id];
            
            System.debug('retrieveCovidInfo [lstCovid19Info : ' + lstCovid19Info + ']');
            if(!lstCovid19Info.isEmpty()) {
                objCovidData = lstCovid19Info[0];

                if(objCovidData.Covid_Observacion__r != NULL) {
                    for(Covid_Observacion__c objObservacion : objCovidData.Covid_Observacion__r) {
                        this.observaciones.add(new Observaciones(objObservacion));
                    }
                }
            }


            System.debug('retrieveCovidInfo [' + objCovidData + '] <-');
            return objCovidData;
        }

        private Boolean esDePilar(){ 
            List<GroupMember> lstUserGroup = null;
            Boolean boolResult = false;

            System.debug('esDePilar [] ->');
    
            lstUserGroup = [SELECT Id, Group.DeveloperName, UserOrGroupId, SystemModstamp 
                            FROM GroupMember 
                            WHERE  UserOrGroupId = :UserInfo.getUserId()];
    
            for(GroupMember objGroupMember : lstUserGroup) {
                if(objGroupMember.Group.DeveloperName == 'Cuidarnos_Pilar' || objGroupMember.Group.DeveloperName.toLowerCase().indexOf('pilar') >= 0) {
                    boolResult = true; 
                    break;
                }
            }
    
            System.debug('esDePilar [' + boolResult + '] <-');
            return boolResult;
        }
    }


    public class Pilar360 {
        private HelperFunctions.CommunitySite communitySite { get; set; }

        @AuraEnabled
        public Pilar360__c pilar360 { get; set; }  

        @AuraEnabled 
        public String email { get; set; }  
        @AuraEnabled 
        public String mobile_phone { get; set; }  
        @AuraEnabled 
        public String phone { get; set; }  

        @AuraEnabled 
        public Boolean isPilar360  { get; set; }  
    
        public Pilar360(HelperFunctions.CommunitySite objCommunitySite, Contact objContact) {
            String strDomain = null;
            this.communitySite = objCommunitySite;

            this.pilar360 = retrieveInfo(objContact);
            
            this.isPilar360 = this.pilar360.pilar_360_Ciudadano360__c;            

            this.email = String.isNotBlank(this.pilar360.Email__c)?this.pilar360.Email__c:objContact.Email;  
            this.mobile_phone = String.isNotBlank(this.pilar360.Mobile_Phone__c)?this.pilar360.Mobile_Phone__c:objContact.MobilePhone;  
            this.phone = String.isNotBlank(this.pilar360.Phone__c)?this.pilar360.Phone__c:objContact.HomePhone;  
            
        }

        private List<String> converttoList(String strList) {
            List<String> setHashTags = null;
            
            setHashTags = new List<String>();
            
            if(String.isNotBlank(strList)) {
                setHashTags.addAll(strList.split(';'));
            }   
                                    
            return setHashTags;
        }

        private Pilar360__c retrieveInfo(Contact objContact) {
            List<Pilar360__c> lstInfo = null;
            Pilar360__c objData = null;

            lstInfo = [ SELECT Administrative_Level_1__c, Administrative_Level_2__c, Administrative_Level_3__c, Administrative_Level_4__c, Citizen__c, Edad__c, Email__c, FirstName__c, FullName__c, LastName__c, MiddleName__c, Mobile_Phone__c, Phone__c, guid__c, pilar_360_Ciudadano360__c, pilar_360_date__c, Id, Name 
                        FROM Pilar360__c
                        WHERE Citizen__c =: objContact.Id];
            
            System.debug('retrieveCovidInfo [lstInfo : ' + lstInfo + ']');
            if(!lstInfo.isEmpty()) {
                objData = lstInfo[0];
            }


            System.debug('retrieveCovidInfo [' + objData + '] <-');
            return objData;
        }       
    }

    public class Misiones {
        private HelperFunctions.CommunitySite communitySite { get; set; }

        @AuraEnabled
        public Misiones__c misiones { get; set; }  

        @AuraEnabled 
        public String Chacra { get; set; }
        
        @AuraEnabled 
        public String HomePhone { get; set; }
        
        @AuraEnabled 
        public String MobilePhone { get; set; }
        
        @AuraEnabled 
        public String Email { get; set; }
        
        @AuraEnabled 
        public String Cuil { get; set; }
        
        @AuraEnabled 
        public String Document { get; set; }
        
        @AuraEnabled 
        public List<String> Gov_Misiones { get; set; }
        
        @AuraEnabled 
        public List<String> Interest_Misiones { get; set; }

        @AuraEnabled 
        public List<String> Social_Benefit_Misiones { get; set; }
        
        @AuraEnabled 
        public String Email_Alternative_List { get; set; }

        @AuraEnabled 
        public String Mobile_Alternative_List { get; set; }
        
        @AuraEnabled 
        public String Estado_COVID_Misiones { get; set; }

        public Misiones(HelperFunctions.CommunitySite objCommunitySite, Contact objContact) {
            String strDomain = null;
            this.communitySite = objCommunitySite;

            this.misiones = retrieveInfo(objContact);
            
            //this.Chacra = this.misiones.Chacra__c;
            //this.HomePhone = this.misiones.HomePhone__c;
            this.MobilePhone = this.misiones.MobilePhone__c;
            this.Email = this.misiones.Email__c;
            this.Cuil = this.misiones.Cuil_Number__c;
            this.Document = this.misiones.Document_Number__c;
            this.Gov_Misiones = this.misiones.Gov_Misiones__c != null ? this.misiones.Gov_Misiones__c.split(';') : new List<String>();
            this.Interest_Misiones = this.misiones.Interest_Misiones__c != null ? this.misiones.Interest_Misiones__c.split(';')  : new List<String>();
            this.Social_Benefit_Misiones = this.misiones.Social_Benefit_Misiones__c != null ? this.misiones.Social_Benefit_Misiones__c.split(';')  : new List<String>();
            this.Email_Alternative_List = this.misiones.Email_Alternative_List__c;
            this.Mobile_Alternative_List = this.misiones.Mobile_Alternative_List__c;
            this.Estado_COVID_Misiones = this.misiones.Estado_COVID_Misiones__c;
            
        }

        private List<String> converttoList(String strList) {
            List<String> setHashTags = null;
            
            setHashTags = new List<String>();
            
            if(String.isNotBlank(strList)) {
                setHashTags.addAll(strList.split(';'));
            }   
                                    
            return setHashTags;
        }

        private Misiones__c retrieveInfo(Contact objContact) {
            List<Misiones__c> lstInfo = null;
            Misiones__c objData = null;

            lstInfo = [ SELECT Id, Name,
                       		MobilePhone__c, Email__c,
                            Cuil_Number__c, Document_Number__c, Email_Alternative_List__c,
                            Gov_Misiones__c, Interest_Misiones__c, Mobile_Alternative_List__c,
                            Social_Benefit_Misiones__c, Estado_COVID_Misiones__C  
                        FROM Misiones__c
                        WHERE Citizen__c =: objContact.Id];
            
            System.debug('retrieveCovidInfo [lstInfo : ' + lstInfo + ']');
            if(!lstInfo.isEmpty()) {
                objData = lstInfo[0];
            }


            System.debug('retrieveCovidInfo [' + objData + '] <-');
            return objData;
        }       
    }


    public class ComunidadRadicales {
        private HelperFunctions.CommunitySite communitySite { get; set; }

        @AuraEnabled
        public ComunidadRadicales__c comunidadRadicales { get; set; }  

        @AuraEnabled 
        public String Vota_a { get; set; }

        @AuraEnabled
        public List<String> Candidatos { get; set; }


        public ComunidadRadicales(HelperFunctions.CommunitySite objCommunitySite, Contact objContact) {
            String strDomain = null;
            this.communitySite = objCommunitySite;
            this.comunidadRadicales = retrieveInfo(objContact);
            this.Vota_a = this.comunidadRadicales.Vota_a__c;
            this.Candidatos = HelperFunctions.retrievePicklistValuesToStringList('ComunidadRadicales__c', 'Vota_a__c');

            // System.debug('ComunidadRadicales [strSObject : ' + 'ComunidadRadicales__c' + ' - strField : ' + 'Vota_a__c' + '] ->');
            // List<Schema.PicklistEntry> lstValues = HelperFunctions.retrievePicklistValues('ComunidadRadicales__c', 'Vota_a__c');
            // if(!lstValues.isEmpty()) {
            //     for(Schema.PicklistEntry objOption : lstValues) {
            //         this.Candidatos.add(objOption.getValue());
            //     }
            // }
            // System.debug('ComunidadRadicales [' + this.Candidatos + '] <-');

        }

        private List<String> converttoList(String strList) {
            List<String> setHashTags = null;
            
            setHashTags = new List<String>();
            
            if(String.isNotBlank(strList)) {
                setHashTags.addAll(strList.split(';'));
            }   
                                    
            return setHashTags;
        }

        private ComunidadRadicales__c retrieveInfo(Contact objContact) {
            List<ComunidadRadicales__c> lstInfo = null;
            ComunidadRadicales__c objData = null;

            lstInfo = [ SELECT Id, Name, Vota_a__c
                        FROM ComunidadRadicales__c
                        WHERE Citizen__c =: objContact.Id];
            
            System.debug('retrieveCovidInfo [lstInfo : ' + lstInfo + ']');
            if(!lstInfo.isEmpty()) {
                objData = lstInfo[0];
            }

            System.debug('retrieveCovidInfo [' + objData + '] <-');
            return objData;
        }       
    }

    public class DatosSalud {

        private HelperFunctions.CommunitySite communitySite { get; set; }

        @AuraEnabled
        public String comorbilidades {get; set;}

        @AuraEnabled
        public String obraSocial {get; set;}

        @AuraEnabled
        public Boolean tuvoCovid {get; set;}

        @AuraEnabled
        public List<Vacuna> vacunas {get; set;}

        public DatosSalud (HelperFunctions.CommunitySite objCommunitySite, Contact objContact) {
            this.communitySite = objCommunitySite;
            this.comorbilidades = objContact.Comorbilidades__c;
            this.obraSocial = objContact.health_insurance__c;
            this.tuvoCovid = objContact.Tuvo_Covid19__c;

            
            //JSON ideal: '[{"dosis":"Primera dosis","nombre":"SPUTNIK sarasa 11111111 Insituto gamalaya","fecha":"15/03/2021"},{"dosis":"Segunda dosis","nombre":"SPUTNIK sarasa 222222 Insituto gamalaya","fecha":"15/07/2021"},{"dosis":"Tercera dosis","nombre":"SPUTNIK sarasa 33 Insituto gamalaya","fecha":"15/01/2022"}]'
            //this.vacunas = (List<Vacuna>) JSON.deserialize(objContact.covid_vacc_desc__c, List<Vacuna>.class);

            Map<Integer,Date> fechasDosis = camposFechaToArray (objContact);
            
            if(!String.isBlank(objContact.covid_vacc_desc__c)){
                this.vacunas = new List<Vacuna> ();
                List<String> nombresVacunas = objContact.covid_vacc_desc__c.split(';');
                for(Integer i = 0 ; i < nombresVacunas.size() ; i ++) {
                    Vacuna vacunaTemp = new Vacuna();
                    if(fechasDosis.containsKey(i))
                        vacunaTemp.fecha = fechasDosis.get(i);
                    vacunaTemp.nombre = nombresVacunas[i];
                    vacunaTemp.dosis = i;
                    this.vacunas.add(vacunaTemp);
                }
            }
        }

        private Map<Integer,Date> camposFechaToArray (Contact objContact) {
            Map<Integer,Date> fechasDosis = new Map<Integer,Date> ();
            if(objContact.covid_vacc_1st_dose__c != null) fechasDosis.put(0, objContact.covid_vacc_1st_dose__c);
            if(objContact.covid_vacc_2nd_dose__c != null) fechasDosis.put(1, objContact.covid_vacc_2nd_dose__c);
            if(objContact.covid_vacc_3rd_dose__c != null) fechasDosis.put(2, objContact.covid_vacc_3rd_dose__c);
            return fechasDosis;
        }
    }

    public class Vacuna {
        @AuraEnabled
        public Integer dosis {get; set;}
        @AuraEnabled
        public String nombre {get; set;}
        @AuraEnabled
        public Date fecha {get; set;}
    }


    @AuraEnabled
    public Contact citizen 				{ get; set; }
    @AuraEnabled
    public GeneralInfo generalInfo 		{ get; set; }
    @AuraEnabled
    public Attributes attributes 		{ get; set; }
    @AuraEnabled
    public MovilidadInfo movilidadInfo 	{ get; set; }
    @AuraEnabled
    public IncomeInfo incomeInfo 		{ get; set; }

    @AuraEnabled
    public ElectoralInfo electoralInfo 	{ get; set; }

    @AuraEnabled
    public ElectoralPaso2023 electoralPaso2023 	{ get; set; }

    @AuraEnabled
    public HashtagsInfo hashTags 		{ get; set; }

    @AuraEnabled
    public Cuidarnos cuidarnos 		{ get; set; }
    
    @AuraEnabled
    public Pilar360 pilar360 		{ get; set; }

    @AuraEnabled
    public Misiones misiones 		{ get; set; }

    @AuraEnabled
    public ComunidadRadicales comunidadRadicales 	{ get; set; }

    @AuraEnabled
    public DatosSalud datosSalud 	{ get; set; }


    @AuraEnabled
    public RemotingMessageHelper.UserPermissions permissions 		{ get; set; }
    
    public CitizenWrapper(Contact objContact) {
        this.communitySite = HelperFunctions.retrieveSite();
        this.citizen = objContact;

        this.generalInfo = new GeneralInfo(this.communitySite, objContact);        
        this.attributes = new Attributes(this.communitySite, objContact);        
        this.movilidadInfo = new MovilidadInfo(this.communitySite, objContact); 
        this.incomeInfo = new IncomeInfo(this.communitySite, objContact); 
        this.electoralInfo = new ElectoralInfo(this.communitySite, objContact); 
        this.electoralPaso2023 = new ElectoralPaso2023(objContact);
        this.hashTags = new HashtagsInfo(this.communitySite, objContact);
        this.cuidarnos = new Cuidarnos(this.communitySite, objContact);     
        this.pilar360 = new Pilar360(this.communitySite, objContact);     
        this.misiones = new Misiones(this.communitySite, objContact);
        this.comunidadRadicales = new ComunidadRadicales(this.communitySite, objContact);   
        this.datosSalud = new DatosSalud(this.communitySite, objContact);
        
        this.permissions = new RemotingMessageHelper.UserPermissions();
    }    
     
}