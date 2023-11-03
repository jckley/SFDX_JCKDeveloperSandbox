@isTest
public class CommonTestFunctions {
    public static void commonSetup() {
        Account objAccount = null;
        Territorio_Administrativo__c objTerritory0 = null;
        Territorio_Administrativo__c objTerritory1 = null;
        Territorio_Administrativo__c objTerritory2 = null;
        Territorio_Administrativo__c objTerritory3 = null;
        Territorio_Administrativo__c objTerritory4 = null;
        List<Contact> lstContacts = null;
        
        objAccount = CommonTestFunctions.createAccount('Prosumia');
        objTerritory0 = CommonTestFunctions.createTerritorioAdministrativo('Argentina', NULL, 0);
        objTerritory1 = CommonTestFunctions.createTerritorioAdministrativo('Level 1', objTerritory0, 1);
        objTerritory2 = CommonTestFunctions.createTerritorioAdministrativo('Level 2', objTerritory1, 2);
        objTerritory3 = CommonTestFunctions.createTerritorioAdministrativo('Level 3', objTerritory2, 3);
        objTerritory4 = CommonTestFunctions.createTerritorioAdministrativo('Level 4', objTerritory3, 4);
        
        lstContacts = CommonTestFunctions.createCitizens(10, objAccount, objTerritory4);
    }

    public static void commonChileSetup() {
        Account objAccount = null;
        Territorio_Administrativo__c objTerritory0 = null;
        Territorio_Administrativo__c objTerritory1 = null;
        Territorio_Administrativo__c objTerritory2 = null;
        Territorio_Administrativo__c objTerritory3 = null;
        Territorio_Administrativo__c objTerritory4 = null;
        List<Contact> lstContacts = null;
        
        objAccount = CommonTestFunctions.createAccount('Prosumia');
        objTerritory0 = CommonTestFunctions.createTerritorioAdministrativo('Chile', NULL, 0);
        objTerritory1 = CommonTestFunctions.createTerritorioAdministrativo('Level 1', objTerritory0, 1);
        objTerritory2 = CommonTestFunctions.createTerritorioAdministrativo('Level 2', objTerritory1, 2);
        objTerritory3 = CommonTestFunctions.createTerritorioAdministrativo('Level 3', objTerritory2, 3);
        objTerritory4 = CommonTestFunctions.createTerritorioAdministrativo('Level 4', objTerritory3, 4);
        
        lstContacts = CommonTestFunctions.createChileCitizens(10, objAccount, objTerritory4);
    }
    
    public static Account createAccount(String strName) {
        Account objAccount = null;
        
        objAccount = new Account();
        objAccount.Name = strName;
        insert objAccount;
        
        return objAccount;
    }
    
    public static List<Contact> createCitizens(Integer intCount, Account objAccount, Territorio_Administrativo__c objTerritory) {
        List<Contact> lstContacts = null;
        Contact objContact = null;
        lstContacts = new List<Contact>();
        
        for(Integer intIndex = 0; intIndex < intCount; intIndex++) {
            objContact = createCitizen(String.format('FirstName {0}', new String[]{ String.valueOf(intIndex)  }),String.format('LastName {0}', new String[]{ String.valueOf(intIndex) }), objAccount, objTerritory );
            lstContacts.add(objContact);
        }
        
        insert lstContacts;
        
        return lstContacts;
    }
    
    public static Contact retrieveContact() {
        Contact objContact = null;
        
        objContact = [SELECT Id, AccountId, FirstName, LastName, Administrative_Level_0__c, Administrative_Level_1__c, Administrative_Level_2__c, Administrative_Level_3__c, Administrative_Level_4__c, Territorio_Administrativo__c, ADFi_Profile_ID__c, Alerta_Buenos_Aires_ID__c, UUID__c, Cuil_Number__c, PhotoUrl_legacy__c, GUID__c
                      FROM Contact
                      LIMIT 1];
        
        return objContact;
    }
    
    private static Contact createCitizen(String strFirstName, String strLastName, Account objAccount, Territorio_Administrativo__c objTerritory) {
        Contact objContact = null;
        
        objContact = new Contact();
        objContact.AccountId = objAccount.Id;
        objContact.FirstName = strFirstName;
        objContact.LastName = strLastName;
        objContact.Administrative_Level_0__c = objTerritory.Level0Name__c;
        objContact.Administrative_Level_1__c = objTerritory.Level1Name__c;
        objContact.Administrative_Level_2__c = objTerritory.Level2Name__c;
        objContact.Administrative_Level_3__c = objTerritory.Level3Name__c;
        objContact.Administrative_Level_4__c = objTerritory.Level4Name__c;
        objContact.Nacionalidad__c = ((Math.random() * 10).intValue() < 5)?'Argentino':'Argentina';
        objContact.Gender__c = ((Math.random() * 10).intValue() < 5)?'M':'F';
        objContact.Territorio_Administrativo__c = objTerritory.Id;        
        objContact.ADFi_Profile_ID__c = Crypto.getRandomInteger();
        objContact.Alerta_Buenos_Aires_ID__c = Crypto.getRandomInteger();
        objContact.UUID__c = generateRandomString(20);
        objContact.GUID__c = generateRandomString(10);
        objContact.Cuil_Number__c = generateRandomString(13);
        objContact.PhotoUrl_legacy__c = 'foto'; //para que connected people devuelva datos
        
        objContact.MailingStreet = 'CALLE';
        objContact.MailingNumber__c = '1222';
        objContact.MailingAppartment__c = 'V';
        objContact.MailingPostalCode = '1111';
        objContact.MailingLatitude = -54.55555;
        objContact.MailingLongitude = -34.0000;
        objContact.BirthDate = Date.newInstance(1999, 15, 10);
        objContact.CUIT_Empleador_1__c = generateRandomString(13);
        objContact.CUIT_Empleador_2__c = generateRandomString(13);
        objContact.CUIT_Empleador_3__c = generateRandomString(13);

        objContact.Movilidad__c = 'Auto';
        objContact.movilidad_desc__c = 'Descripcion del vehículo';
        objContact.movilidad_patente__c = 'ABC123';
        
        objContact.RecordTypeId = [SELECT Id 
                                   FROM RecordType 
                                   WHERE sObjectType = 'Contact' 
                                   AND DeveloperName = 'Argentino' 
                                   LIMIT 1].Id;
        

        objContact.covid_vacc_1st_dose__c = Date.today();
        objContact.covid_vacc_desc__c = 'vacuna1';

        return objContact;
    }
    
    public static Territorio_Administrativo__c createTerritorioAdministrativo(String strName, Territorio_Administrativo__c objParent, Integer intLevel) {
        Territorio_Administrativo__c objTerritory = null;
        Integer intTotal = NULL;
        
        objTerritory = new Territorio_Administrativo__c();
        
        objTerritory.Name = strName;
        objTerritory.Location_UUID__c = generateRandomString(10);
        objTerritory.Nivel_Administrativo__c = intLevel;
        
        objTerritory.Total_de_Hombres_de_0_a_15__c = (Math.random() * 10000).intValue();
        intTotal = objTerritory.Total_de_Hombres_de_0_a_15__c.intValue();
        
        objTerritory.Total_de_Hombres_de_16_a_17__c = (Math.random() * 10000).intValue();
        intTotal += objTerritory.Total_de_Hombres_de_16_a_17__c.intValue();
        
        objTerritory.Total_de_Hombres_de_18_a_24__c = (Math.random() * 10000).intValue();
        intTotal += objTerritory.Total_de_Hombres_de_18_a_24__c.intValue();
        
        objTerritory.Total_de_Hombres_de_25_a_39__c = (Math.random() * 10000).intValue();
        intTotal += objTerritory.Total_de_Hombres_de_25_a_39__c.intValue();
        
        objTerritory.Total_de_Hombres_de_40_a_64__c = (Math.random() * 10000).intValue();
        intTotal += objTerritory.Total_de_Hombres_de_40_a_64__c.intValue();
        
        objTerritory.Total_Hombres_de_65plus__c = (Math.random() * 10000).intValue();
        intTotal += objTerritory.Total_Hombres_de_65plus__c.intValue();
        
        objTerritory.Total_Mujeres_de_0_a_15__c = (Math.random() * 10000).intValue();
        intTotal += objTerritory.Total_Mujeres_de_0_a_15__c.intValue();
        
        objTerritory.Total_Mujeres_de_16_a_17__c = (Math.random() * 10000).intValue();
        intTotal += objTerritory.Total_Mujeres_de_16_a_17__c.intValue();
        
        objTerritory.Total_Mujeres_de_18_a_24__c = (Math.random() * 10000).intValue();
        intTotal += objTerritory.Total_Mujeres_de_18_a_24__c.intValue();
        
        objTerritory.Total_Mujeres_de_25_a_39__c = (Math.random() * 10000).intValue();
        intTotal += objTerritory.Total_Mujeres_de_25_a_39__c.intValue();
        
        objTerritory.Total_Mujeres_de_40_a_64__c = (Math.random() * 10000).intValue();
        intTotal += objTerritory.Total_Mujeres_de_40_a_64__c.intValue();
        
        objTerritory.Total_Mujeres_de_65plus__c = (Math.random() * 10000).intValue();
        intTotal += objTerritory.Total_Mujeres_de_65plus__c.intValue();
        
        objTerritory.Total_Ciudadanos__c = intTotal;
        
        /*
List<String> ageRangeMaleInfo =   new List<String>{'Etario_Sub_16_Male__c',   'Etario_Centennials_Male__c',   'Etario_Millennials_Male__c',   'Etario_Generacion_X_Male__c',    'Etario_Baby_Boomers_Male__c', 'Etario_Generacion_Silenciosa_Male__c'  };
List<String> ageRangeFemaleInfo = new List<String>{'Etario_Sub_16_Female__c', 'Etario_Centennials_Female__c', 'Etario_Millennials_Female__c', 'Etario_Generacion_X_Female__c', 'Etario_Baby_Boomers_Female__c', 'Etario_Generacion_Silenciosa_Female__c' };
*/
        
        objTerritory.Etario_Baby_Boomers_Female__c = 10;
        objTerritory.Etario_Baby_Boomers_Male__c = 10;
        objTerritory.Etario_Baby_Boomers_Total__c = 20;
        objTerritory.Etario_Centennials_Female__c = 10;
        objTerritory.Etario_Centennials_Male__c = 20;
        objTerritory.Etario_Centennials_Total__c = 30;
        objTerritory.Etario_Generacion_Silenciosa_Female__c = 10;
        objTerritory.Etario_Generacion_Silenciosa_Male__c = 10;
        objTerritory.Etario_Generacion_Silenciosa_Total__c = 20;
        objTerritory.Etario_Generacion_X_Female__c = 10;
        objTerritory.Etario_Generacion_X_Male__c = 10;
        objTerritory.Etario_Generacion_X_Total__c = 10;
        objTerritory.Etario_Millennials_Female__c = 10;
        objTerritory.Etario_Millennials_Male__c = 20;
        objTerritory.Etario_Millennials_Total__c = 30;
        objTerritory.Etario_Sub_16_Female__c = 30;
        objTerritory.Etario_Sub_16_Male__c = 20;
        objTerritory.Etario_Sub_16_Total__c = 50;
                
        objTerritory.Total_Emails__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Moviles__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Telefonos_FIjos__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Facebook__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Instagram__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Linkedin__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Twitter__c = (Math.random() * intTotal).intValue();
        
        objTerritory.Total_Education_Level_Primary__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Education_Level_Secondary__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Education_Level_Tertiary__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Education_Level_University_Degree__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Occupation_Type_Self_Employed__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Occupation_Type_Wage_Earned__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Occupation_Type_Retired__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Occupation_Type_Not_Declared__c = (Math.random() * intTotal).intValue();
        
        objTerritory.Total_Income_Range_High__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Income_Range_Medium__c = (Math.random() * intTotal).intValue();
        objTerritory.Total_Income_Range_Low__c = (Math.random() * intTotal).intValue();
        
        objTerritory.Total_Economic_Activities__c = 'prueba,1';
        
        if(objParent != NULL && objParent.Id != NULL) {
            objTerritory.ParentId__c = objParent.Id;            
        }
        
        insert objTerritory;
        
        return objTerritory;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    public void createNewSurveyForTest() {
		Integer NewUsers = 5;
        Integer NewQuestions = 5;
        Integer NumberOfOptions = NewUsers;
        
        //Create a New Lead / User
        List<Lead> leads = new List<Lead>();
        for (Integer l = 0 ; l < NewUsers ; l++) {
            Lead lead = new Lead();
            lead.FirstName = 'Test Lead First Name ' + (l+1);
            lead.LastName = 'Test Lead Last Name ' + (l+1);
            lead.Company = 'Test Lead Company ' + (l+1);
            lead.RecordTypeId = [Select Id from RecordType where DeveloperName = 'PulsoCRM'].Id;
            leads.add(lead);
        }
        insert leads;
        
		//Create a New Survey
        Encuesta__c encuesta = new Encuesta__c();
        encuesta.TituloEncuesta__c = 'titulo de la encuesta';
        encuesta.Description__c = 'Encuesta de Test';
        encuesta.Slug__c = 'Encuesta_1';
        encuesta.TypeformId__c = '101';
        encuesta.TypeformResultsId__c = '102';
        insert encuesta;

        List<User_Survey__c> users = new List<User_Survey__c>();
        for (Integer i = 0 ; i < NewUsers ; i++) {
            //Create New User Survey (Answering User)
            User_Survey__c user = new User_Survey__c();
            user.Lead__c = leads[i].Id;
            user.Survey__c = encuesta.Id;
            user.ExternalId__c = 'test' + (i+1);
            users.add(user);
        }
        insert users;
        
        for (Integer quest = 0 ; quest < NewQuestions ; quest++) {
            //Create A New Question
            Survey_Question__c question = new Survey_Question__c();
            question.Title__c = 'Pregunta ' + (quest + 1);
            question.Survey__c = encuesta.Id;
            insert question;
            
            for (Integer j = 0 ; j < NumberOfOptions ; j++) {
                //Create New Question's Options
                Survey_Available_Option__c option = new Survey_Available_Option__c();
                option.Survey_Option__c = 'Opcion ' + j;
                option.Index__c = j+1;
                option.Survey_Question__c = question.Id;
                insert option;
                
                //Create New Answers
                if (j < NewUsers) {
                    User_Survey_Answers__c answer = new User_Survey_Answers__c();
                    answer.Survey_Available_Option__c = option.Id;
                    answer.User_Survey__c = users[j].Id;
                    insert answer;
                }
            }

        }
    }

    // Chile
    public static List<Contact> createChileCitizens(Integer intCount, Account objAccount, Territorio_Administrativo__c objTerritory) {
        List<Contact> lstContacts = null;
        Contact objContact = null;
        lstContacts = new List<Contact>();
        
        for(Integer intIndex = 0; intIndex < intCount; intIndex++) {
            objContact = createChileCitizen(String.format('FirstName {0}', new String[]{ String.valueOf(intIndex)  }),String.format('LastName {0}', new String[]{ String.valueOf(intIndex) }), objAccount, objTerritory );
            lstContacts.add(objContact);
        }
        
        insert lstContacts;
        
        return lstContacts;
    }

    private static Contact createChileCitizen(String strFirstName, String strLastName, Account objAccount, Territorio_Administrativo__c objTerritory) {
        Contact objContact = null;
        
        objContact = new Contact();
        objContact.AccountId = objAccount.Id;
        objContact.FirstName = strFirstName;
        objContact.LastName = strLastName;
        objContact.Administrative_Level_0__c = objTerritory.Level0Name__c;
        objContact.Administrative_Level_1__c = objTerritory.Level1Name__c;
        objContact.Administrative_Level_2__c = objTerritory.Level2Name__c;
        objContact.Administrative_Level_3__c = objTerritory.Level3Name__c;
        objContact.Administrative_Level_4__c = objTerritory.Level4Name__c;
        objContact.Nacionalidad__c = ((Math.random() * 10).intValue() < 5)?'Chileno':'Chilena';
        objContact.Gender__c = ((Math.random() * 10).intValue() < 5)?'M':'F';
        objContact.Territorio_Administrativo__c = objTerritory.Id;        
        objContact.ADFi_Profile_ID__c = Crypto.getRandomInteger();
        objContact.Alerta_Buenos_Aires_ID__c = Crypto.getRandomInteger();
        objContact.UUID__c = generateRandomString(20);
        objContact.GUID__c = generateRandomString(10);
        objContact.Cuil_Number__c = generateRandomString(13);
        objContact.PhotoUrl_legacy__c = 'foto'; //para que connected people devuelva datos
        
        objContact.MailingStreet = 'CALLE';
        objContact.MailingNumber__c = '1222';
        objContact.MailingAppartment__c = 'V';
        objContact.MailingPostalCode = '1111';
        objContact.MailingLatitude = -54.55555;
        objContact.MailingLongitude = -34.0000;
        objContact.BirthDate = Date.newInstance(1999, 15, 10);
        objContact.CUIT_Empleador_1__c = generateRandomString(13);
        objContact.CUIT_Empleador_2__c = generateRandomString(13);
        objContact.CUIT_Empleador_3__c = generateRandomString(13);

        objContact.Movilidad__c = 'Auto';
        objContact.movilidad_desc__c = 'Descripcion del vehículo';
        objContact.movilidad_patente__c = 'ABC123';
        
        objContact.RecordTypeId = [SELECT Id 
                                   FROM RecordType 
                                   WHERE sObjectType = 'Contact' 
                                   AND DeveloperName = 'Chileno' 
                                   LIMIT 1].Id;
        
        return objContact;
    }
    
}