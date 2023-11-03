@RestResource(urlMapping='/pilar/rest/*')
global with sharing class Pilar_REST {

    public class PilarCuitificacion extends RemotingMessageHelper.CuidarnosCuitificacion{
        public String guid { get; set; }
        public String pilar360Id { get; set; }

        public PilarCuitificacion(Contact objContact, String pilar360Id) {
            super(objContact);
            this.guid = objContact.guid__c;
            this.pilar360Id = pilar360Id;
        }
    }

    @HttpGet 
    global static void cuitificar() {
        PilarCuitificacion objResponse = null;
        RemotingMessageHelper.CountRecordsRespose objResponseError = null;
        RestRequest objRESTRequest = null;
        RestResponse objRESTResponse = null;
        List<Contact> lstContacts = null;
        List<String> lstString = null;
        String strUrl = null;
        String strDocumentNumber = null;
        String strSexo = null;
        
        System.debug('cuitificar [ request : ' + RestContext.request + ' ] -> ');
        
        try  {
            objRESTRequest = RestContext.request;
            objRESTResponse = RestContext.response;   
            objRESTResponse.addHeader('Content-Type', 'application/json');
            strUrl = objRESTRequest.requestURI;
            strSexo = objRESTRequest.params.get('sexo');
            
            System.debug('cuitificar [ strSexo : ' + strSexo + ' ]');

            if(String.isNotBlank(strSexo) && strSexo.toLowerCase() != 'm' && strSexo.toLowerCase() != 'f') {
                strSexo = '';
                System.debug('cuitificar [sexo was emptied]');
            }

            if(strUrl.endsWith('/')) {
                strUrl = strUrl.removeEnd('/');
            } 
            lstString = strUrl.split('/');
            strDocumentNumber = lstString[lstString.size() - 1];

            if(String.isNotBlank(strDocumentNumber)) {
                if(String.isBlank(strSexo)) {
                    System.debug('cuitificar [ querying with null sex]');

                    lstContacts = [ SELECT Id, Gender__c, covid19_predictiva_score__c, BirthDate, FirstName, MiddleName, LastName,
                                           MailingStreet, MailingNumber__c, MailingAppartment__c, Administrative_Level_1__c, 
                                           Administrative_Level_2__c, Administrative_Level_3__c, Administrative_Level_4__c,
                                           guid__c 
                                    FROM Contact 
                                    WHERE Document_Number__c =: strDocumentNumber];                                     
                } else {
                    System.debug('cuitificar [ querying with sex]');

                    lstContacts = [ SELECT Id, Gender__c, covid19_predictiva_score__c, BirthDate, FirstName, MiddleName, 
                                           LastName, MailingStreet, MailingNumber__c, MailingAppartment__c, Administrative_Level_1__c, 
                                           Administrative_Level_2__c, Administrative_Level_3__c, Administrative_Level_4__c,
                                           guid__c
                                    FROM Contact 
                                    WHERE Document_Number__c =: strDocumentNumber
                                    AND Gender__c =: strSexo];
                }

                if(!lstContacts.isEmpty()) {
                    Contact contact = lstContacts[0];
                    String pilar360Id;

                    List <Pilar360__c> lstPilar360 = [SELECT Id, Name FROM Pilar360__c WHERE Citizen__c = :contact.Id ORDER BY CreatedDate DESC LIMIT 1];
                    if (lstPilar360.isEmpty()) {
                        try {
                            Pilar360__c Pilar360 = new Pilar360__c();
                            Pilar360.Citizen__c = contact.Id;
                            Pilar360.guid__c = contact.guid__c;
    
                            System.debug('upserting Pilar360 record for ' + Pilar360.Citizen__c);
                            System.debug('guid = ' + contact.guid__c);
    
                            upsert Pilar360;
                            pilar360Id = Pilar360.Id;
                        } catch (Exception e) {}
                    } else {
                        pilar360Id = lstPilar360[0].Id;
                    }
                    System.debug(pilar360Id);

                    objResponse = new PilarCuitificacion(contact, pilar360Id);

                    objRESTResponse.statusCode = 200;
                    objRESTResponse.responseBody = Blob.valueOf(JSON.serialize(objResponse));    
                } else {
                    objResponseError = new RemotingMessageHelper.CountRecordsRespose();
                    objResponseError.code = 100;
                    objResponseError.message = 'No se han encontrado resultados';

                    objRESTResponse.statusCode = 400; 
                    objRESTResponse.responseBody = Blob.valueOf(JSON.serialize(objResponseError));   
                }
            } else {                
                objResponseError = new RemotingMessageHelper.CountRecordsRespose();
                objResponseError.code = 110;
                objResponseError.message = Label.API_Invalid_Request;

                objRESTResponse.statusCode = 400; 
                objRESTResponse.responseBody = Blob.valueOf(JSON.serialize(objResponseError));   
        
            }
        } catch(Exception Ex) {
            objResponseError = new RemotingMessageHelper.CountRecordsRespose();
            objResponseError.code = 999;
            objResponseError.message = Label.API_Invalid_Request;

            objRESTResponse.statusCode = 500; 
            objRESTResponse.responseBody = Blob.valueOf(JSON.serialize(objResponseError));
        }
        
        System.debug('retrieveCUIT [ statusCode : ' + objRESTResponse.statusCode + ' ]');
        System.debug('retrieveCUIT [ responseBody : ' + objRESTResponse.responseBody + ' ]');
        System.debug('retrieveCUIT [] <- ');
    }
}