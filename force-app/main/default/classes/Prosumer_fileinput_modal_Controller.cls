public class Prosumer_fileinput_modal_Controller {
    @AuraEnabled
    public static list<ContentDistribution> getFiles(List<String> fileTypes){
        system.debug('Prosumer_fileinput_modal_Controller' + fileTypes);
        return [
                    SELECT id, ContentVersion.FileType, ContentVersion.Title, ContentDownloadUrl, ContentVersionId
                    FROM ContentDistribution 
                    WHERE ContentVersion.Prosumer_Account_fileupload__c =: Prosumer_AudienciaPageController.getAccountFromUser() AND
                              ContentVersion.FileType IN: fileTypes
                    ORDER BY CreatedDate DESC
                ];
    }

    @AuraEnabled
    public static string createLinkForContentVersionId (Id contentVersionId) {
      ContentDistribution cd = new ContentDistribution();
      cd.Name = 'DistributionFor'+contentVersionId;
      cd.ContentVersionId = contentVersionId;
      cd.PreferencesAllowViewInBrowser= true;
      cd.PreferencesLinkLatestVersion=true;
      cd.PreferencesNotifyOnVisit=false;
      cd.PreferencesPasswordRequired=false;
      cd.PreferencesAllowOriginalDownload= true;
      insert cd;
  
      ContentDistribution cdWithLink = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE id=:cd.id];
  
      return cdWithLink.ContentDownloadUrl;
    }

    @AuraEnabled
    public static String getContentVersionDataAsString(Id ContentVersionId){
      ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE id=: ContentVersionId];
      return EncodingUtil.Base64Encode(cv.VersionData);
    }

    @AuraEnabled
    public static void deleteDocumentFromContentVersionId(Id ContentVersionId){
      ContentVersion cd = [SELECT id, contentDocumentId FROM ContentVersion WHERE id=:ContentVersionId];
      
      ContentDocument cvToDelete = new contentDocument();
      cvToDelete.id = cd.contentDocumentId;
      delete cvToDelete;
    }
}