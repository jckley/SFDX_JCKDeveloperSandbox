@RestResource(urlMapping='/file/*')
global class RestExportTEST {
    @HttpGet 
    global static String isAlive() {
        return 'isAlive!';
    }

       
    @HttpPost
    global static Id createFile(String strUserId, String strFilename, String strFileContent, String strContentType) {
    	Id objFileId = null;
        Attachment objAttachment = null;
        
        System.debug('createFile [strUserId : ' + strUserId + ' - strFilename : ' + strFilename + '] ->');
        
        objAttachment = new Attachment();
        objAttachment.ParentId = [SELECT ID FROM Account LIMIT 1].Id;
        objAttachment.Name = strFilename;
        objAttachment.ContentType = strContentType;

        if (strContentType == 'application/zip') {
            objAttachment.Body = EncodingUtil.base64Decode(strFileContent);
        } else if (strContentType == 'text/csv') {
            strFileContent = EncodingUtil.urlDecode(strFileContent, 'UTF-8');
            objAttachment.Body = Blob.valueOf(strFileContent);
        } else {
            System.debug('Error: Content-Type no tipificado');
        }
        
        insert objAttachment;
        
        System.debug('createFile [ ' + objAttachment.Id + '] <-');

        return objAttachment.Id;
    }

    
    @HttpPut
    global static void appendFile(String strFileId, String strCSV) { 
        Attachment objAttachment = null;
        String strExistingBody = null;
        
        System.debug('appendFile [strFileId : ' + strFileId + ' - strCSV : ' + strCSV + '] ->');

        strCSV = EncodingUtil.urlDecode(strCSV, 'UTF-8');
        
        objAttachment = [SELECT Id, Body 
                         FROM Attachment 
                         WHERE Id = :strFileId];
        
        if(objAttachment.Body != NULL) {
            strCSV = strCSV.replaceAll('%(?![0-9a-fA-F]{2})', '%25');
            strCSV = strCSV.replaceAll('\\+', '%2B');
            strCSV = EncodingUtil.urlDecode(strCSV, 'UTF-16');        
            strExistingBody = objAttachment.Body.toString();
            
            objAttachment.Body = Blob.valueOf(strExistingBody + strCSV);             
        }
        
        update objAttachment;
        
        System.debug('appendFile [] <-');        
    }

    
    private FeedItem generatePostWithRelatedDocument(Id objFileId) {
        FeedItem objFeedItem = null;
        
        System.debug('generatePostWithRelatedDocument [  objFileId : ' +  objFileId + '] ->'); 
        
        objFeedItem = new FeedItem();
        objFeedItem.Body = 'Se ha generado su reporte';
        objFeedItem.ParentId = UserInfo.getUserId();
        objFeedItem.RelatedRecordId = objFileId;
        objFeedItem.Type = 'ContentPost';
        
        insert objFeedItem;
        
        System.debug('generatePostWithRelatedDocument [' + objFeedItem + '] <-'); 
        
        return objFeedItem;        
    }
}