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
        public Boolean ViewEdition { get; set; }
        
        public UserPermissions() {
            this.ContactViewAttributes = FeatureManagement.checkPermission('ContactViewAttributes'); 
            this.ContactViewCommonData = FeatureManagement.checkPermission('ContactViewCommonData'); 
            this.ContactViewContactInfo = FeatureManagement.checkPermission('ContactViewContactInfo'); 
            this.ContactViewContactInfoDetails = FeatureManagement.checkPermission('ContactViewContactInfoDetails'); 
            this.ContactViewElectoral = FeatureManagement.checkPermission('ContactViewElectoral'); 
            this.ContactViewIncome = FeatureManagement.checkPermission('ContactViewIncome'); 
            this.ContactViewLocation = FeatureManagement.checkPermission('ContactViewLocation'); 
            this.ContactViewMapInfo = FeatureManagement.checkPermission('ContactViewMapInfo'); 
            this.ContactViewSocialInfo = FeatureManagement.checkPermission('ContactViewSocialInfo'); 
            this.ContactViewSocialInfoDetails = FeatureManagement.checkPermission('ContactViewSocialInfoDetails'); 
            this.ViewEdition = FeatureManagement.checkPermission('ViewEdition');             
        }
    }