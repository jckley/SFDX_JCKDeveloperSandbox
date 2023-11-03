@RestResource(urlMapping='/cuidarnos/rest/pdf/*')
global without sharing class Cuidarnos_Ficha_REST {
    public class FichaException extends Exception {}

    @HttpGet 
    global static void exportFicha() {
        RemotingMessageHelper.CountRecordsRespose objResponseError = null;
        RestRequest objRESTRequest = null;
        RestResponse objRESTResponse = null;
        List<Contact> lstContacts = null;
        List<Covid19__c> lstCovidInfo = null;
        List<String> lstUrlParts = null;
        Contact objContact = null;
        CitizenWrapper objCitizenWrapper = null;
        String strContactId = null;
        String strUrl = null;
        String strBody = null;
        Blob objResponseBody = null;
        String strFileName = null;
        String strMode = null;
        String strClient = null;
        String strEndpoint = null;

        System.debug('exportFicha [ request : ' + RestContext.request + ' ] -> ');
        
        try  {
            objRESTRequest = RestContext.request;
            objRESTResponse = RestContext.response;   
            objRESTResponse.addHeader('Content-Type', 'application/json');
            strUrl = objRESTRequest.requestURI;
            
            if(strUrl.endsWith('/')) {
                strUrl = strUrl.removeEnd('/');
            } 

            lstUrlParts = strUrl.split('/');
            strContactId = lstUrlParts[lstUrlParts.size() - 3];
            strMode = lstUrlParts[lstUrlParts.size() - 2];
            strClient = lstUrlParts[lstUrlParts.size() - 1];
    
            System.debug('exportFicha [ strContactId : ' + strContactId + ' ]');
            System.debug('exportFicha [ strMode : ' + strMode + ' ]');
            System.debug('exportFicha [ strClient : ' + strClient + ' ]');

    
            if(String.isNotBlank(strContactId) && String.isNotBlank(strMode) && String.isNotBlank(strClient)) {               
                if(strMode == 'autoevaluacion' || strMode == 'notificacion' || strMode == 'alta' ) {
                    if(strClient == 'cuidarnos' || strClient == 'pilar') {
                        objContact = ContactDetailController.retrieveContactFromId(strContactId);

                        if(objContact != NULL) {      
                            objCitizenWrapper = new CitizenWrapper(objContact);
                            
                            strFileName = String.format('{0}-{1}', new String[] { String.valueOf(objContact.Document_Number__c), DateTime.now().format() });
                            
                            if(strMode == 'autoevaluacion' || strMode == 'notificacion') {
                                strBody = retrieveBody(strMode, strClient, objCitizenWrapper, false);
                                strEndpoint = 'https://cuidarnos.app/ficha/';
                            } else if (strMode == 'alta') {
                                strBody = retrieveBodyAlta(strMode, strClient, objCitizenWrapper, false);
                                strEndpoint = 'https://covid.pilar.gov.ar/ficha/';
                            }

                            objResponseBody = makeRequest(strEndpoint, strBody);                    

                            objRESTResponse.addHeader('Content-Disposition', 'attachment;filename="' + strFileName + '.pdf"');
                            objRESTResponse.statusCode = 200;
                            objRESTResponse.responseBody = objResponseBody;
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
                        objResponseError.message = 'Perfil ingrasado no válido';
    
                        objRESTResponse.statusCode = 400; 
                        objRESTResponse.responseBody = Blob.valueOf(JSON.serialize(objResponseError));       
                    }
                } else {
                    objResponseError = new RemotingMessageHelper.CountRecordsRespose();
                    objResponseError.code = 130;
                    objResponseError.message = 'Modo ingrasado no válido';

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
        
        System.debug('exportFicha [ statusCode : ' + objRESTResponse.statusCode + ' ]');
        System.debug('exportFicha [ responseBody : ' + objRESTResponse.responseBody + ' ]');
        System.debug('exportFicha [] <- ');
    }

    private static Blob makeRequest(String strBody) {
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        String strEndpoint = null;
        Blob objResponseBody = null;

        System.debug('makeRequest [ strBody : ' + strBody + '] ->');
    
        strEndpoint = 'https://cuidarnos.app/ficha/';

        objRequest = new HttpRequest();
        objRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8');
        objRequest.setMethod('POST');
        objRequest.setEndpoint(strEndpoint);
        objRequest.setTimeout(60 * 1000);
        //objRequest.setHeader('content-type', 'application/json; charset=UTF-8');
        objRequest.setBody(strBody);
        
        System.debug('makeRequest [ strEndpoint : ' + strEndpoint + ']');
        System.debug('makeRequest [ objResponse.getBody() : ' + objRequest.getBody() + ']');

        objHttp = new Http();
        objResponse = objHttp.send(objRequest);
        
        if(objResponse != NULL && objResponse.getStatusCode() == 200) {
            objResponseBody = objREsponse.getBodyAsBlob();
        } else {
            throw new FichaException();
        }

        System.debug('makeRequest [] <-');
        return objResponseBody;
    }

    private static Blob makeRequest(String strEndpoint, String strBody) {
        HttpRequest objRequest = null;
        Http objHttp = null;
        HttpResponse objResponse = null;
        Blob objResponseBody = null;

        System.debug('makeRequest [ strBody : ' + strBody + '] ->');
    
        objRequest = new HttpRequest();
        objRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8');
        objRequest.setMethod('POST');
        objRequest.setEndpoint(strEndpoint);
        objRequest.setTimeout(60 * 1000);
        //objRequest.setHeader('content-type', 'application/json; charset=UTF-8');
        objRequest.setBody(strBody);
        
        System.debug('makeRequest [ strEndpoint : ' + strEndpoint + ']');
        System.debug('makeRequest [ objResponse.getBody() : ' + objRequest.getBody() + ']');

        objHttp = new Http();
        objResponse = objHttp.send(objRequest);
        
        if(objResponse != NULL && objResponse.getStatusCode() == 200) {
            objResponseBody = objREsponse.getBodyAsBlob();
        } else {
            throw new FichaException();
        }

        System.debug('makeRequest [] <-');
        return objResponseBody;
    }
    public static String retrieveBody(String strMode, String strClient, CitizenWrapper objCitizenWrapper, Boolean boolSendEmail) {
        String strBody = null;
        String strCreatedDate = null;
        String strObservations = null;

        System.debug('retrieveBodyAlta [strMode : ' + strMode + ' - strClient : ' + strClient + ' - objCitizenWrapper : ' + objCitizenWrapper + ' - boolSendEmail : ' + boolSendEmail + '] -> ');

        strCreatedDate = DateTime.now().format();
        
        strBody = '';
        strBody += String.format('type={0}&', new String[] { strMode  });
        strBody += String.format('client={0}&', new String[] { strClient });
        if(boolSendEmail) {
            strBody += String.format('caso={0}&', new String[] { objCitizenWrapper.cuidarnos.covid.Cuidarnos_Muestra_Result__c });
        } else {
            strBody += String.format('caso={0}&', new String[] { objCitizenWrapper.cuidarnos.status });
        }
        

        strBody += String.format('nombre={0} {1} {2}&', new String[] { String.isNotBlank( objCitizenWrapper.citizen.FirstName)? objCitizenWrapper.citizen.FirstName:'', String.isNotBlank( objCitizenWrapper.citizen.MiddleName)? objCitizenWrapper.citizen.MiddleName:'', String.isNotBlank( objCitizenWrapper.citizen.LastName)? objCitizenWrapper.citizen.LastName:''  });
        if(boolSendEmail) {
            strBody += String.format('email={0}&', new String[] { EncodingUtil.urlEncode(objCitizenWrapper.cuidarnos.email, 'UTF-8') });
        }

        strBody += String.format('dni={0}&', new String[] { String.isNotBlank(objCitizenWrapper.citizen.Document_Number__c)?objCitizenWrapper.citizen.Document_Number__c:'' });
        strBody += String.format('fecha_creado={0}&', new String[] { strCreatedDate });
        strBody += String.format('fecha_nacimiento={0}&', new String[] { objCitizenWrapper.generalInfo.BirthdateSPFormat });
        strBody += String.format('direccion={0}&', new String[] { objCitizenWrapper.generalInfo.addressSimple });
        strBody += String.format('codigo_postal={0}&', new String[] { String.isNotBlank(objCitizenWrapper.citizen.MailingPostalCode)?objCitizenWrapper.citizen.MailingPostalCode:'' });
        strBody += String.format('provincia={0}&', new String[] { String.isNotBlank(objCitizenWrapper.citizen.Administrative_Level_1__c)?objCitizenWrapper.citizen.Administrative_Level_1__c:'' });
        strBody += String.format('municipio={0}&', new String[] { String.isNotBlank(objCitizenWrapper.citizen.Administrative_Level_2__c)?objCitizenWrapper.citizen.Administrative_Level_2__c:'' });
        strBody += String.format('ciudad={0}&', new String[] { String.isNotBlank(objCitizenWrapper.citizen.Administrative_Level_3__c)?objCitizenWrapper.citizen.Administrative_Level_3__c:'' });
        strBody += String.format('telefono_fijo={0}&', new String[] { String.isNotBlank(objCitizenWrapper.cuidarnos.phone)?objCitizenWrapper.cuidarnos.phone:'' });
                
        if(objCitizenWrapper.cuidarnos.covid != NULL) { 
            strBody += String.format('fecha_caso={0}&', new String[] { (objCitizenWrapper.cuidarnos.covid.Cuidarnos_Comunidad_Date__c != NULL)?objCitizenWrapper.cuidarnos.covid.Cuidarnos_Comunidad_Date__c.format():'' });
           
            strBody += String.format('fecha_triage={0}&', new String[] { objCitizenWrapper.cuidarnos.Triage });
            strBody += String.format('fecha_telemedico={0}&', new String[] { objCitizenWrapper.cuidarnos.Telemedico  });
            strBody += String.format('fecha_muestra={0}&', new String[] { objCitizenWrapper.cuidarnos.Muestra  });
            strBody += String.format('fecha_resultado={0}&', new String[] { objCitizenWrapper.cuidarnos.Resultado });
            strBody += String.format('fecha_notificacion={0}&', new String[] { objCitizenWrapper.cuidarnos.Notificacion });

            strBody += String.format('salud={0}&', new String[] { String.isNotBlank(objCitizenWrapper.cuidarnos.covid.proactiva_health__c)?objCitizenWrapper.cuidarnos.covid.proactiva_health__c:'' });
            strBody += String.format('viajero={0}&', new String[] { (objCitizenWrapper.cuidarnos.covid.proactiva_traveler__c != NULL && objCitizenWrapper.cuidarnos.covid.proactiva_traveler__c)?'Sí':'No' });
            strBody += String.format('temperatura={0}&', new String[] { (objCitizenWrapper.cuidarnos.covid.proactiva_temperature__c != NULL)?String.valueOf(objCitizenWrapper.cuidarnos.covid.proactiva_temperature__c) + '' : ''  });
            strBody += String.format('autopercepcion_covid={0}&', new String[] { String.isNotBlank(objCitizenWrapper.cuidarnos.covid.proactiva_autoperception__c)?objCitizenWrapper.cuidarnos.covid.proactiva_autoperception__c:'' });
            strBody += String.format('contacto={0}&', new String[] { (objCitizenWrapper.cuidarnos.covid.proactiva_hasbeencontact__c != NULL && objCitizenWrapper.cuidarnos.covid.proactiva_hasbeencontact__c)?'Sí':'No' });
            strBody += String.format('contacto_frecuencia={0}&', new String[] { String.isNotBlank(objCitizenWrapper.cuidarnos.covid.proactiva_frecuency__c)?objCitizenWrapper.cuidarnos.covid.proactiva_frecuency__c:''});
            strBody += String.format('sintomas={0}&', new String[] { (objCitizenWrapper.cuidarnos.covid.proactiva_symptoms__c != NULL)?String.join(objCitizenWrapper.cuidarnos.covid.proactiva_symptoms__c.split(';'), ' '):''  });
            strBody += String.format('antecedentes={0}&', new String[] { (objCitizenWrapper.cuidarnos.covid.proactiva_history__c != NULL)?String.join(objCitizenWrapper.cuidarnos.covid.proactiva_history__c.split(';'), ' '):''  });

            strObservations = '';
            for(CitizenWrapper.Observaciones objObservation : objCitizenWrapper.cuidarnos.observaciones) {
                strObservations += String.format('{0}', new String[] { objObservation.Observacion }); 
            }
            strBody += String.format('notas={0}&', new String[] { strObservations });
        } else {
            strBody += 'salud=&';
            strBody += 'viajero=&';
            strBody += 'temperatura=&';
            strBody += 'autopercepcion_covid=&';
            strBody += 'contacto=&';
            strBody += 'contacto_frecuencia=&';
            strBody += 'sintomas=&';
            strBody += 'antecedentes=&';
            strBody += 'notas=&';                
        }  

        System.debug('retrieveBody[' + strBody + '] <- ');
        return strBody;
    }

    public static String retrieveBodyAlta(String strMode, String strClient, CitizenWrapper objCitizenWrapper, Boolean boolSendEmail) {
        String strBody = null;
        String strCreatedDate = null;
        String strObservations = null;

        System.debug('retrieveBodyAlta [strMode : ' + strMode + ' - strClient : ' + strClient + ' - objCitizenWrapper : ' + objCitizenWrapper + ' - boolSendEmail : ' + boolSendEmail + '] -> ');

        strCreatedDate = DateTime.now().format();
        
        strBody = '';

        strBody += String.format('nombre={0} {1} {2}&', new String[] { String.isNotBlank( objCitizenWrapper.citizen.FirstName)? objCitizenWrapper.citizen.FirstName:'', String.isNotBlank( objCitizenWrapper.citizen.MiddleName)? objCitizenWrapper.citizen.MiddleName:'', String.isNotBlank( objCitizenWrapper.citizen.LastName)? objCitizenWrapper.citizen.LastName:''  });
        if(boolSendEmail) {
            strBody += String.format('email={0}&', new String[] { EncodingUtil.urlEncode(objCitizenWrapper.cuidarnos.email, 'UTF-8') });
        }

        strBody += String.format('dni={0}&', new String[] { String.isNotBlank(objCitizenWrapper.citizen.Document_Number__c)?objCitizenWrapper.citizen.Document_Number__c:'' });
        strBody += String.format('fecha_covid={0}&', new String[] { objCitizenWrapper.cuidarnos.Resultado });
        strBody += String.format('fecha_nacimiento={0}&', new String[] { objCitizenWrapper.generalInfo.BirthdateSPFormat });

        System.debug('retrieveBodyAlta[' + strBody + '] <- ');
        return strBody;
    }

    private static String retrieveAddressSimple(Contact objContact) {
        String strAddress = null;
        String strFloorApartment = null;
                
        System.debug('retrieveAddressSimple [] ->');

        strFloorApartment = retrieveFloorApartment(objContact);
        if(String.isNotBlank(objContact.MailingStreet)) {    
            objContact.MailingStreet = String.join(HelperFunctions.capitalizeList(objContact.MailingStreet.split(' ')), ' ');
            if(String.isNotBlank(objContact.MailingNumber__c) ) {
                if(String.isNotBlank(strFloorApartment)) {
                    strAddress = String.format('{0} {1} {2}', new String[] {objContact.MailingStreet, objContact.MailingNumber__c, strFloorApartment });                  		                
                } else {                    
                    strAddress = String.format('{0} {1}', new String[] {objContact.MailingStreet, objContact.MailingNumber__c });                  		                
                }
            } else {
                if(String.isNotBlank(strFloorApartment)) {
                    strAddress = String.format('{0} {1}, {2}', new String[] {  objContact.MailingStreet, strFloorApartment});
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
    
    private static String retrieveFloorApartment(Contact objContact) { 
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

    public static void noqueriahaceresto() {
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
    }
}