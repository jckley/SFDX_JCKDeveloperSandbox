@RestResource(urlMapping='/email/*')
global without sharing class EmailRESTInterface {
    @HttpPost 
    global static void sendNotification(RemotingMessageHelper.RESTEmailRequest objEmailRequest) {
        List<User> lstUsers = null;

        System.debug('sendNotification [ objEmailRequest : ' + objEmailRequest + ' ] -> ');
        System.debug('sendNotification [ objEmailRequest [JSON] : ' + JSON.serialize(objEmailRequest) + ']');

        if(objEmailRequest != NULL && String.isNotBlank(objEmailRequest.userid) && String.isNotBlank(objEmailRequest.message)) {
            lstUsers = [SELECT Id, FirstName, Email FROM User WHERE Id =: String.escapeSingleQuotes(objEmailRequest.userid)];
            if(!lstUsers.isEmpty()) {
                System.debug('sendNotification [ objEmailRequest.fileId: ' + objEmailRequest.fileId + ']');
                System.debug('sendNotification [ objEmailRequest.files: ' + objEmailRequest.files + ']');
				
                if (objEmailRequest.files != null || String.isNotBlank(objEmailRequest.fileId)) {
                    List<String> lstFilesIds = null;
                    lstFilesIds =  new List<String>();  
                    if(objEmailRequest.files != null && !objEmailRequest.files.IsEmpty()) {
                        lstFilesIds.addAll(objEmailRequest.files);
                    } 
                    if(String.isNotBlank(objEmailRequest.fileId)){
                        lstFilesIds.add(objEmailRequest.fileId);
                    }
                        
                    if (!lstFilesIds.isEmpty()) {
                        List<Attachment> lstcsvfiles = new List<Attachment>();
                        
                        lstcsvfiles = [SELECT Id, Body, BodyLength, Name FROM Attachment WHERE Id IN :lstFilesIds];
    
                        System.debug('sendNotification [ lstcsvfiles : ' + lstcsvfiles + ' ]');
                        for (Attachment csvfile : lstcsvfiles) {
                            System.debug('sendNotification [ csvfile : ' + csvfile.Name + ' ]');
                        }
                        
                        if(!lstcsvfiles.isEmpty()) {
                            Double dblAttachmentSize = 0.0;
                            for (Attachment objAttachment : lstcsvfiles) {
                                dblAttachmentSize += objAttachment.BodyLength / (1024 * 1024);
                                objAttachment.Name = String.format('{0}_{1}', new String[] {String.valueOf(Datetime.now()), objAttachment.Name});
                            }
    
                            if(dblAttachmentSize < 14.0) {
                                System.debug('Attachment file with size lesser than 14Mb');
                                objEmailRequest.message = String.format('Estimado {0}, <br /> <br /> Adjuntamos el reporte solicitado.<br /> <br /> Saludos<br />Reportes Prosumia<br />', new String[] {lstUsers[0].FirstName});
                                //HelperFunctions.sendEmail(lstUsers[0].Email, 'Prosumia Notification', objEmailRequest.message, objAttachment.Name, 'application/zip', objAttachment.Body);
                                HelperFunctions.sendEmail(lstUsers[0].Email, 'Prosumia Notification', objEmailRequest.message, lstcsvfiles, 'application/zip');
                            } else {
                                System.debug('Attachment file with size larger than 14Mb');
                                objEmailRequest.message = String.format('Estimado {0}, <br /> <br /> Su reporte es disponible para descargar <a href="{1}">aquí</a>.<br /> <br /> Saludos<br />Reportes Prosumia<br />', new String[] {lstUsers[0].FirstName, URL.getSalesforceBaseUrl().toExternalForm() + '/' + objEmailRequest.files[0]});
                                HelperFunctions.sendEmail(lstUsers[0].Email , 'Prosumia Notification', objEmailRequest.message);
                            }
                        } else {
                            HelperFunctions.sendEmail(lstUsers[0].Email , 'Prosumia Notification', objEmailRequest.message);
                        }
    
                    } else {
                        HelperFunctions.sendEmail(lstUsers[0].Email , 'Prosumia Notification', objEmailRequest.message);
                    }
                } else {
                    HelperFunctions.sendEmail(lstUsers[0].Email , 'Prosumia Notification', objEmailRequest.message);
                }
            } else {
                System.debug('sendNotification [ Email : NO EMAIL FOUND ]');    
            }            
        } else {
            System.debug('sendNotification [ INCOMPLETE REQUEST ]');            
        }
        
        System.debug('sendNotification [] <-');
    }
}