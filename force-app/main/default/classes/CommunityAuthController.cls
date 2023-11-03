public class CommunityAuthController {
    // global CommunityAuthController() {}
    public String username {get; set;}
    public String password {get; set;}

    public String tabTitle {get; set;}
    public String favIconName {get; set;}
    public String zipBundle {get; set;}
    public String footerTitle {get; set;}

    public PageReference doLogin() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    }

    public CommunityAuthController() {
        Community_Config__mdt communityConfig = HelperFunctions.retrieveCommunitySettings();
        this.tabTitle = communityConfig?.Login_Tab_Title__c;
        this.favIconName = communityConfig?.Static_Resourse_Name_FavIcon__c;
        this.zipBundle = communityConfig?.Static_Resourse_Name_ZipBundle__c;
        this.footerTitle = communityConfig?.Login_Footer_Title__c;
    }
    
    /*@AuraEnabled(cacheable=true)
    public static String communityLogin(String username, String password){
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        ApexPages.PageReference pageRef = Site.login(username, password, startUrl);
		return pageRef.getParameters().get('startURL');
    }*/
    
    /*@AuraEnabled(cacheable=true)
    public static String communityLogin(String username, String password, String startURL){
        ApexPages.PageReference pageRef = Site.login(username, password, startUrl);
		return startURL;
    }*/
}