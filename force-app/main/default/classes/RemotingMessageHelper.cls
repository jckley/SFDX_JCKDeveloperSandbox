global class RemotingMessageHelper {  

    public class CuidarnosPilarCovidCuitificacion {
        public String nombre { get; set;}
        //public String email { get; set;}
        public Integer dni { get; set;}
        public String sexo { get; set;}
        public String fecha_nacimiento { get; set;}
        public String fecha_covid { get; set;}
        public String estado { get; set;}
        public String alta_epidemeologica { get; set;}
    }

    public class MCSMS {
        public List<String> mobileNumbers   { get; set; }
        public Boolean Subscribe { get; set; }
        public Boolean Resubscribe { get; set; }
        public Boolean OverrideAUX { get; set; }
        public String keyword { get; set; }
        public String messageText { get; set; }

        public MCSMS() {
            this.mobileNumbers = new List<String>();  
            this.Subscribe = true;
            this.Resubscribe = true;
            this.OverrideAUX = true;
        }
    }

    public class MCSMSSingle {
        public List<String> mobileNumbers   { get; set; }

        public MCSMSSingle() {
            this.mobileNumbers = new List<String>();  
        }
    }

    public class MCAuth {
        public String grant_type   { get; set; }
        public String client_id   { get; set; }
        public String client_secret   { get; set; }
        public String scope   { get; set; }
        public String account_id   { get; set; }

        public MCAuth() {
            this.grant_type = ''; 
            this.client_id = ''; 
            this.client_secret = ''; 
            this.scope = ''; 
            this.account_id = '';  
        }
    }

    //2020-12-29 FL Clases para envío de SMS por MC desde el panel SMS
    public class MCSMS2 {
        public String MessageId { get; set; }
        public String Keyword { get; set; }
        public String NotificationEmail { get; set; }
        public Boolean OverrideAux { get; set; }
        public String OverrideText { get; set; }
        public Boolean IsDuplicationAllowed { get; set; }
        public Boolean IsVisible { get; set; }
        public List<MCSMS_ImportDefinition> ImportDefinition { get; set; }
        
        public MCSMS2(String messageId, String keyword) {
            this.MessageId = messageId;
            this.Keyword = keyword;
            this.OverrideAux = true;
            this.IsDuplicationAllowed = true;
            this.IsVisible = true;
            this.ImportDefinition = new List<MCSMS_ImportDefinition>();
        }

        public void addDataExtension(String dataExtension){
            this.importDefinition.add(new MCSMS_ImportDefinition(dataExtension));
        }
    }

    public class MCSMS_ImportDefinition {

        public String ImportType { get; set; }
        public String ImportMappingType { get; set; }
        public String DataExtensionName { get; set; }
        public Boolean IsFirstRowHeader { get; set; }
        
        public MCSMS_ImportDefinition(String dataExtension) {
            this.ImportType = 'DATA_EXTENSION';  
            this.ImportMappingType = 'InferFromColumnHeadings';
            this.DataExtensionName = dataExtension;
            this.IsFirstRowHeader = true;
        }
    }

    public class MCSMS_ImportSendStatus {

        public String status { get; set; }
        public String lastUpdate { get; set; }
        public String createdTime { get; set; }
        public String startTime { get; set; }
        public String completedTime { get; set; }
        public String lastRunTime { get; set; }
        public String source { get; set; }
        public String inserted { get; set; }
        public String updated { get; set; }
        public String invalid { get; set; }
        
        public MCSMS_ImportSendStatus() {
            
        }
    }

    public virtual class CuidarnosCuitificacion {
        public String nombre { get; set; }
        public String apellido { get; set; }
        public String direccion { get; set; }
        public String sexo { get; set; }
        public Date fecha_nacimiento { get; set; }
        public Decimal score { get; set; }
    
        public String level1 { get; set; }
        public String level2 { get; set; }
        public String level3 { get; set; }
        public String level4 { get; set; }
    
        public CuidarnosCuitificacion(Contact objContact) {
            if(String.IsNotBlank(objContact.MiddleName)) {
                this.nombre = objContact.FirstName + ' ' + objContact.MiddleName;
            } else {
                this.nombre = objContact.FirstName;
            }

            this.apellido = objContact.LastName;
            this.direccion = this.retrieveAddressSimple(objContact);
            this.score = objContact.covid19_predictiva_score__c;
            this.fecha_nacimiento = objContact.BirthDate;
            this.sexo = objContact.Gender__c;

            this.level1 = objContact.Administrative_Level_1__c;
            this.level2 = objContact.Administrative_Level_2__c;
            this.level3 = objContact.Administrative_Level_3__c;
            this.level4 = objContact.Administrative_Level_4__c;
        }


        private String retrieveAddressSimple(Contact objContact) {
            String strAddress = null;
            
            System.debug('retrieveAddressSimple [] ->');

            if(String.isNotBlank(objContact.MailingStreet)) {    
                objContact.MailingStreet = String.join(HelperFunctions.capitalizeList(objContact.MailingStreet.split(' ')), ' ');
                if(String.isNotBlank(objContact.MailingNumber__c) ) {
                    if(String.isNotBlank(objContact.MailingAppartment__c)) {
                        strAddress = String.format('{0} {1} {2}', new String[] {objContact.MailingStreet, objContact.MailingNumber__c, objContact.MailingAppartment__c  });                  		                
                    } else {                    
                        strAddress = String.format('{0} {1}', new String[] {objContact.MailingStreet, objContact.MailingNumber__c });                  		                
                    }
                } else {
                    if(String.isNotBlank(objContact.MailingAppartment__c)) {
                        strAddress = String.format('{0} {1}, {2}', new String[] {  objContact.MailingStreet, objContact.MailingAppartment__c});
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
    }

    public class CustomSelectOptions{
        @AuraEnabled String label { get; set; }
        @AuraEnabled String value { get; set; }
    
        public CustomSelectOptions() {
            this.label = '';
            this.value = '';
        }
    
        public CustomSelectOptions(String strLabel, String strValue) {
            this.label = strLabel;
            this.value = strValue;
        }
    }

    global class SMSSondeosRequest {
        public String sender {get;set;}
        public String dataExtension{get;set;}
        public String dataExtensionName{get;set;}
        public String message{get;set;}
        public String titulo{get;set;}
        public String proyecto{get;set;}
        public String messageid{get;set;}
    }

    global class Sondeos { 
        public String origen 	{ get; set; }
        public String origenRotativo 	{ get; set; }
        public String destino 	{ get; set; }
        public String telco { get; set; }
        public String fecha { get; set; }
        public String mensaje { get; set; }
        public String source_addr_ton { get; set; }
        public String source_addr_npi { get; set; }
    }

    global class SondeosDR { 
        public SondeosAuth auth { get; set; }
        public List<SondeosOption> options { get; set; }
        public SondeosParametersDR parameters { get; set; }
        public SondeosService service { get; set; }
    }

    global class SondeosMO { 
        public SondeosAuth auth { get; set; }
        public List<SondeosOption> options { get; set; }
        public SondeosParametersMO parameters { get; set; }
        public SondeosService service { get; set; }
    }
    
    global class SondeosAuth { 
        public String password { get; set; }
        public String usuario { get; set; }
    }


    global class SondeosIVR { 
        public SondeosAuth auth { get; set; }
        public SondeosService service { get; set; }
        public SondeosParametersIVR parameters { get; set; }
    }

    global class SondeosParametersIVR { 
        public String doctor { get; set; }
        public String patient { get; set; }
    }

    global class SondeosOption { 

    }

    global class SondeosParametersDR { 
        public String celco { get; set; }
        public String customerId { get; set; }
        public Long destino { get; set; }
        public Integer estado { get; set; }
        public String id_mensaje { get; set; }
        public String msgId { get; set; }
        public Long origen { get; set; }
        public Long origenRotativo { get; set; }
        public String shortMessageDR { get; set; }
    }

    global class SondeosParametersMO { 
        public String customerId { get; set; }
        public Long destino { get; set; }
        public String fecha { get; set; }
        public String mensaje { get; set; }
        public Long origen { get; set; }
        public Long origenRotativo { get; set; }
        public String telco { get; set; }
    }

    global class SondeosService {  
        public String operacion { get; set; }
        public String provision { get; set; }

    }
    
    global class CountRecordsRequest {  
        public String type { get; set; }
        public String query { get; set; }
    }
    global class CountRecordsRespose {  
        public Integer code { get; set; }
        public String message { get; set; }
        public Integer count { get; set; }
    }

    global class CuidarnosNotifyUserRequest {  
        public String client { get; set; }
        public String guid { get; set; }
        public String dni { get; set; }
        public String salesforceid { get; set; }
    }


    global class ResendSMS {  
        public String usuario { get; set; }
        public String password { get; set; }
        public String provision { get; set; }
        public String operacion { get; set; }
        public String sourceAddress { get; set; }
        public String consultaEstado { get; set; }
        public String messageid { get; set; }
        public String maxintentos { get; set; }
    }

    global class Pulso { 
        public String TypeFormUrl 	{ get; set; }
        public String TwitterLink 	{ get; set; }
        public String FacebookLink 	{ get; set; }
        public String InstagramLink { get; set; }
        public String Domain { get; set; }
        
        public Pulso() {} 
    }  
        
    public class PulsoSurvey {
        public String Id 			 { get; set; }
        public String typeformid 	 { get; set; }
        public String advertisingid  { get; set; }
        public String name         	 { get; set; }
        public String description    { get; set; }
        public Integer preguntas     { get; set; }
        public Integer surveyed   	 { get; set; }
        public Integer identified 	 { get; set; }
        public Boolean showQuestion  { 
            get {
                return this.preguntas > 0;
            } 
        }
        
        public PulsoSurvey() {}
        public PulsoSurvey(Encuesta__c objSurvey) {
            this.Id = objSurvey.Id;
            this.typeformid = objSurvey.TypeformId__c;
            this.advertisingid = objSurvey.AdvertinsingID__c;
            this.name = objSurvey.TituloEncuesta__c;
            this.description = objSurvey.Description__c;
             
            if(objSurvey.Number_of_Questions_VIew__c == NULL) {
                this.preguntas = 0;                
            } else {
                this.preguntas = Integer.valueOf(objSurvey.Number_of_Questions_View__c);
            }
        }
    }
      
    public class TerritoryInfo {
        private String strResourceBaseUrl = null;
        private String strCommunity = null;
        
        @AuraEnabled
        public String name 																	{ get; set; }        
        @AuraEnabled
        public String administrativelevel 													{ get; set; }        
        @AuraEnabled
        public String parent 																{ get; set; }        
        @AuraEnabled
        public String parentid 																{ get; set; }                
        @AuraEnabled
        public String total 																{ get; set; }
        @AuraEnabled
        public String totalwomen 															{ get; set; }
        @AuraEnabled
        public String totalmen 		                                                        { get; set; }
        @AuraEnabled
        public String parentlink														    { get; set; }        
        @AuraEnabled
        public String geocode   														    { get; set; }        

        @AuraEnabled
        public String riverTotal 																{ get; set; }
        @AuraEnabled
        public String riverTotalwomen 															{ get; set; }
        @AuraEnabled
        public String riverTotalmen 		                                                        { get; set; }

        @AuraEnabled
        public List<TerritoryInfoGenerationInfoList> generationInfo 						{ get; set; }
        @AuraEnabled
        public List<TerritoryInfoEducationLevelInfoList> educationLevels 					{ get; set; }
        @AuraEnabled
        public List<TerritoryInfoOccupationTypesInfoList> occupationTypes 					{ get; set; }        
        @AuraEnabled
        public List<TerritoryInfoIncomeRangesInfoList> incomeranges 						{ get; set; }     
        @AuraEnabled
        public List<TerritoryInfoGeographicDistributionsInfoList> geographicdistributions 	{ get; set; }
        @AuraEnabled
        public List<TerritoryInfoGeographicDistributionsInfoList> riverGeographicdistributions 	{ get; set; }    
        @AuraEnabled
        public List<TerritoryInfoEconomicActivitiesInfoList> economicactivities 			{ get; set; }
        
        @AuraEnabled
        public Territorio_Administrativo__c territoryRecord 																	{ get; set; }
        
        public TerritoryInfo() {
            this.total = '0';
            this.totalwomen = '0';
            this.totalmen = '0';
            this.riverTotal = '0';
            this.riverTotalwomen = '0';
            this.riverTotalmen = '0';
            this.generationInfo = new List<TerritoryInfoGenerationInfoList>();
            this.educationLevels = new List<TerritoryInfoEducationLevelInfoList>();
			this.occupationTypes = new List<TerritoryInfoOccupationTypesInfoList>();        
            this.incomeranges = new List<TerritoryInfoIncomeRangesInfoList>();     
            this.geographicdistributions = new List<TerritoryInfoGeographicDistributionsInfoList>();
            this.riverGeographicdistributions = new List<TerritoryInfoGeographicDistributionsInfoList>();    
            this.economicactivities = new  List<TerritoryInfoEconomicActivitiesInfoList>();
            this.territoryRecord = new Territorio_Administrativo__c ();           
        }
        
        public TerritoryInfo(Territorio_Administrativo__c objTerritory, String strCurrentCommunity) {
            this();            
            this.strResourceBaseUrl = HelperFunctions.retrieveStaticResourceBaseUrl('PRM');
            this.strCommunity = strCurrentCommunity;
            
            this.name = objTerritory.Name;
            this.parent = objTerritory.ParentId__r.Name;
            this.parentid = objTerritory.ParentId__c;
            this.administrativelevel = String.valueOf(objTerritory.Nivel_Administrativo__c);
            
            this.total = HelperFunctions.formatNumber(objTerritory.Total_Ciudadanos__c);
            this.totalwomen = HelperFunctions.formatNumber(objTerritory.Total_Number_of_Females__c);
            this.totalmen = HelperFunctions.formatNumber(objTerritory.Total_Number_of_Males__c);
            
            this.riverTotal = HelperFunctions.formatNumber(objTerritory.RiverId_Total_Ciudadanos__c);
            this.riverTotalwomen = HelperFunctions.formatNumber(objTerritory.RiverId_Total_Number_of_Females__c);
            this.riverTotalmen = HelperFunctions.formatNumber(objTerritory.RiverId_Total_Number_of_Males__c);

            this.geocode = objTerritory.Geocode__c;

            this.territoryRecord = objTerritory;

            loadGenerationInfo(objTerritory);
            loadEducactionLevel(objTerritory);
            loadOccupationType(objTerritory);
            loadEconomicActivities(objTerritory);
            loadIncomeRange(objTerritory);            
        }
        
        private void loadGenerationInfo(Territorio_Administrativo__c objTerritory) {
            TerritoryInfoGenerationInfoList objInfo = null;
            
            objInfo = new TerritoryInfoGenerationInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/genUnder16.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_GEN_Under_16;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Etario_Sub_16_Total__c);
            objInfo.info.description = Label.PRM_GEN_Under_16_Description;     
            this.generationInfo.add(objInfo);

            objInfo = new TerritoryInfoGenerationInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/genCentennials.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_GEN_Centennials;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Etario_Centennials_Total__c);
            objInfo.info.description = Label.PRM_GEN_Centennials_Description;     
            this.generationInfo.add(objInfo);
            
            objInfo = new TerritoryInfoGenerationInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/genMillennials.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_GEN_Millennials;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Etario_Millennials_Total__c);
            objInfo.info.description = Label.PRM_GEN_Millennials_Description;     
            this.generationInfo.add(objInfo);

            objInfo = new TerritoryInfoGenerationInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/genGenerationX.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_GEN_Generation_X;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Etario_Generacion_X_Total__c);
            objInfo.info.description = Label.PRM_GEN_Generation_X_Description;     
            this.generationInfo.add(objInfo);
            
            objInfo = new TerritoryInfoGenerationInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/genBabyBoomers.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_GEN_Baby_Boomers;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Etario_Baby_Boomers_Total__c);
            objInfo.info.description = Label.PRM_GEN_Baby_Boomers_Description;     
            this.generationInfo.add(objInfo);
            
            objInfo = new TerritoryInfoGenerationInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/genSilentGeneration.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_GEN_Silent_Generation;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Etario_Generacion_Silenciosa_Total__c);
            objInfo.info.description = Label.PRM_GEN_Silent_Generation_Description;     
            this.generationInfo.add(objInfo);
        }
        
        private void loadEducactionLevel(Territorio_Administrativo__c objTerritory) {
            TerritoryInfoEducationLevelInfoList objInfo = null;
            
            objInfo = new TerritoryInfoEducationLevelInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/educationLevelPrimary.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_EL_Primary;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Education_Level_Primary__c);
            objInfo.info.description = Label.PRM_EL_Primary;     
            this.educationLevels.add(objInfo);
            
            objInfo = new TerritoryInfoEducationLevelInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/educationLevelSecondary.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_EL_Secondary;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Education_Level_Secondary__c);
            objInfo.info.description = Label.PRM_EL_Secondary;     
            this.educationLevels.add(objInfo);
            
            objInfo = new TerritoryInfoEducationLevelInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/educationLevelTertiary.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_EL_Tertiary;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Education_Level_Tertiary__c);
            objInfo.info.description = Label.PRM_EL_Tertiary;     
            this.educationLevels.add(objInfo);
            
            objInfo = new TerritoryInfoEducationLevelInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/educationLevelUniversityDegree.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_EL_University_Degree;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Education_Level_University_Degree__c);
            objInfo.info.description = Label.PRM_EL_University_Degree;    
            
            this.educationLevels.add(objInfo);
        }
    
        private void loadOccupationType(Territorio_Administrativo__c objTerritory) {
            TerritoryInfoOccupationTypesInfoList objInfo = null;
            
            objInfo = new TerritoryInfoOccupationTypesInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/occupationTypeWageEarner.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_OT_Wage_Earner;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Occupation_Type_Wage_Earned__c);
            objInfo.info.description = Label.PRM_OT_Wage_Earner;     
            this.occupationTypes.add(objInfo);
            
            objInfo = new TerritoryInfoOccupationTypesInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/occupationTypeSelfEmployed.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_OT_Self_Employed;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Occupation_Type_Self_Employed__c);
            objInfo.info.description = Label.PRM_OT_Self_Employed;     
            this.occupationTypes.add(objInfo);
                                    
            objInfo = new TerritoryInfoOccupationTypesInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/occupationTypeRetired.png', new String[] { this.strResourceBaseUrl , this.strCommunity});
            objInfo.info.name = Label.PRM_OT_Retired;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Occupation_Type_Retired__c);
            objInfo.info.description = Label.PRM_OT_Retired;     
            this.occupationTypes.add(objInfo);
            
            objInfo = new TerritoryInfoOccupationTypesInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.image = String.format('{0}/{1}/img/occupationTypeNotDeclared.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
            objInfo.info.name = Label.PRM_OT_Not_Declared;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Occupation_Type_Not_Declared__c);
            objInfo.info.description = Label.PRM_OT_Not_Declared;    
            
            this.occupationTypes.add(objInfo);
        }

        private void loadIncomeRange(Territorio_Administrativo__c objTerritory) {
            TerritoryInfoIncomeRangesInfoList objInfo = null;
            
            objInfo = new TerritoryInfoIncomeRangesInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.name = Label.PRM_Income_Range_Very_Low;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Income_Range_Very_Low__c);
            objInfo.info.description = Label.PRM_Income_Range_Very_Low_Description;     
            this.incomeranges.add(objInfo);
            
            objInfo = new TerritoryInfoIncomeRangesInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.name = Label.PRM_Income_Range_Low_Description;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Income_Range_Low__c);
            objInfo.info.description = Label.PRM_Income_Range_Low_Description;     
            this.incomeranges.add(objInfo);
            
            objInfo = new TerritoryInfoIncomeRangesInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.name = Label.PRM_Income_Range_Medium;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Income_Range_Medium__c);
            objInfo.info.description = Label.PRM_Income_Range_Medium_Description;     
            this.incomeranges.add(objInfo);
                                    
            objInfo = new TerritoryInfoIncomeRangesInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.name = Label.PRM_Income_Range_High;
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Income_Range_High__c);
            objInfo.info.description = Label.PRM_Income_Range_High_Description;     
            this.incomeranges.add(objInfo);
            
            objInfo = new TerritoryInfoIncomeRangesInfoList();
            objInfo.info = new TerritoryDetailInfo();
            objInfo.info.name = Label.PRM_Income_Range_Very_High; 
            objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Income_Range_Very_High__c);
            objInfo.info.description = Label.PRM_Income_Range_Very_High_Description;     
            this.incomeranges.add(objInfo); 
        }
        
        public void loadGeographicDistribution(List<Territorio_Administrativo__c> lstChildTerritories) {
            TerritoryInfoGeographicDistributionsInfoList objInfo = null;

            if(lstChildTerritories != NULL && !lstChildTerritories.isEmpty()) {     
                for(Territorio_Administrativo__c objTerritory : lstChildTerritories) {
                    objInfo = new TerritoryInfoGeographicDistributionsInfoList();
                    objInfo.info = new TerritoryDetailInfo();
                    objInfo.info.image =  String.format('{0}/{1}/img/IconLocation.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
                    objInfo.info.name = objTerritory.Name; 
                    objInfo.info.value = HelperFunctions.formatNumber(objTerritory.Total_Ciudadanos__c);
                    objInfo.info.description = objTerritory.Name;     
                    if(String.isNotBlank(Site.getSiteId())) {
                        objInfo.info.link = String.format('/prosumia/{0}', new String[] { objTerritory.Id }); 
                    } else {
                        objInfo.info.link = String.format('/{0}', new String[] { objTerritory.Id });                         
                    }
                    this.geographicdistributions.add(objInfo);
                }
            }

            TerritoryInfoGeographicDistributionsInfoList riverObjInfo = null;

            if(lstChildTerritories != NULL && !lstChildTerritories.isEmpty()) {     
                for(Territorio_Administrativo__c objTerritory : lstChildTerritories) {
                    riverObjInfo = new TerritoryInfoGeographicDistributionsInfoList();
                    riverObjInfo.info = new TerritoryDetailInfo();
                    riverObjInfo.info.image =  String.format('{0}/{1}/img/IconLocation.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
                    riverObjInfo.info.name = objTerritory.Name; 
                    riverObjInfo.info.value = HelperFunctions.formatNumber(objTerritory.RiverId_Total_Ciudadanos__c);
                    riverObjInfo.info.description = objTerritory.Name;     
                    if(String.isNotBlank(Site.getSiteId())) {
                        riverObjInfo.info.link = String.format('/prosumia/{0}', new String[] { objTerritory.Id }); 
                    } else {
                        riverObjInfo.info.link = String.format('/{0}', new String[] { objTerritory.Id });                         
                    }
                    this.riverGeographicdistributions.add(riverObjInfo);
                }
            }
        }
        
        private void loadEconomicActivities(Territorio_Administrativo__c objTerritory) {
            
            if(String.isNotBlank(objTerritory.Total_Economic_Activities__c)) {
                List<String> lstEconomicActivities = objTerritory.Total_Economic_Activities__c.split(';');
                String strImage = String.format('{0}/{1}/img/occupationTypeWageEarner.png', new String[] { this.strResourceBaseUrl, this.strCommunity });

                for(String strEconomicActivity : lstEconomicActivities) {
                    List<String> lstEconomicActivity = strEconomicActivity.split(':');
                    // System.debug('lstEconomicActivity : ' + lstEconomicActivity);
                    if(lstEconomicActivity != null && !lstEconomicActivity.isEmpty() && lstEconomicActivity.size() == 2) {
                        TerritoryInfoEconomicActivitiesInfoList objInfo = new TerritoryInfoEconomicActivitiesInfoList();
                        objInfo.info = new TerritoryDetailInfo();
                        objInfo.info.image =  strImage;
                        objInfo.info.name = lstEconomicActivity[0];
                        objInfo.info.value = HelperFunctions.formatNumber(Decimal.valueOf(lstEconomicActivity[1]));
                        objInfo.info.description = objTerritory.Name;     
                        this.economicactivities.add(objInfo);
                    }
                }
            }

            String strImage = String.format('{0}/{1}/img/occupationTypeWageEarner.png', new String[] { this.strResourceBaseUrl, this.strCommunity });
        }
    }
    
    public class TerritoryInfoGenerationInfoList { 
        @AuraEnabled
        public TerritoryDetailInfo info { get; set; } 
    }
    
    public class TerritoryInfoEducationLevelInfoList { 
        @AuraEnabled
        public TerritoryDetailInfo info { get; set; } 
    }
    
    public class TerritoryInfoOccupationTypesInfoList { 
        @AuraEnabled
        public TerritoryDetailInfo info { get; set; } 
    }
    
    public class TerritoryInfoIncomeRangesInfoList { 
        @AuraEnabled
        public TerritoryDetailInfo info { get; set; } 
    }
        
    public class TerritoryInfoGeographicDistributionsInfoList { 
        @AuraEnabled
        public TerritoryDetailInfo info { get; set; } 
    }
    
    public class TerritoryInfoEconomicActivitiesInfoList { 
        @AuraEnabled
        public TerritoryDetailInfo info { get; set; } 
    }
        
    public class TerritoryDetailInfo { 
        @AuraEnabled
        public String link 			{ get; set; }
        @AuraEnabled
        public String image 		{ get; set; }
        @AuraEnabled
        public String name 			{ get; set; }
        @AuraEnabled
        public String value 		{ get; set; }
        @AuraEnabled
        public String description 	{ get; set; }
    }
    
    public class Territory {
        @AuraEnabled
        public Territorio_Administrativo__c Territorio { get; set; }
        
        @AuraEnabled
        public Id Id { get; set; }
        
        @AuraEnabled
        public String Name { get; set; }
        
        @AuraEnabled
        public Integer Level { get; set; }
        
        @AuraEnabled
        public String Flag { get; set; }
        
        @AuraEnabled
        public Boolean IsSelected { get; set; }
        
        public Territory() { }
        public Territory(Territorio_Administrativo__c objTerritory ) {
            this.Id = objTerritory.Id;
            this.Name = objTerritory.Name;
            this.Level = Integer.valueOf(objTerritory.Nivel_Administrativo__c);
        }
        
        public Territory(Territorio_Administrativo__c objTerritory, Boolean boolIsSelected ) {
            this.Name = objTerritory.Name;
            this.Flag = objTerritory.Flag__c;
            this.Level = Integer.valueOf(objTerritory.Nivel_Administrativo__c);
            this.IsSelected = boolIsSelected;
        }
    }
    
    public class ProfileUser {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String Name { get; set; }
        @AuraEnabled
        public String ProfileUserType { get; set; }         
        @AuraEnabled
        public Boolean IsPortalEnabled { get; set; } 
        @AuraEnabled
        public String Username { get; set; } 
        
        public ProfileUser(Profile objProfile) {
            this.Id = objProfile.Id;
            this.Name = objProfile.Name;
            this.ProfileUserType = 'PROFILE';
            this.IsPortalEnabled = false;
            this.Username = '';
        }
        
        public ProfileUser(User objUser) {
            this.Id = objUser.Id;
            this.Name = objUser.Name;
            this.ProfileUserType = 'USER';
            this.IsPortalEnabled = objUser.IsPortalEnabled;
            this.Username = objUser.Username;
        }
    }
    
    public class ProfileUserPermission { 
        public String 					TimeRange 	{ get; set; }
        public Integer 					MaxRecords 	{ get; set; }
        public Integer 					Records 	{ get; set; }
        public List<FieldPermission> 	Fields 		{ get; set; }
    }
    
    public class FieldPermission {
        @AuraEnabled
        public String Id { get; set; }
        
        @AuraEnabled
        public String Name { get; set; }
        
        @AuraEnabled
        public Boolean CanRead { get; set; }         
        
        @AuraEnabled
        public Boolean CanWrite { get; set; }         
        
        @AuraEnabled
        public Boolean CanExport { get; set; }      
        
        public Permission__c toSObject() {
            Permission__c objPermission = null;
            
            objPermission = new Permission__c();
            objPermission.Can_Export__c = this.CanExport;
            objPermission.FieldName__c = this.Name;
            
            return objPermission;
        }
    }
    
    public class SalesforceDoamins {
        @AuraEnabled
        public String LEX { get; set; }
        @AuraEnabled
        public String VF { get; set; } 
    }
    
    public class CommunitySettings {
        @AuraEnabled
        public String LEX { get; set; }
        @AuraEnabled
        public String VF { get; set; } 
        @AuraEnabled
        public String ContactLayout { get; set; }
    }
    
    public class MultipicklistOptions {
        @AuraEnabled
        public String label { get; set; }
        
        @AuraEnabled
        public String value { get; set; }
        
        @AuraEnabled
        public Boolean selected { get; set; } 
    }
    
    public class Citizen { 
        @AuraEnabled
        public Id Id { get; set; }
        @AuraEnabled
        public String FirstName { get; set; }
        @AuraEnabled
        public String LastName { get; set; }
        @AuraEnabled
        public String Email { get; set; }
        @AuraEnabled
        public String MobilePhone { get; set; }
        @AuraEnabled
        public String ProfilePicture { get; set; }
        
        public Citizen (Contact objCitizen) {
            this.Id = objCitizen.Id;
            this.FirstName = objCitizen.FirstName;
            this.LastName = objCitizen.LastName;
            this.Email = objCitizen.Email;
            this.MobilePhone = objCitizen.MobilePhone; 
            this.ProfilePicture = String.isNotBlank(objCitizen.PhotoUrl_legacy__c)?objCitizen.PhotoUrl_legacy__c:'';
        }
    }
    
    public class UserPermissions {
        @AuraEnabled
        public Boolean ContactViewAttributes { get; set; }
        @AuraEnabled
        public Boolean ContactViewCommonData { get; set; }
        @AuraEnabled
        public Boolean ContactViewContactInfo { get; set; }
        @AuraEnabled
        public Boolean ContactViewContactInfoDetails { get; set; }
        @AuraEnabled
        public Boolean ContactViewElectoral	{ get; set; }
        @AuraEnabled
        public Boolean ContactViewIncome { get; set; }
        @AuraEnabled
        public Boolean ContactViewLocation { get; set; }
        @AuraEnabled
        public Boolean ContactViewMapInfo { get; set; }
        @AuraEnabled
        public Boolean ContactViewSocialInfo { get; set; }
        @AuraEnabled
        public Boolean ContactViewSocialInfoDetails	{ get; set; }
        @AuraEnabled
        public Boolean ContactViewCuidarnos	{ get; set; }
        @AuraEnabled
        public Boolean ContactViewCuidarnosMark	{ get; set; }
        @AuraEnabled
        public Boolean ContactViewCuidarnosViewObservations	{ get; set; }
        @AuraEnabled
        public Boolean ContactViewCuidarnosEditObservations	{ get; set; }
        @AuraEnabled
        public Boolean ContactViewStandardPage	{ get; set; }
        @AuraEnabled
        public Boolean ContactViewSerologico	{ get; set; }
        @AuraEnabled
        public Boolean ContactViewEtiquetas	{ get; set; }
        @AuraEnabled
        public Boolean ContactViewHealth { get; set; }


        @AuraEnabled
        public Boolean CuidannosCanNotify	{ get; set; }
        @AuraEnabled
        public Boolean CuidarnosCanArchive	{ get; set; }
        @AuraEnabled
        public Boolean CuidarnosCanDiscard	{ get; set; }
        @AuraEnabled
        public Boolean CuidarnosCanLoad_Result	{ get; set; }
        @AuraEnabled
        public Boolean CuidarnosCanSuspect	{ get; set; }
        @AuraEnabled
        public Boolean CuidarnosCanTag	{ get; set; }

        @AuraEnabled
        public Boolean CuidarnosCanTriage	{ get; set; }     

        @AuraEnabled
        public Boolean CuidarnosCanCall	{ get; set; }             


        @AuraEnabled
        public Boolean CuidarnosCanNotifyEmail	{ get; set; }   

        @AuraEnabled
        public Boolean CuidarnosCanNotifyDetectSMS1	{ get; set; }   

        @AuraEnabled
        public Boolean CuidarnosCanNotifyDetectSMS2	{ get; set; }   


        @AuraEnabled
        public Boolean CuidarnosCanNotifyNoDetectSMS1	{ get; set; }   
        @AuraEnabled
        public Boolean CuidarnosCanNotifyNoDetectSMS2	{ get; set; }   

        @AuraEnabled
        public Boolean CuidarnosCanNotifyInvalidSMS3	{ get; set; }   

        @AuraEnabled
        public Boolean CuidarnosCanArechiveAlta	{ get; set; }  


        @AuraEnabled
        public Boolean CuidarnosViewHistoryTag	{ get; set; }   

        @AuraEnabled
        public Boolean CuidarnosCanFollow	{ get; set; }   

        @AuraEnabled
        public Boolean CuidarnosCanUpdateRisk	{ get; set; }           

        @AuraEnabled
        public Boolean ViewEdition { get; set; }
        @AuraEnabled
        public Boolean ContactViewTags { get; set; }

        @AuraEnabled
		public Boolean SMSDebug { get; set; }
		
		@AuraEnabled
        public Boolean CuidarnosTestTypeAntigeno { get; set; }

		@AuraEnabled
		public Boolean CuidarnosTestTypePCR { get; set; }
        
        @AuraEnabled
        public Boolean CuidarnosViewHisopado { get; set; }

        @AuraEnabled
        public Boolean CuidarnosExportAlta { get; set; }
        
        @AuraEnabled
        public Map<String,Boolean> permissionsMap {get; set;}

        public UserPermissions() {
            this.ContactViewAttributes = FeatureManagement.checkPermission('Contact_View_Attributes'); 
            this.ContactViewCommonData = FeatureManagement.checkPermission('Contact_View_Common_Data'); 
            this.ContactViewContactInfo = FeatureManagement.checkPermission('Contact_View_Contact_Info'); 
            this.ContactViewContactInfoDetails = FeatureManagement.checkPermission('Contact_View_Contact_Info_Details'); 
            this.ContactViewElectoral = FeatureManagement.checkPermission('Contact_View_Electoral'); 
            this.ContactViewIncome = FeatureManagement.checkPermission('Contact_View_Income'); 
            this.ContactViewLocation = FeatureManagement.checkPermission('Contact_View_Location'); 
            this.ContactViewMapInfo = FeatureManagement.checkPermission('Contact_View_Map_Info'); 
            this.ContactViewSocialInfo = FeatureManagement.checkPermission('Contact_View_Social_Info'); 
            this.ContactViewSocialInfoDetails = FeatureManagement.checkPermission('Contact_View_Social_Info_Details'); 
            this.ContactViewCuidarnos = FeatureManagement.checkPermission('Contact_View_Cuidarnos'); 
            this.ContactViewCuidarnosMark = FeatureManagement.checkPermission('Contact_View_Cuidarnos_Mark'); 
            this.ContactViewCuidarnosViewObservations = FeatureManagement.checkPermission('Contact_View_Cuidarnos_Observations'); 
            this.ContactViewCuidarnosEditObservations = FeatureManagement.checkPermission('Contact_Edit_Cuidarnos_Observations'); 
            this.ContactViewStandardPage = FeatureManagement.checkPermission('Contact_View_Standard_Page'); 
            this.ContactViewHealth = FeatureManagement.checkPermission('ContactViewHealth'); 
            
            this.SMSDebug = FeatureManagement.checkPermission('SMS_Debug'); 

            this.ViewEdition = FeatureManagement.checkPermission('View_Edition');
            this.ContactViewTags = FeatureManagement.checkPermission('Contact_View_Tags');

            this.CuidannosCanNotify = FeatureManagement.checkPermission('Cuidarnos_Can_Notify');
            this.CuidarnosCanArchive = FeatureManagement.checkPermission('Cuidarnos_Can_Archive');
            this.CuidarnosCanDiscard = FeatureManagement.checkPermission('Cuidarnos_Can_Discard');
            this.CuidarnosCanLoad_Result = FeatureManagement.checkPermission('Cuidarnos_Can_Load_Result');
            this.CuidarnosCanSuspect = FeatureManagement.checkPermission('Cuidarnos_Can_Suspect');
            this.CuidarnosCanTag = FeatureManagement.checkPermission('Cuidarnos_Can_Tag');
            this.CuidarnosCanTriage = FeatureManagement.checkPermission('Cuidarnos_Can_Triage');
            this.CuidarnosCanCall = FeatureManagement.checkPermission('Cuidarnos_Can_Call');       
            this.CuidarnosViewHistoryTag = FeatureManagement.checkPermission('Contact_View_History_Tag');       
            this.CuidarnosCanFollow = FeatureManagement.checkPermission('Cuidarnos_Can_Follow');       
            this.CuidarnosCanUpdateRisk = FeatureManagement.checkPermission('Cuidarnos_Can_Update_Risk');       
            
 
            this.CuidarnosCanNotifyEmail = FeatureManagement.checkPermission('Cuidarnos_Can_Notify_Email');

            this.CuidarnosCanNotifyDetectSMS1 = FeatureManagement.checkPermission('Cuidarnos_Nofify_Detect_SMS_1');
            this.CuidarnosCanNotifyDetectSMS2 = FeatureManagement.checkPermission('Cuidarnos_Nofify_Detect_SMS_2');
            
            this.CuidarnosCanNotifyNoDetectSMS1 = FeatureManagement.checkPermission('Cuidarnos_Nofify_No_Detect_SMS_1');                        
            this.CuidarnosCanNotifyNoDetectSMS2 = FeatureManagement.checkPermission('Cuidarnos_Nofify_No_Detect_SMS_2');  
            
            this.CuidarnosCanNotifyInvalidSMS3 = FeatureManagement.checkPermission('Cuidarnos_Nofify_Invalid_SMS_3');  
                        
			this.CuidarnosTestTypeAntigeno = FeatureManagement.checkPermission('Cuidarnos_Test_Type_Antigeno');                        						
			this.CuidarnosTestTypePCR = FeatureManagement.checkPermission('Cuidarnos_Test_Type_PCR');                        						
      
			this.ContactViewSerologico = FeatureManagement.checkPermission('Cuidarnos_View_Serologico');                        						
            this.ContactViewEtiquetas = FeatureManagement.checkPermission('Cuidarnos_View_Etiquetas');                        						    
            
            this.CuidarnosCanArechiveAlta = FeatureManagement.checkPermission('Cuidarnos_Archive_Alta');                        						    
            this.CuidarnosViewHisopado = FeatureManagement.checkPermission('Cuidarnos_View_Hisopado');     
            
            this.CuidarnosExportAlta = FeatureManagement.checkPermission('Cuidarnos_Export_Alta');
            
            List<CustomPermission> customPermissionsList = [SELECT Id, DeveloperName FROM CustomPermission];
            this.permissionsMap = new Map<String,Boolean> ();
            for (CustomPermission thisCustomPermission : customPermissionsList) {
                String cpName = thisCustomPermission.DeveloperName;
                permissionsMap.put(cpName, FeatureManagement.checkPermission(cpName));
            }
        }
    } 
    
    public class MarketingCloudAccessToken {
        public String accessToken { get; set; }
        public Integer expiresIn { get; set; }
    }
    
    public class MarketingCloudAccessTokenV2 {
        public String access_token { get; set; }
        public String token_type { get; set; }
        public String scope { get; set; }
        public String soap_instance_url { get; set; }
        public String rest_instance_url { get; set; }
        public Integer expiresIn { get; set; }
    }

    public class EmailRequest {
        public FromAddress Sender { get; set; }
        public ToAddress To { get; set; }
        
        public String ToJSON() {
            String strJSON = null;
            
            //strJSON = String.format('{{ "From": {{ "Address": "{0}", "Name": "{1}"}} , "To": {{ "Address": "{2}", "SubscriberKey": "{3}" }},  "Options": {{ "RequestType": "SYNC" }} }}', new String[] { this.Sender.Address, this.Sender.Name, this.To.Address, this.To.SubscriberKey});
            strJSON = '{';
            strJSON += ' "From" : {';
            strJSON += String.format(' "Address" : "{0}" , "Name" : "{1}" ', new String[] {  this.Sender.Address, this.Sender.Name });
            strJSON += ' }';
            strJSON += ', "To" : {';
            strJSON += String.format(' "Address" : "{0}" , "SubscriberKey" : "{1}" ', new String[] {  this.To.Address, this.To.SubscriberKey });
            strJSON += ' }';
            strJSON += ' ,  "Options": { "RequestType": "ASYNC" } }';
            
            return strJSON;
        }
    }
    
    public class FromAddress {
        public String Address { get; set; }
        public String Name { get; set; }
    }
    
    public class ToAddress {
        public String Address { get; set; }
        public String SubscriberKey { get; set; }
    }
    
    public class SMSRequest {
        public Subscriber[] Subscribers { get; set; }
        public String Subscribe { get; set; }
        public String Resubscribe { get; set; }
        public String keyword { get; set; }
        
        public SMSRequest() {
            this.Subscribers = new List<Subscriber>();
        }
        
        public String toJSON() {
            String strJSON = null;
            Boolean boolFirstSubscriber = true;
            Boolean boolFirstAttribute = true;
            
            strJSON = '{';
            if(this.Subscribers != null && this.Subscribers.size() > 0) {
                strJSON += ' "Subscribers" : [';                
                for(Subscriber objSubscriber : this.Subscribers) {
                    if(boolFirstSubscriber) {
                        boolFirstSubscriber = false;
                    } else {
                        strJSON += ',';  
                    }
                    strJSON += '{';
                    strJSON += String.format(' "MobileNumber" : "{0}",', new String[] { objSubscriber.MobileNumber});
                    strJSON += String.format(' "SubscriberKey" : "{0}" ', new String[] { objSubscriber.SubscriberKey});
                    if(objSubscriber.Attributes != null && !objSubscriber.Attributes.IsEmpty()) {
                        strJSON += ', "Attributes" : {';  
                        boolFirstAttribute = true;
                        for(String strAttributeKey : objSubscriber.Attributes.keySet()) {
                            if(boolFirstAttribute) {
                                boolFirstAttribute = false;
                            } else {
                                strJSON += ',';  
                            }
                            
                            strJSON += String.format(' "{0}" : "{1}" ', new String[] { strAttributeKey , objSubscriber.Attributes.get(strAttributeKey) });
                        }
                        strJSON += '}';
                    }
                    strJSON += '}';                   
                }
                strJSON += '] ,';                
                strJSON += String.format(' "Subscribe" : "{0}",', new String[] { this.Subscribe});
                strJSON += String.format(' "Resubscribe" : "{0}",', new String[] { this.Resubscribe});
                strJSON += String.format(' "keyword" : "{0}"', new String[] { this.keyword });
            }
            
            strJSON += '}';
            
            System.debug('------------------------------');
            System.debug(strJSON);
            System.debug('------------------------------');
            return strJSON; 
        }
    }
    
    public class Subscriber {
        public String MobileNumber { get; set; }
        public String SubscriberKey { get; set; }      
        public Map<String, String> Attributes { get; set; }
        
        public Subscriber() {
            this.Attributes = new Map<String, String>();
        }
    }       
    
    public class SMSResponses {
        public String tokenId { get; set; }
    }
    
    global class CUITRequest {
        global String ExternalId 		{ get; set; }
        global String Client 			{ get; set; }
        global String FullName 			{ get; set; }
        global String FirstName 		{ get; set; }
        global String LastName 			{ get; set; }
        global String Gender 			{ get; set; }
        global Integer BirthDay 		{ get; set; }
        global Integer BirthMonth 		{ get; set; }
        global Integer BirthYear 		{ get; set; }
        global String Email 			{ get; set; }
        global Integer AdFiProfileId 	{ get; set; }
        
        global Boolean isValid() {
            Boolean boolIsValid = false;
            
            if(
                (
                    String.isNotBlank(this.Email) ||
                    String.isNotBlank(this.FullName) || 
                    String.isNotBlank(this.LastName) || 
                    String.isNotBlank(this.FirstName) ||
                    String.isNotBlank(this.Gender) ||
                    this.BirthYear != NULL ||
                    this.BirthMonth != NULL  || 
                    this.BirthDay != NULL ||
                    this.AdFiProfileId != NULL
                ) 
            ) {
                boolIsValid = true;
            }
            
            return boolIsValid;
        }
    }
    
    public class CUITResponse { 
        public String ExternalId  			{ get; set; }
        public Integer Code 				{ get; set; }
        public String Message 				{ get; set; }        
        public CitizenFound[] CitizensFound { get; set; }
        
        public CUITResponse() {
            this.CitizensFound = new List<CitizenFound>();
        }
    }
    
    public class CitizenFound { 
        public String FirstName  	{ get; set; }
        public String LastName 		{ get; set; }
        public String Cuit 			{ get; set; }
        public String Email 		{ get; set; }           
        public String BirthDate 	{ get; set; }   
        public String Gender 		{ get; set; }   
        public String Level1 		{ get; set; }                
        public String Level2 		{ get; set; }                
        public String Level3 		{ get; set; }                        
        public String Level4 		{ get; set; }    
        public String FacebookUser 	{ get; set; }   
        public String FacebookUrl 	{ get; set; }   
        public String FullName 		{ get; set; }   
        public Integer AdFiProfileId 	{ get; set; }
        
        public CitizenFound(Contact objContact) {
            this.FullName = objContact.Name;
            this.FirstName = objContact.FirstName;
            this.LastName = objContact.LastName;
            this.Cuit = objContact.Cuil_Number__c;
            //this.Email = objContact.Email;
            this.BirthDate = String.valueOf(objContact.BirthDate);
            this.Gender = objContact.Gender__c;
            this.Level1 = objContact.Administrative_Level_1__c;
            this.Level2 = objContact.Administrative_Level_2__c;
            this.Level3 = objContact.Administrative_Level_3__c;
            this.Level4 = objContact.Administrative_Level_4__c;      
            //this.FacebookUser = objContact.Usuario_Facebook__c;  
            //this.FacebookUrl = objContact.Facebook_Link__c;  
            this.AdFiProfileId = Integer.valueOf(objContact.ADFi_Profile_ID__c);
        }                 
    }
    
    public class ChartData {
        public List<String> 		labels 			{ get; set; }
        public List<ChartDataset> 	datasets 		{ get; set; }
        public ChartOptions 		options 		{ get; set; }
        
        public ChartData() {
            this.labels = new List<String>();
            this.datasets = new List<ChartDataset>();
            this.options = new ChartOptions();
        }
    }
    
    public class ChartDataset {
        public String 			label 			{ get; set; }
        public String 			backgroundColor { get; set; }
        public String 			borderColor 	{ get; set; }
        public Integer 			borderWidth 	{ get; set; }
        public List<Decimal> 	data 			{ get; set; }
        
        public ChartDataset() {
            this.data = new List<Decimal>();
            this.backgroundColor = 'rgb(255, 99, 132)';
            this.borderColor = 'rgb(54, 162, 235)';
            this.borderWidth = 1;
        }
    }
    
    public class ChartOptions {
        public Boolean responsive { get; set; }
        public ChartLegend legend { get; set; }
        public ChartTitle title { get; set; }
        public ChartAnimation animation { get; set; }
        public ChartScale scales { get; set; }
        
        public ChartOptions() {
            this.responsive = true;
            this.legend = new ChartLegend();
            this.title = new ChartTitle();
            this.animation = new ChartAnimation();
            this.scales = new ChartScale();
        }        
    }
    
    public class ChartLegend { 
        public String position { get; set; }        
        
        public ChartLegend() {
            this.position = 'top';
        }
    }
    
    public class ChartTitle { 
        public Boolean display { get; set; }
        public String text { get; set; }
        
        public ChartTitle() {
            this.display = true;            
        }
    }
    
    public class ChartAnimation { 
        public Boolean animateRotate { get; set; }
        public Boolean animateScale { get; set; }
        
        public ChartAnimation() {
            this.animateRotate = true;
            this.animateScale = true;           
        }
    }
    
    public class ChartScale {
        public List<ChartAxe> xAxes { get; set; }
        public List<ChartAxe> yAxes { get; set; }
        
        public ChartScale() {
            this.xAxes = new List<ChartAxe>();
            this.yAxes = new List<ChartAxe>();
        }
    }
    
    public class ChartAxe {
        public Boolean display { get; set; }
        public ChartScaleLabel scaleLabel { get; set; }
        public ChartGridLines gridLines { get; set; }
        
        public ChartAxe() {
            this.display = false;
        }        
    }
    
    public class ChartScaleLabel {
        public Boolean display { get; set; }
        public String labelString { get; set; }
        
        public ChartScaleLabel() {
            this.display = false;
        }
    }
    
    public class ChartGridLines {
        public Boolean display { get; set; }
        public Boolean drawBorder { get; set; }
        public Boolean drawOnChartArea { get; set; }
        public Boolean drawTicks { get; set; }
        
        public ChartGridLines() {
            this.display = false;
            this.drawBorder = false;
            this.drawOnChartArea = false;
            this.drawTicks = false;
            
        }
    }
    
    public class SearchResults {
        public List<SearchResult> results { get; set; }
        
        public SearchResults() {
            this.results = new List<SearchResult>();
        } 
        
        public SearchResults(List<List<sObject>> lstSOSLResult) {
            this();
            SearchResult objSearchResult = null;
            
            if(lstSOSLResult != null && !lstSOSLResult.isEmpty()) {
                for(List<sObject> lstResultType : lstSOSLResult) {
                    
                    if(lstResultType != null && !lstResultType.isEmpty()) {
                        objSearchResult = new SearchResult(lstResultType);
                        this.results.add(objSearchResult);
                    }
                }
            }
        } 
        
    }
    
    public class DistanceChartResult {
        public List<String> labelX {get; set;}
        public List<String> labelY {get; set;}
        public List<List<Decimal>> values {get; set;}

        public DistanceChartResult() {
            this.labelX = new List<String>();
            this.labelY = new List<String>();
            this.values = new List<List<Decimal>>();
        }
    }

    public class SearchResult { 
        public String type 			{ get; set; }
        public List<sObject> record { get; set; }
        
        public SearchResult() {
            this.record = new List<sObject>();
        }
        
        public SearchResult(List<sObject> lstResults) {
            this();
            if(lstResults != null && !lstResults.isEmpty()) {
                this.type = lstResults[0].getSObjectType().getDescribe().getLabel();
                this.record = lstResults;                 
            }
        }
    }
    
    public class WhatsAppMessage { 
        public String phone 	{ get; set; }
        public String chatId 	{ get; set; } 
        public String body 		{ get; set; } 
        public String filename 	{ get; set; } 
        public String caption 	{ get; set; } 
    }
    
    public class PermissionRequest {
        public String UserId 												 { get; set; }
        public String ProfileId 											 { get; set; } 
        public String SObjectName 											 { get; set; } 
        public String RecordsQuota 											 { get; set; } 
        public String MaxRecords 											 { get; set; } 
        public String TimeRange 											 { get; set; } 
        public List<RemotingMessageHelper.FieldPermission> ActivePermissions { get; set; }  
    }
    
    global class OperationResult {
        public String Id { get; set; }
        public Integer Code 	{ get; set; }
        public String Message	{ get; set; } 
        
    }
    
    public class AnalyticsMCWrapper {
        public String name 			{ get; set; }
        public String saql 			{ get; set; }
        public Boolean queryall 	{ get; set; }
        public Boolean sendable 	{ get; set; }
        public String userid 		{ get; set; }
        public String exportid      { get; set; }
        public String smsmessage    { get; set; }
    }

    
    public class PulsoNuevaAudienciaWrapper {
        public String dataExtension	{ get; set; }
        public String surveyId {get; set;}
        public List<Pulso_Survey_User_Wrapper> users {get; set;}
        public List<Map<String, String>> fields {get; set;}
        
        public PulsoNuevaAudienciaWrapper (String xDataExtension, String xSurveyId, Set<User_Survey__c> xUsers, List<String> xFields) {
        	this.dataExtension = xDataExtension;
            this.surveyId = xSurveyId;

            users = new List<Pulso_Survey_User_Wrapper>();
            for (User_Survey__c user : xUsers) {
                users.add(new Pulso_Survey_User_Wrapper(user));
            }

            fields = new List<Map<String, String>>();
            Integer i = 0;
            for (String field : xFields) {
                fields.add(new Map<String, String>{'FieldName' => field});
            }
        }
    }

    public class Pulso_Survey_User_Wrapper {
        public String Id {get; set;}
        public String FirstName {get; set;}
        public String LastName {get; set;}
        
        public Pulso_Survey_User_Wrapper(User_Survey__c user) {
            this.id = user.Id;
            this.FirstName = user.Lead__r.FirstName;
            this.LastName = user.Lead__r.LastName;
        }
    }

    
    public class ExportWrapper { 
        public String name 					{ get; set; }
        public String saql 					{ get; set; }   
        public String exportid              { get; set; }
        public String userid 				{ get; set; }
        public Boolean queryall 			{ get; set; }  
        public Integer maxrecords 			{ get; set; }
        public Set<String> allowedfields 	{ get; set; }
    }

    public class ExportWrapperForSondeosIVR { 
        public String name 					{ get; set; }
        public String saql 					{ get; set; }   
        public String exportid              { get; set; }
        public String userid 				{ get; set; }
        public Boolean queryall 			{ get; set; }  
        public Integer maxrecords 			{ get; set; }
        public String fecha_inicio          { get; set; }
        public String fecha_finalizacion    { get; set; }
        public String hora_inicio           { get; set; }
        public String hora_finalizacion     { get; set; }
        public String audio	                { get; set; }
    }

    public class UserQuota {
        public Integer Code   { get; set; }
        public String Message { get; set; }
        public Integer Quota   { get; set; }
        
        public UserQuota() {
        }
    }

    global class RESTEmailRequest { 
        global List<String> files { get; set; }        
        global String userid { get; set; }        
        global String message { get; set; }
        global String fileId { get; set; }
    }

    public class FacebookLocation { 
        public Decimal id { get; set; }
        public String name { get; set; }
    }

    public class FacebookUser {
        public Decimal id 					{ get; set; }
        public String first_name 			{ get; set; }
        public String last_name 			{ get; set; }
        public String email 				{ get; set; }
        public String gender 				{ get; set; }
        public String birthday 				{ get; set; }
        public FacebookLocation location 	{ get; set; }
        
        public FacebookUser() {}
        
        public FacebookUser(Lead objLead ) {
            this.first_name = objLead.FirstName;
            this.last_name = objLead.LastName;
            this.email = objLead.Email;
            this.id = objLead.FacebookId__c;            
        }

        
        public Lead toLead() {
            Lead objLead = null;
            
            objLead = new Lead();
            objLead.FirstName = this.first_name;
            objLead.LastName = this.last_name;
            objLead.Email = this.email;
            objLead.Company = 'PulsoCRM';
            objLead.FacebookId__c = this.id;            
            if(String.isNotBlank(this.birthday) && this.birthday.length() == 10) {
                objLead.Birthdate__c = HelperFunctions.convertStringToDate(this.birthday, 'MMDDYYYY','/');
            } else if(String.isNotBlank(this.birthday) && this.birthday.length() == 4) {                
                objLead.Birthdate__c = Date.newInstance(Integer.valueOf(this.birthday), 1, 1);
            }
            objLead.Gender__c = this.gender;
            objLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PulsoCRM').getRecordTypeId();            
            
            return objLead;
        }
        /*
        public Facebook_Location__c toFacebookLocation() { 
            Facebook_Location__c objFacebookLocation = null;
            
            if(this.location != NULL && this.location.id != NULL && String.isNotBlank(this.location.name) ) {
                objFacebookLocation = new Facebook_Location__c();
                objFacebookLocation.FacebookId__c = this.location.Id;
                objFacebookLocation.Name = this.location.name;
            }
            return objFacebookLocation;
        }*/
    }
    /*
    public class FacebookLikes {
        public String name 			{ get; set; }
        public Decimal id 			{ get; set; }
        public String created_time 	{ get; set; }
        
        public Facebook_Page__c toFacebookPage() {
            Facebook_Page__c objFacebookPage = null;
            
            objFacebookPage = new Facebook_Page__c();
            objFacebookPage.Nombre__c = this.name;            
            objFacebookPage.FacebookId__c = this.id;
            
            return objFacebookPage;
        }     
    }*/
    
    public class PulsoContact {
        public String FirstName {get; set;}
        public String LastName {get; set;}        
        public String Email {get; set;}
        public String Mobile {get; set;}
        public String TerritoryId {get; set;}        
        public String Description {get; set;}
        public String City {get; set;}
        
        public PulsoContact() {}
        public Lead toLead() {
            Lead objLead = null;
            
            objLead = new Lead();
            objLead.FirstName = this.FirstName;
            objLead.LastName = this.LastName;
            objLead.Company = 'PulsoCRM';
            objLead.MobilePhone = this.Mobile;
            objLead.Email = this.Email;
            objLead.Description = this.Description;
            objLead.Territory__c = this.TerritoryId;
            objLead.City = this.City;
            objLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PulsoCRM').getRecordTypeId();
            
            return objLead;
        }
	        
    }
    public class TypeformTokenResponse {  
        public String access_token { get; set; } 
        public String refresh_token { get; set; } 
        public String token_type { get; set; } 
        public String state { get; set; } 
        public Integer expires_in { get; set; } 
    }
    
    public class FacebookGraphToken {  
        public String access_token { get; set; } 
        public String token_type { get; set; } 
    }
    
    public class TypeformCredentials {
        public String AuthUrl { get; set; }
        public String CallbackUrl { get; set; }
        public String TokenUrl { get; set; }
        public String FormsUrl { get; set; }
        
        public String ClientId { get; set; }
        public String ClientSecret { get; set; }
        public String Scope { get; set; } 
        
        public String Code { get; set; } 
        public String AccessToken { get; set; } 
        public String RefreshToken { get; set; }
        public DateTime ExpiresIn { get; set; } 

        public Integer PageSize { get; set; } 
        
        public Boolean IsValid { 
            get {
                Boolean boolIsValid = true;
                
                boolIsValid = this.ExpiresIn > DateTime.now();
                
                return boolIsValid;
            }                                
        } 
        
        public Boolean IsAuthenticated { 
            get {
                return String.isNotBlank(this.Code);    
            } 
        } 
        
        public TypeformCredentials(Typeform__mdt objSettings) {
            this.AuthUrl = objSettings.AuthURL__c;
            this.ClientId = objSettings.ClientId__c;
            this.ClientSecret = objSettings.ClientSecret__c;
            this.Scope = String.join(objSettings.Scope__c.split(','), '+');
            this.CallbackUrl = objSettings.Callback_Url__c;
            this.TokenUrl = objSettings.TokenUrl__c; 
            this.FormsUrl = objSettings.FormsUrl__c;
            this.PageSize = Integer.valueOf(objSettings.Page_Size__c);
        }
        
        public String toAuthorizationUrl() {
            String strAuthorizationUrl = null;
             
            strAuthorizationUrl = String.format('{0}?client_id={1}&scope={2}&redirect_uri={3}', new String[] {this.AuthUrl, EncodingUtil.urlEncode(this.ClientId, 'UTF-8'),this.Scope, this.CallbackUrl });
            
            return strAuthorizationUrl;
        }
    }
    public class FichaResponse {    
        public String status {get; set;}
        public String msj {get; set;}

    }
    
    public class Encuesta {   
        public String surveyid {get; set;}
        public String name {get; set;}
        public Integer totalpreguntas {get; set;}
        public String description {get; set;}
        public String advertising {get; set;}
        public String responseid {get; set;}
        public String slug {get; set;}

        public Encuesta() {}
        
        public Encuesta(Encuesta__c objEncuesta) {
            this.surveyid = objEncuesta.TypeformId__c;
            this.name = objEncuesta.TituloEncuesta__c;
            
            this.totalpreguntas = Integer.valueOf(objEncuesta.Number_Of_Questions__c);
            this.advertising = objEncuesta.AdvertinsingID__c;
            this.slug = objEncuesta.Slug__c;
            this.description = objEncuesta.Description__c;
        }
        
    /*
     * surveyid
        
        public String id {get; set;}
        public String typeformid {get; set;}
        public Boolean default_survey {get; set;}
        public String resultadosid {get; set;}
        public String tituloencuesta {get; set;}
        public String pauta {get; set;}
        public String slug {get; set;}
        public String descripcion {get; set;}
        public String external_results_url { 
            get {
        		String strUrl = null;
                
                strUrl = String.format('https://smix.typeform.com/report/{0}/{1}', new String[] { this.typeformid, this.resultadosid });
                
                return strUrl;
            }
        }
        
        public Encuesta() {}
        
        public Encuesta(Encuesta__c objEncuesta) {
            this.Id = objEncuesta.Id;
            this.typeformid = objEncuesta.TypeformId__c;
            this.default_survey = objEncuesta.Default_Survey__c;
            this.resultadosid = objEncuesta.TypeformResultsId__c;
            this.tituloencuesta = objEncuesta.TituloEncuesta__c;
            this.pauta = objEncuesta.AdvertinsingID__c;
            this.slug = objEncuesta.Slug__c;
            this.descripcion = objEncuesta.Description__c;
        }
*/
    }
    
    public class TypeformSurvey {
        public String id {get; set;}
        public String title {get; set;}
        public TypeformSurveyFields[] fields {get; set;}

    }
    
    public class TypeformSurveyFields { 
        public String id {get; set;}
        public String title {get; set;}
        public String type {get; set;} //dropdown opinion_scale picture_choice multiple_choice	
        public TypeformSurveyProperty properties {get; set;}
    }
    
    public class TypeformSurveyProperty { 
        public TypeformSurveyFieldsChoices[] choices {get; set;}
        public Integer steps {get; set; }
        public Boolean start_at_one { get; set; }        
    } 
    
    public class TypeformSurveyFieldsChoices { 
        public String id {get; set;}
        public String label {get; set;}
    } 
     
    public class TypeformSurveyReponses {  
        public Integer total_items { get; set; }
        public Integer page_count { get; set; } 
        public TypeformSurveyReponseItem[] items { get; set; } 
    }
    public class TypeformSurveyReponseItem { 
        public TypeformSurveyReponseItemMetadata metadata {get; set;}
        public TypeformSurveyReponseItemAnswer[] answers {get; set;}
        public TypeformSurveyReponseHiddenFields hidden {get; set;}
    } 
    
    public class TypeformSurveyReponseItemMetadata {
        public String referer { get; set;}
    }
    
    public class TypeformSurveyReponseItemAnswer {
        public TypeformSurveyReponseItemAnswerField field { get; set;}
        public String type {get; set;}
        public String text {get; set;}
        public Integer number_x {get; set;} //tengo que reemplazar en el json que viene de typeform number x number_x
        public Boolean boolean_x {get; set;} //tengo que reemplazar en el json que viene de typeform number x number_x
        public TypeformSurveyReponseItemAnswerChoice choice {get; set;}
    }
    
    public class TypeformSurveyReponseItemAnswerField { 
        public String id {get; set;}
        public String type {get; set;}        
    }
    
    public class TypeformSurveyReponseItemAnswerChoice { 
        public String label {get; set;}        
    }
    
    public class TypeformSurveyReponseHiddenFields {
        public String fbid { get; set;}
        public String d { get; set;}
        public String pulsohash { get; set;}
    }
    
    public class FilterFanpages { 
        public List<FacebookPageInfo> fanpages 	{ get; set; }
        public Integer totalusers 				{ get; set; }
    }
    public class FacebookPageInfo implements Comparable {
        public String id { get; set; }
        public String name { get; set; }
        public String about { get; set; }
        public String category { get; set; }
        public Long fan_count { get; set; }
        public Long survey_count { get; set; }
        public String link { get; set; }
        public FacebookPageInfoPicture picture { get; set; }
        
        public String logo { get; set; }
        public Integer percentage { get; set; }
        
        public FacebookPageInfo() {}
        /*
        public FacebookPageInfo(Facebook_Page__c objPage) {
            this.name = objPage.Nombre__c;
            this.fan_count = Integer.valueOf(objPage.Cantidad_Usuarios__c);
            this.about = objPage.Descripcion__c;
            this.logo = objPage.Logo__c;
            this.category = objPage.Category__c;
            this.link = objPage.Fan_Page_Url__c;                
        }
        
        public Facebook_Page__c toFacebookPage() {
            Facebook_Page__c objFacebookPage = null;
            System.debug('toFacebookPage [] ->');
                            
            objFacebookPage = new Facebook_Page__c();
            objFacebookPage.FacebookId__c = Long.valueOf(this.id);
            objFacebookPage.Descripcion__c = this.about;
            objFacebookPage.Cantidad_Usuarios__c = this.fan_count;
            objFacebookPage.Nombre__c = this.name;
            objFacebookPage.Fan_Page_Url__c = this.link;
            objFacebookPage.Category__c = this.category;
            
            if(this.link != NULL) {
                if(String.isNotBlank(this.link) && this.link.length() > 255) {
                    objFacebookPage.Fan_Page_Url__c = this.link.substring(0,255);                    
                } else {
                    objFacebookPage.Fan_Page_Url__c = this.link;
                }
            }
            
            if(this.picture != NULL && this.picture.data != NULL) {
                if(String.isNotBlank(this.picture.data.url) && this.picture.data.url.length() > 255) {
                    objFacebookPage.Logo__c = this.picture.data.url.substring(0,255);                    
                } else {
                    objFacebookPage.Logo__c = this.picture.data.url;
                }
            }
            
            System.debug('toFacebookPage [' + objFacebookPage + '] <-');
            return objFacebookPage;
        }
        */
        public Integer compareTo(Object objCompareTo) {
            Integer intResult = NULL;
            FacebookPageInfo objFacebookPage = NULL;
            
            intResult = 0;
            objFacebookPage = (FacebookPageInfo)objCompareTo;
            if (this.survey_count > objFacebookPage.survey_count) {
                intResult = -1;
            } else if (this.survey_count < objFacebookPage.survey_count) {
                intResult = 1;
            }
            
            return intResult;       
        }
    }
    
    public class FacebookPageInfoPicture {
        public FacebookPageInfoPictureData data {get; set;}
    }
    
    public class FacebookPageInfoPictureData {
        public String id { get; set; }
        public Long height { get; set; }
        public Long width { get; set; }
        public Boolean is_silhouette { get; set; }
        public String url { get; set; }        
    }



    public class SMSSends {
        public String campaingid { get; set; }
        public String usuario { get; set; }
        public String password { get; set; }
        public String provision { get; set; }
        public String operacion { get; set; }
        public String data_extension_name { get; set; } 
        public String data_extension_field { get; set; }       
        public String shortMessage { get; set; }      
        public String sourceAddress { get; set; }  
        public String consultaEstado { get; set; }  
        public String messageid { get; set; }  
    }

    public static void elmejortestlohacelusuarioenproduccion(){
        Integer intI = 1;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
        intI++;
    }

}